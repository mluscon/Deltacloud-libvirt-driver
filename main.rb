#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'nokogiri'
require 'parseconfig'

require './web'
require './helper'

#recover from outage
redis = Redis.new
if (len=redis.llen('copying')) != 0
  len.times do
    redis.rpoplpush('copying', 'waiting')
  end
end


#config
config = ParseConfig.new( './driver.conf' )
amqp_server = config.get_value( 'amqp_server' )
workers = config.get_value( 'workers' ).to_i
interval = config.get_value( 'interval' ).to_i
    
#workers
workers.times do
  fork do
    loop do
        if uuid = Helper.rpop( 'waiting' )
          Helper.transform( uuid )
          Helper.copy_and_launch( uuid )
        else     
          sleep interval
        end
    end
  end
end

#web interface
Thread.new do
  Web.run!
end


#amqp client
AMQP.start( :host => amqp_server ) do |connection|
  channel = AMQP::Channel.new( connection )
  queue = channel.queue("libvirt", :auto_delete => true)
   
  queue.subscribe do |metadata, payload|
    message = Nokogiri::XML( payload )
        
    case message.root.name
    when 'query'
      uuid = message.xpath( '/query/uuid' ).first.text
      state = Helper.state( uuid )
      channel.default_exchange.publish(state,
                                       :routing_key => metadata.reply_to,
                                       :correlation_id => metadata.message_id,
                                       :immediate => true,
                                       :mandatory => true)    
      
    when 'launch'
      Helper.add( message )
    end
  end
end

                

