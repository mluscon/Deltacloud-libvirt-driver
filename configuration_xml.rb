
GUEST_DISK = "/home/michal/media/Download/Fedora-16-x86_64-Live-KDE.iso"
UUID = "6b70605e-0e06-11e1-92a1-001f1616e000"

class Xml_conf
  def config
    return @new_dom_xml
  end
  
  def initialize
 
@new_dom_xml = <<EOF
<domain type="qemu">
  <name>tralala</name>
  <uuid>#{UUID}</uuid>
  <memory>262144</memory>
  <currentMemory>262144</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type machine="pc-0.14" arch="x86_64" class="text">qemu</type>
    <boot dev="hd"/>
  </os>
  <features>
    <acpi/>
  </features>
  <clock offset="utc"/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-kvm</emulator>
    <disk type="file" device="cdrom">
      <driver type="qcow2" name="qemu"/>
      <source file="#{GUEST_DISK}"/>
      <readonly/>
      <driver name='qemu' type='raw'/>
      <target dev='hdc' bus='ide'/>
      </disk>
    <membaloon model="virtio">
      <address type="pci" function="0x0" domain="0x0000" bus="0x00" slot="0x06"/>
    </membaloon>
  </devices>
</domain>

EOF

  end
end