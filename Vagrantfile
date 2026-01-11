# -*- mode: ruby -*-
# vi: set ft=ruby :

MASTER_IP = "192.168.56.10"
WORKER_COUNT = 2
WORKER_IP_BASE = "192.168.56.2"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false

  # Force VirtualBox provider
  config.vm.provider "virtualbox"

  # Master Node
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: MASTER_IP
    
    master.vm.provider "virtualbox" do |vb|
      vb.name = "k8s-master"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  # Worker Nodes
  (1..WORKER_COUNT).each do |i|
    config.vm.define "k8s-worker-#{i}" do |worker|
      worker.vm.hostname = "k8s-worker-#{i}"
      worker.vm.network "private_network", ip: "#{WORKER_IP_BASE}#{i}"
      
      worker.vm.provider "virtualbox" do |vb|
        vb.name = "k8s-worker-#{i}"
        vb.memory = "2048"
        vb.cpus = 2
      end
    end
  end
end
