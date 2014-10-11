require 'uri'
require 'nokogiri-plist'
require 'erb'

# Open the binary Bookmarks plist and convert to xml, read it in
input = %x[/usr/bin/plutil -convert xml1 -o - ~/Library/Safari/Bookmarks.plist]

# Let's parse the plist and find the elements we care about
# There's probably a better way to do this, but I'm stupid at Ruby
# This also seems ripe for refactoring, but I'm lazy
reading_list = Array.new
plist = Nokogiri::PList(input)
if plist.include? 'Children'
  plist['Children'].each do |child|
    child.keys.each do |ck|
      if child[ck].is_a? Array
        child[ck].each do |list|
          if list.include? 'ReadingList'
            reading_list <<  { title: list['URIDictionary']['title'], description: list['ReadingList']['PreviewText'], url: URI::escape(list['URLString']) }
          end
        end
      end
    end
  end
end

puts "write index.html..."
template = ERB.new IO.read('index.erb')
IO.write('index.html', template.result)
puts "index.html written."