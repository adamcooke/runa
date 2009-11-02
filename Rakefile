namespace :runa do
  task :start do

    $:.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'runa'
    require 'test/examples/classes'
    
    loop do
      if job = Runa::QueuedJob.next_job
        puts "Running #{job.identifier}"
        job.payload_object.perform
        puts "\e[34;43m[Finished with #{job.identifier}]\e[0m"
        puts "\n\n"
      else
        sleep 1
      end
    end
  end
end
