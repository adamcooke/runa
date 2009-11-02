module Runa
  class Job
        
    attr_accessor :worker, :job_id
    
    def self.queue(*params)
      Runa::QueuedJob.queue(self.new(*params))
    end
    
    def puts(text)
      Runa.logger.debug("#{worker} [#{job_id}]") { "\e[37m#{text}\e[0m" }
    end
    alias_method :log, :puts
    
  end
end
