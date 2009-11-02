require File.join(File.dirname(__FILE__), '..', 'helper') 
 
class TestJobs < Test::Unit::TestCase
  
  def setup
    Runa.delete("jobs")
  end
  
  def test_adding_jobs
    job = Runa::QueuedJob.queue(ExampleJob.new(123))
    assert job.identifier.is_a?(String)
    assert_equal job.attributes, Runa.pull(:jobs)
  end
  
  def test_running_payload_objects_through_redis
    Runa::QueuedJob.queue(ExampleJob.new(333))
    job = Runa::QueuedJob.next_job
    assert_equal "ID: 333", job.payload_object.perform
  end
  
  def test_getting_a_job_when_none_exist
    assert_equal nil, Runa::QueuedJob.next_job
  end
  
  def test_jobs_can_be_queued_using_inherited_job_class
    assert ExampleJob2.queue(234).is_a?(Runa::QueuedJob)
    assert_equal "Another ID: 234", Runa::QueuedJob.next_job.payload_object.perform
  end
  
end

class ExampleJob
  
  def initialize(id)
    @id = id
  end
  
  def perform
    "ID: #{@id}"
  end
  
end

class ExampleJob2 < Runa::Job
  
  def initialize(id)
    @id = id
  end
  
  def perform
    "Another ID: #{@id}"
  end
  
end
