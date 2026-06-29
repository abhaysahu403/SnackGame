[control]

ansible-control ansible_host=${control_ip}

[workers]

%{ for ip in worker_ips ~}
worker-${index(worker_ips, ip) + 1} ansible_host=${ip}
%{ endfor ~}

[all:vars]

ansible_user=ubuntu
ansible_ssh_private_key_file=~/Downloads/AbhayOrg.pem
ansible_python_interpreter=/usr/bin/python3