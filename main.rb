#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'nokogiri'
require 'parseconfig'

require './instance'
require './web'
require './helper'


#config
config = ParseConfig.new('./driver.conf')
amqp_server = config.get_value('amqp_server')
workers = config.get_value('workers').to_i

    
#workers
workers.times do
  fork do
    redis = Redis.new
    helper = Helper.new
    loop do
        if uuid = redis.lpop( 'waiting' )
          helper.copy( uuid )
	  helper.transform( uuid )
        else     
          sleep 5
        end
    end
  end
end

#web interface
fork do
  Web.run!
end


#amqp client
helper = Helper.new

AMQP.start( :host => amqp_server ) do |connection|
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("libvirt", :auto_delete => true)
   
  queue_.subscribe do |metadata, payload|
    message = Nokogiri::XML(payload)
    case message.root.name
    when 'query'
      uuid = message.xpath('/query/uuid').first.text
      state = helper.state( uuid )
      channel.default_exchange.publish(state,
                                       :routing_key => metadata.reply_to,
                                       :correlation_id => metadata.message_id,
                                       :immediate => true,
                                       :mandatory => true)    
      
    when 'launch'
      helper.add( message )
    end
  end
end

                

