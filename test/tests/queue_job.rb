## Queue lots of jobs for the workers to play with...

$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'runa'
require 'test/examples/classes'

100000.times do |f|
  ExampleJob.queue(f)
end
