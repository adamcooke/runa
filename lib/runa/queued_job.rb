require 'digest'

module Runa
  class QueuedJob
    
    class DeserializationError < StandardError; end
    
    ## A hash of all attributes related to this job
    attr_accessor :attributes
    
    ## Construct a new QueuedJob based on the attributed hash provided.
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
    
    ## The deserialized class which should be run for this job.
    def payload_object
      @payload_object ||= deserialize(self.attributes['handler'])
    end
    
    ## When a job completes, move it into the "compelted" list for inspection later. This will
    ## get large over time and should be cleared or not even attempted - it depends on your application
    ## and how often you want to clear it.
    def complete!
      Runa.push "jobs:completed", self.attributes
    end
    
    ## When a job fails (i.e. an exception is raised within the job class), log the error message
    ## and push the job into the "failed" job queue for inspection.
    def fail!(e)
      Runa.log :info, e.message
      Runa.push "jobs:failed", self.attributes
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
        o['identifier']  = Digest::SHA1.hexdigest(o['handler'] + "#{Time.now.utc.to_s}")[0,13]
        Runa.push "jobs", o
        new(o)
      end
      
      ## Get the next job to run or return nil if no jobs to run...
      def next_job
        hash = Runa.pull(:jobs)
        hash.is_a?(Hash) ? new(hash) : nil
      end
      
      ## Get a list of all jobs which have failed. This list should be cleared out on a regular basis
      def failed
        Runa.get_list('jobs:failed').map{|c| new(c) }
      end
      
      ## Get a list of all currently queued jobs...
      def queued
        Runa.get_list('jobs').map{|c| new(c) }
      end
      
    end
    
  end
end
