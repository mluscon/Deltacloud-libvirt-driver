
require 'fileutils'
require 'rubygems'
require 'nokogiri'
 


class Instance
  
  def initialize( xml )
    @state = 1
    @spec = xml
    
    puts( xml.xpath('/domain/uuid').first.text + " was created")
  end
  
  def copy( from, to )
     @thread = Thread.new do 
	FileUtils.cp( from, to)
     end
 
  end
    
end

#inst = Instance.new
#inst.copy("/home/mluscon/test.img", "/home/mluscon/copy_of_test.img")

#while true do puts "tralala" end