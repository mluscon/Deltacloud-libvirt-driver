
require 'fileutils'
require 'rubygems'

 


class Instance
  
  
  def initialize()
    @state = 1
  end
  
  def copy( from, to )
     @thread = Thread.new do 
	FileUtils.cp( from, to)
     end
 
  end
    
end

inst = Instance.new
inst.copy("/home/mluscon/test.img", "/home/mluscon/copy_of_test.img")

while true do puts "tralala" end