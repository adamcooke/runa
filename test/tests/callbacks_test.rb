require File.join(File.dirname(__FILE__), '..', 'helper') 
 
class TestCallbacks < Test::Unit::TestCase
  
  def setup
    Runa.delete("jobs")
    Runa.delete("jobs:completed")
    Runa.delete("jobs:failed")
  end
  
  def test_callbacks
    job = ExampleJob.queue
    $global_a = nil
    $global_b = nil
    Runa.before_work_callback = Proc.new{|worker, job| $global_a = :before_invoked}
    Runa.after_work_callback = Proc.new{|worker, job| $global_b = :after_invoked}
    worker = Runa::Worker.new
    worker.send(:perform_job, job)
    assert_equal :before_invoked, $global_a
    assert_equal :after_invoked, $global_b
  end
  
end

class ExampleJob < Runa::Job
  def perform
    "Hello"
  end
end
