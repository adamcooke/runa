module Runa
  class Job
        
    attr_accessor :worker, :job_id
    
    def self.queue(*params)
      Runa::QueuedJob.queue(self.new(*params))
    end
    
    def puts(text)
      Runa.log :debug, "\e[37m#{text}\e[0m", "#{worker} [#{job_id}]"
    end
    alias_method :log, :puts
    
  end
end
