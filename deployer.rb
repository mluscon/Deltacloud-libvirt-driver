require 'libvirt'
require './configuration_xml.rb'

conn = Libvirt::open("qemu:///system")

if conn.closed?
  puts "closed"
else
  puts "open"
end

xml = Xml_conf.new

dom = conn.create_domain_xml(xml.config)

sleep 150

dom.destroy
conn.close