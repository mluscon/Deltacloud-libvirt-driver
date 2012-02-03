require 'fileutils'
require 'rubygems'
require 'nokogiri'
require 'resque'
require 'resque/helpers'
require 'resque_scheduler'
require 'redis'



require './configuration_xml'


class Instance
  
  def initialize( spec )
    @queue = :images
    @state = 1
    @spec = spec
     
    from = "/home/mluscon/projects/deltacloud-libvirt/driver/test.img" 
    to = "/home/mluscon/projects/deltacloud-libvirt/driver/test_copy.img"
    @uuid = spec.xpath('/domain/uuid').first.text
    
    Resque.enqueue( self, @uuid, from, to )
    
  end
  
  def self.perform( uuid, from, to)
    FileUtils.cp( from, to)
  end
  
  attr_accessor :state
  
end




