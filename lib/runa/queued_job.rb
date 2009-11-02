require 'digest'

module Runa
  class QueuedJob
    
    class DeserializationError < StandardError; end
    
    ## A hash of all attributes related to this job
    attr_accessor :attributes
    
    def initialize(attributes = {})
      @attributes = attributes
    end
    
    ## Pass any methods via. the attributes hash to see if they exist
    ## before resuming normal method_missing behaviour
    def method_missing(method, *params)
      set = method.to_s.include?('=')
      key = method.to_s.sub('=', '')
      self.attributes = Hash.new unless self.attributes.is_a?(Hash)
      if set
        self.attributes[key] = params.first
      else
        self.attributes[key]
      end
    end
    
    def payload_object
      @payload_object ||= deserialize(self.attributes['handler'])
    end
    
    def complete!
      Runa.push "jobs:completed", self.attributes
    end
    
    def failed!(e)
      Runa.logger.info e.message
      Runa.push "jobs_failed", self.attributes
    end
    
    private
    
    ## Deserialize the passed YAML handler and return an object which we can invoke properly.
    ## If fails, raise a DeserializationError error which cannot be rescued from.
    def deserialize(source)
      handler = YAML.load(source) rescue nil

      unless handler.respond_to?(:perform)
        if handler.nil? && source =~ /\!ruby\/\w+\:([^\s]+)/
          handler_class = $1
        end
        attempt_to_load(handler_class || handler.class)
        handler = YAML.load(source)
      end

      return handler if handler.respond_to?(:perform)

      raise DeserializationError, 'Job failed to load: Unknown handler. Try to manually require the appropiate file.'
    rescue TypeError, LoadError, NameError => e
      raise DeserializationError, "Job failed to load: #{e.message}. Try to manually require the required file."
    end
    
    ## Constantize the object so that ActiveSupport can attempt
    ## its auto loading magic. Will raise LoadError if not successful.
    def attempt_to_load(klass)
       klass.constantize
    end
    

    class << self
      
      ## Queue the passed job to run...
      def queue(obj)
        o = {}
        o['handler']     = YAML.dump(obj)
        value = Digest::SHA1.hexdigest(o['handler'] + "#{Time.now.utc.to_s}")
        o['identifier']  = value[0,13]
        Runa.push "jobs", o
        new(o)
      end
      
      ## Get the next job to run or return nil if no jobs to run...
      def next_job
        hash = Runa.pull(:jobs)
        hash.is_a?(Hash) ? new(hash) : nil
      end
      
      ## Get the latest failed jobs
      def failed
        Runa.backend.list_range('jobs:failed', 0, -10)
      end
      
      def queued
        Runa.backend.list_range('jobs', 0, -100)
      end
      
      def completed
        Runa.backend.list_range('jobs:completed', 0, -10)
      end
      
    end
    
  end
end
