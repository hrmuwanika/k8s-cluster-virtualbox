[masters]
${master_ip} ansible_host=${master_ip} ansible_user=vagrant

[workers]
%{ for ip in worker_ips ~}
${ip} ansible_host=${ip} ansible_user=vagrant
%{ endfor ~}

[k8s_cluster:children]
masters
workers

[k8s_cluster:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
