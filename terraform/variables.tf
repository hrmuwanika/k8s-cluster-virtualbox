variable "vm_count_master" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "vm_count_worker" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "master_cpus" {
  description = "Number of CPUs for master nodes"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "Memory for master nodes in MB"
  type        = number
  default     = 2048
}

variable "worker_cpus" {
  description = "Number of CPUs for worker nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory for worker nodes in MB"
  type        = number
  default     = 2048
}

variable "network_prefix" {
  description = "Network prefix for host-only network"
  type        = string
  default     = "192.168.56"
}

variable "base_image" {
  description = "Base image for VMs"
  type        = string
  default     = "ubuntu/jammy64"
}

variable "disk_size" {
  description = "Disk size for VMs in GB"
  type        = number
  default     = 20
}
