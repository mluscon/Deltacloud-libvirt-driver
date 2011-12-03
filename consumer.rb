require 'rubygems'
require 'amqp'
require 'nokogiri'

EventMachine.run do
  connection = AMQP.connect(:host => 'localhost')
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

  machines = []

  channel = AMQP::Channel.new(connection)
  queue = channel.queue("libvirt", :auto_delete => true)
  queue.subscribe do |metadata, payload|
    libvirt_spec = Nokogiri::XML(payload)
    machines << {
      :uuid => libvirt_spec.xpath('/domain/uuid').first.text,
      :name => libvirt_spec.xpath('/domain/name').first.text,
      :memory => libvirt_spec.xpath('/domain/memory').first.text,
      :cpus => libvirt_spec.xpath('/domain/vcpu').first.text,
    }
    puts payload
    puts machines
  end
end
