namespace :runa do
  task :start do
    $:.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'runa'
    require 'test/examples/classes'
    Runa::Worker.new.work
  end
end
