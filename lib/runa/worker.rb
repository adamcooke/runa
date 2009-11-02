module Runa
  class Worker
    
    def initialize(identifier)
      @identifier = identifier
    end
    
    def work
      loop do
        if j = QueuedJob.next_job
          j.payload_object.perform
          puts "Run Job: #{j.identifier}"
        end
        sleep 1
      end
    end
    
  end
end
