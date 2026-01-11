variable "vm_image" {
  description = "VM image for VirtualBox (Ubuntu 22.04 recommended)"
  type        = string
  default     = "https://app.vagrantup.com/ubuntu/boxes/jammy64/versions/20230616.0.0/providers/virtualbox.box"
}

variable "master_cpus" {
  description = "Number of CPUs for master node"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "Memory for master node in MB"
  type        = string
  default     = "2048 mib"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "worker_cpus" {
  description = "Number of CPUs for worker nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory for worker nodes in MB"
  type        = string
  default     = "2048 mib"
}

variable "host_only_adapter" {
  description = "VirtualBox host-only adapter name"
  type        = string
  default     = "vboxnet0"
}
