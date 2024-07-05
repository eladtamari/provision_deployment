terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
     ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}


resource "virtualbox_vm" "node" {
  count     = 2
  name      = format("node-%02d", count.index + 1)
  //image     = "/Users/eladtamari1/Downloades/ubuntu-22.04.4-live-server-amd64.iso"
  image     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20240701.0.0/providers/virtualbox.box" 
  //image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "512 mib"
  //user_data = file("${path.module}/user_data")
  
  # connection {
  #     type     = "ssh"
  #     user     = "ubuntu"
  #     password = "ubuntu"
  #     host     = self.network_adapter[0].ip_address
  # }
  network_adapter {
    type   = "bridged"
    device = "IntelPro1000MTDesktop"
    host_interface = "en0"
  }
}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}

output "IPAddr_2" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 2)
}

# resource "local_file" "inventory" {
#   content = templatefile("../ansiblefiles/inventory.tpl", {
#   instances = [(virtualbox_vm.node.*.network_adapter.0.ipv4_address)]
#   })
#   filename = "../ansiblefiles/inventory.ini"
# }

# output "inventory" {
#   value = local_file.inventory.content
# }

resource "ansible_playbook" "playbook" {
  playbook   = "../ansiblefiles/playbook.yml"
  name       = "../ansiblefiles/inventory.ini"   
  replayable = true

  extra_vars = {
    ansible_connection="ssh"
    ansible_user="vagrant"
    ansible_ssh_pass="vagrant"
  }
}
 