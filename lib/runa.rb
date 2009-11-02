## Runa is a job/background task runner powered by a backend Redis database.
## This library can be easily added onto an application to replace a system like delayed_job
## or the existing Codebase library 'WorkHorse'.

require 'yaml'
require 'redis'

require 'runa/job'
require 'runa/queued_job'
require 'runa/worker'

module Runa
  
  class << self
    
    ## The hostname of the redis server (defaults to localhost)
    attr_accessor :redis_server
    attr_accessor :redis_port
    
    ## The logger which should be used for logging and task activity
    attr_accessor :logger
    
    ## The backend Redis connection object which is used for all database communications
    ## within the library.
    def backend
      @backend ||= Redis.new({:host => self.redis_server, :port => self.redis_port})
    end
    
    ## Push a value into a list. If the value is not a string, serialize it using YAML before
    ## saving.
    def push(list, value)
      value = YAML::dump(value) unless value.is_a?(String)
      backend.push_tail(list.to_s, value)
    end
    
    ## Pull the next value from a given list.
    def pull(list)
      value = backend.pop_head(list.to_s)
      value.nil? ? String.new : YAML::load(value)
    end
    
    ## Empty a named list (delete it)
    def delete(list)
      backend.delete(list.to_s)
    end
    
  end
  
end
