require 'rubygems'
require 'amqp'
require 'nokogiri'
require './instance'
require './interface'

instances = Hash.new

Thread.new do
  Driver_web.run!
end


EventMachine.run do
  connection = AMQP.connect(:host => '192.168.2.101')
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."
  
    

  channel = AMQP::Channel.new(connection)
  queue = channel.queue("libvirt", :auto_delete => true)
  queue.subscribe do |metadata, payload|
    libvirt_spec = Nokogiri::XML(payload)
    
    uuid = libvirt_spec.xpath('/domain/uuid').first.text
    instances[uuid] = Instance.new( libvirt_spec )
    
    end
end
