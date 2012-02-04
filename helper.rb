require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'redis'
require 'libvirt'

class Helper
  
  def initialize
    @redis = Redis.new
    
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

  def copy_and_launch( uuid )
    conn = Libvirt::open("qemu:///system")
    from = @redis.hget( uuid, 'from')
    to = @redis.hget( uuid, 'to' )
    spec = @redis.hget(uuid, 'spec')
    @redis.rpush( "copying" , uuid.to_str ) 
    
    FileUtils.cp( from, to)
    @redis.lrem( "copying", 1, uuid )
    @redis.rpush( "running", uuid)
    dom = conn.create_domain_xml( spec )
  end
  
  def transform( uuid )
    to = @redis.hget(uuid, 'to')
    spec = Nokogiri::XML( @redis.hget(uuid, 'spec') )
    
    spec.search('//source').each do |node|
      node.set_attribute(file, to)
    end
    
    @redis.hset('spec', spec)    
  end
  
  
end
    

