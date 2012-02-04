require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'redis'

class Helper
  
  def initialize
    @redis = Redis.new
    builder = Nokogiri::XML::Builder.new do
      response {
        uuid_ 
        status_
    }
    end

  end
  
  def status( uuid )
    #need to complete
    #if redis.sismember('waiting', uuid )  return status 
     
    #if redis.sismember('copying', uuid )  return status
     
    #if redis.sismember('running', uuid )  return status
  end
  
  def add( message )
    uuid = message.xpath('/query/domain/uuid').first.text
    from = message.xpath('/query/copy_from').first.text
    to = message.xpath('/query/copy_to').first.text
    spec = message.xpath('/query/domain')
    @redis.hmset( uuid, 'from' , from, 'to', to, 'spec', spec )
    @redis.rpush( "waiting", uuid ) 
  end

  def copy( uuid )
    from = @redis.hget( uuid, 'from')
    to = @redis.hget( uuid, 'to' )
    @redis.rpush( "copying" , uuid.to_str ) 
    
    FileUtils.cp( from, to)
    @redis.lrem( "copying", 1, uuid )
    @redis.rpush( "running", uuid)
  end
  
  
end
    

