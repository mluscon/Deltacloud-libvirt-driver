require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'redis'
require 'libvirt'

module Helper
  
  def self.status( uuid )
    redis = Redis.new
    if redis.sismember( 'running', uuid )
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
  
  def self.add( message )
    redis = Redis.new
    uuid = message.xpath( '/query/domain/uuid' ).first.text
    from = message.xpath( '/query/copy_from' ).first.text
    to = message.xpath( '/query/copy_to' ).first.text
    spec = message.xpath( '/query/domain' )
    redis.hmset( uuid, 'from' , from, 'to', to, 'spec', spec )
    redis.rpush( "waiting", uuid ) 
  end

  def self.copy_and_launch( uuid )
    redis = Redis.new
    conn = Libvirt::open( 'qemu:///system' )
    from = redis.hget(uuid, 'from')
    to = redis.hget(uuid, 'to' )
    spec = redis.hget(uuid, 'spec')
    redis.rpush('copying' , uuid ) 
    
    FileUtils.cp(from, to)
    
    redis.lrem('copying', 1, uuid )
    redis.rpush('running', uuid)
    dom = conn.create_domain_xml( spec )
    conn.close
  end
  
  def self.transform( uuid )
    redis = Redis.new
    to = redis.hget(uuid, 'to')
    spec = Nokogiri::XML( @redis.hget(uuid, 'spec') )
    
    spec.search('//source').each do |node|
      node.set_attribute(file, to)
    end
    
    redis.hset('spec', spec)    
  end
  
  def self.rpop( list )
    redis = Redis.new
    return redis.lpop( 'waiting' )
end
    

