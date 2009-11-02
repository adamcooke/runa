Dir[File.join(File.dirname(__FILE__), 'tests', '*.rb')].each do |file|
  next if file.include?("threads.rb")
  require file
end
