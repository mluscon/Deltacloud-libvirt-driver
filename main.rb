#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'nokogiri'


require './instance'
require './web'

$machines = Hash.new


  
#resque worker
fork do  
  loop do
    if job = Resque.reserve(:images)
     job.perform
    else     
      sleep 5
    end
   end
end

#sinatra interface
Thread.new do
  Web.run!
end


#amqp client
amqp_server = ARGV[0]
printf "Connecting to amqp server on #{amqp_server}.\n"

AMQP.start( :host => amqp_server ) do |connection|
  
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."
  
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("libvirt", :auto_delete => true)
  
  queue.subscribe do |metadata, payload|
    libvirt_spec = Nokogiri::XML(payload)
    uuid = libvirt_spec.xpath('/domain/uuid').first.text
    $machines[uuid] = Instance.new( libvirt_spec )

  end
  
end


