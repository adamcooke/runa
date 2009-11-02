#Runa

Runa is a simple Redis-powered background job runner library. It allows you to easily create
classes which are then run by the works you start.

In the most basic form, you can simply create a class which inherits from `Runa::Job` and the 
simply invoke `MyCoolClass.queue(param1, param2, etc)` which will queue the job.

To start a worker process, you should create a wrapper in your application which includes
your own application and then simply run `Runa::Worker.new.work`. You can use the
configuration options below to adjust things to suit you:

    Runa.redis_server   =   "redis.mydomain.com"
    Runa.redis_port     =   1234
    Runa.key_prefix     =   "application_"
    Runa.logger         =   Logger.new("path/to/log/file.log")

In addition to these basic variables, you can also define a couple of callbacks which will be
invoke before and after a job is run by a worker process.

    Runa.before_work_callback   = Proc.new {|worker, job| do_something }
    Runa.after_work_callback    = Proc.new {|worker, job| do_something }

##Setup

The library will work with Rails or any other Ruby application. Simply get the source and 
`require runa`. You'll also need [redis-rb](http://github.com/ezmobius/redis-rb) in your load path.

If you're working with Rails, you can simply install this as a gem and then configure it in 
`config/initalizers/runa.rb`.

##Queueing Jobs

There are two ways to queue jobs in Runa. The easiest way is to simply create a class which inherits
from `Runa::Job`, this will add a class level `queue` method which you can use in the same as `new`
and it'll return the new `Runa::QueuedJob` object. It will also create `log` method which will send
output to your Runa logger (this is also aliased to `puts`).

    class MyExampleJob < Runa::Job
      def initialize(param)
        @param = param
      end
      
      def perform
        #do something with @param
      end
    end

    MyExampleJob.queue(1234)

Alternatively, if you'd rather just just clean classes, you can run the command below which will also
return the new Runa::QueuedJob object.

    Runa::QueuedJob.queue(MyCleanClass.new(1234))

##Identifiers

Each job is assigned a 13 character SHA-based identifier based on the time it was queued and the contents
of the handler/class.

##Licence

Licensed under the MIT-LICENCE.
