output "master_nodes" {
  description = "Master node details"
  value = {
    for idx, vm in virtualbox_vm.k8s_master : vm.name => {
      id            = vm.id
      network_adapter = vm.network_adapter
    }
  }
}

output "worker_nodes" {
  description = "Worker node details"
  value = {
    for idx, vm in virtualbox_vm.k8s_worker : vm.name => {
      id            = vm.id
      network_adapter = vm.network_adapter
    }
  }
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "ssh_config_path" {
  description = "Path to generated SSH config"
  value       = local_file.ssh_config.filename
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    master_count = var.vm_count_master
    worker_count = var.vm_count_worker
    total_nodes  = var.vm_count_master + var.vm_count_worker
  }
}
