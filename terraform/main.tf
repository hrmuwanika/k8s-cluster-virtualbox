terraform {
  required_version = ">= 1.0"
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "~> 0.2"
    }
  }
}

provider "virtualbox" {}

# Master Node
resource "virtualbox_vm" "k8s_master" {
  name   = "k8s-master"
  image  = var.vm_image
  cpus   = var.master_cpus
  memory = var.master_memory

  network_adapter {
    type           = "hostonly"
    host_interface = var.host_only_adapter
  }

  network_adapter {
    type = "nat"
  }
}

# Worker Nodes
resource "virtualbox_vm" "k8s_worker" {
  count  = var.worker_count
  name   = "k8s-worker-${count.index + 1}"
  image  = var.vm_image
  cpus   = var.worker_cpus
  memory = var.worker_memory

  network_adapter {
    type           = "hostonly"
    host_interface = var.host_only_adapter
  }

  network_adapter {
    type = "nat"
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    master_ip  = virtualbox_vm.k8s_master.network_adapter[0].ipv4_address
    worker_ips = [for vm in virtualbox_vm.k8s_worker : vm.network_adapter[0].ipv4_address]
  })
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}
