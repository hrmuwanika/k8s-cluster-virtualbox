output "master_ip" {
  description = "IP address of the Kubernetes master node"
  value       = virtualbox_vm.k8s_master.network_adapter[0].ipv4_address
}

output "worker_ips" {
  description = "IP addresses of the Kubernetes worker nodes"
  value       = [for vm in virtualbox_vm.k8s_worker : vm.network_adapter[0].ipv4_address]
}

output "inventory_file" {
  description = "Path to generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}
