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
    @redis = Redis.new
    from = "/home/mluscon/projects/deltacloud-libvirt/driver/test.img" 
    to = "/home/mluscon/projects/deltacloud-libvirt/driver/test_copy.img"
    @uuid = spec.xpath('/domain/uuid').first.text
    
    Resque.enqueue( self, from, to )
    redis.sadd "waiting" @uuid
  end
  
  def self.perform(uuid, from, to)
    @redis.srem "waiting" @uuid
    @redis.sadd "copying" @uuid
    FileUtils.cp( from, to)
    @redis.srem "copying" @uuid
    @redis.sadd "running" @uuid
  end
  
  attr_accessor :state
  
end




