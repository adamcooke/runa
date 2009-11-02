Dir[File.join(File.dirname(__FILE__), 'tests', '*.rb')].each do |file|
  next unless file.include?("_test.rb")
  require file
end
