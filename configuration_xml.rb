
class Xml_conf
  def config
    return @new_dom_xml
  end
  
  def initialize
 
@new_dom_xml = <<EOF
<query>
<copy_from>./test.img</copy_from>
<copy_to>./test_copy.img</copy_to>
<domain type="kvm">
  <name>Testing instance</name>
  <uuid>5bf1b4be-1920-11e1-92be-001f1616e111</uuid>
  <memory>256000</memory>
  <currentMemory>256000</currentMemory>
  <vcpu>2</vcpu>
  <os>
    <type machine="pc-0.14" arch="x86_64" class="text">hvm</type>
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
    <disk type="file" device="disk">
      <source file="/home/mluscon/test.img"/>
      <target dev="vda" bus="virtio"/>
      
    </disk>
    <membaloon model="virtio">
      <address type="pci" function="0x0" domain="0x0000" bus="0x00" slot="0x06"/>
    </membaloon>
  </devices>
</domain>
</query>
EOF

  end
end