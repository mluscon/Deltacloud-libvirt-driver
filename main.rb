#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'nokogiri'
require 'parseconfig'

require './instance'
require './web'

#config
config = ParseConfig.new('./file.conf')
amqp_server = config.get_value('amqp_server')
workers = Integer( config.get_value('workers') )

    
#workers
workers.times do
  fork do  
    loop do
        if job = Resque.reserve(:images)
        job.perform
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
machines = Hash.new

AMQP.start( :host => amqp_server ) do |connection|
    
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("libvirt", :auto_delete => true)
   
  queue_.subscribe do |metadata, payload|
    message = Nokogiri::XML(payload)
    case message.root.name
    when 'query'
      uuid = libvirt_spec.xpath('/query/uuid').first.text
      state = helper.state( uuid )
      channel.default_exchange.publish(state,
                                       :routing_key => metadata.reply_to,
                                       :correlation_id => metadata.message_id,
                                       :immediate => true,
                                       :mandatory => true)    
      
    when 'launch'
      uuid = libvirt_spec.xpath('/launch/domain/uuid').first.text
      $machines[uuid] = Instance.new( libvirt_spec )
    end
  end
end

