variable project {
    description = "Reference Project name"
    default = "wabbit"
}

variable "region" {
  description ="Reference region"
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-a"  
}

variable "network_name" {
  description = "Wabbit VPC network name"
  default = "wabbitvpc"
}

variable "gcp_vm_count" {\
description = "Number of VMs to be run"
default=1
}

variable "wabbitwww" {
  description = "BBB server names"
  default="www"
}




