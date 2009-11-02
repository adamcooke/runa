require 'socket'

module Runa
  class Worker
    
    attr_reader :identifier
    
    def initialize
      @identifier = "#{Socket.gethostname}:#{Process.pid}"
    end
    
    ## Start polling for jobs and running those which you find. Also register itself with the
    ## 'workers' list.
    def work
      trap("TERM") { log("Exiting.."); $exit = true }
      trap("INT")  { log("Exiting..."); $exit = true }
      
      log "Started Runa Worker"
      loop do
        break if $exit
        if job = QueuedJob.next_job
          log "\e[4;32mStart Processing\e[0m", job
          begin
            job.payload_object.worker = self.identifier
            job.payload_object.job_id = job.identifier
            job.payload_object.perform
            job.complete!
            log "\e[4;33mJob Completed\e[0m", job
          rescue => e
            job.fail!(e)
          end
          
        else
          sleep 1
        end
      end
    end
    
    private
    
    def log(string, job = nil)
      id = (job ? "#{identifier} [#{job.identifier}]" : identifier )
      Runa.log :info, string, id
    end
    
  end
end
