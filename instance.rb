require 'fileutils'
require 'rubygems'
require 'nokogiri'
require 'resque'
require 'resque/helpers'
require 'redis'

require './configuration_xml'

class Instance
  
  def initialize( spec )
    @queue = :images
    @state = 1
    @spec = spec
    Redis.new
    from = "/home/michal/projects/deltacloud/driver/test.img" 
    to = "/home/michal/projects/deltacloud/driver/test_copy.img"
    @uuid = spec.xpath('/domain/uuid').first.text
    
    Resque.enqueue( self, @uuid, from, to )
    Redis.new.sadd "waiting", @uuid
  end
  
  def self.perform( uuid, from, to )
    puts uuid
    redis = Redis.new
    redis.srem "waiting", uuid
    redis.sadd "copying", uuid
    FileUtils.cp( from, to)
    redis.srem "copying", uuid
    redis.sadd "running", uuid
  end
  
  attr_accessor :state
  
end




