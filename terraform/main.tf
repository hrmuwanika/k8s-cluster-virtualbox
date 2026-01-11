terraform {
  required_version = ">= 1.5.0"
  
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
  count     = var.vm_count_master
  name      = "k8s-master-${count.index + 1}"
  image     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20231215.0.0/providers/virtualbox/unknown/vagrant.box"
  cpus      = var.master_cpus
  memory    = var.master_memory
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }

  network_adapter {
    type = "nat"
  }
}

# Worker Nodes
resource "virtualbox_vm" "k8s_worker" {
  count     = var.vm_count_worker
  name      = "k8s-worker-${count.index + 1}"
  image     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20231215.0.0/providers/virtualbox/unknown/vagrant.box"
  cpus      = var.worker_cpus
  memory    = var.worker_memory
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }

  network_adapter {
    type = "nat"
  }
}

# Create Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    masters = virtualbox_vm.k8s_master[*]
    workers = virtualbox_vm.k8s_worker[*]
  })
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}

# Generate SSH config
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    masters = virtualbox_vm.k8s_master[*]
    workers = virtualbox_vm.k8s_worker[*]
  })
  filename = "${path.module}/ssh_config"
}
