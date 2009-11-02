module Runa
  class Job
    
    def self.queue(*params)
      Runa::QueuedJob.queue(self.new(*params))
    end
    
  end
end
