[all]
%{ for instance in instances ~}
${instance.network_adapter[0].ip_address} ansible_user=ubuntu ansible_ssh_pass=your_password
%{ endfor ~}
