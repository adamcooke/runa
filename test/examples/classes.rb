class ExampleJob < Runa::Job
  def initialize(id)
    @id = id
  end
  def perform
    puts "ID is : #{@id}"
    File.open("ids.txt", "a") { |f| f.write(@id.to_s + "\n")}
    puts "Saved output to ids.txt"
    puts "More pointless text to make the logs look like they do stuff..."
    puts "Something else awesome."
  end
end
