class ExampleJob < Runa::Job
  def initialize(id)
    @id = id
  end
  def perform
    puts "ID is : #{@id}"
    File.open("ids.txt", "a") { |f| f.write(@id.to_s + "\n")}
  end
end
