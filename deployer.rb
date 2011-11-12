require 'libvirt'

conn = Libvirt::open_auth("qemu:///system")


if conn.closed?
  puts "Connection was not been established."
  return
else
  puts "Connection is established now."
end
  
conn.close