require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'redis'
require 'libvirt'

class Helper
  
  def initialize
    @redis = Redis.new
    @conn = Libvirt::open("qemu:///system")
  end
  
  def status( uuid )
    if @redis.sismember('running', uuid )
      builder = Nokogiri::XML::Builder.new do
      response {
        uuid_ uuid
        status_ 'running'
      }
      end
      return builder.to_xml
    else
      builder = Nokogiri::XML::Builder.new do
      response {
        uuid_ uuid
        status_ 'pending'
      }
      end
      return builder.to_xml
    end     
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
  
  def transform( uuid )
    
    
    
  end
    
end
    

