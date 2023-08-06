packer {
# we are using aws
  required_plugins {
	  amazon = {
	    version = ">= 1.0.0"
	    source = "github.com/hashicorp/amazon"
	  }
  }
}

locals {
  timestamp = regex_replace(timestamp(),"[- TZ:]","")
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "region" {
  type = string
  default = "us-west-1"
}

variable "profile" {
  type = string
  default = "labs"
}

source "amazon-ebs" "packer-demo" {
# which AMI to use as the base
# where to save AMI
  
  ami_description = "CentOS 7 Base Image with Cloud-init and Other Pre-configurations."
  ami_name = "packer-demo-${local.timestamp}"
  instance_type   = var.instance_type
  region          = var.region
  ssh_username    = "centos"
  profile         = var.profile

  # Copy AMI to other regions
  ami_regions = [ "us-west-1", "eu-west-2" ]

  force_deregister = true
  force_delete_snapshot = true

   
  # reference https://www.centos.org/download/aws-images/
  # source_ami = "ami-0bcd12d19d926f8e9"
  
  source_ami_filter {
    filters = {
      name                = "packer-demo-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = [ "self" ]
  }

}


build {

  sources = [
    "source.amazon-ebs.packer-demo"
  ]

# Wait for Cloud-init to finish initial setup
provisioner "shell" {
  inline = [
     "sudo timeout 90 /usr/bin/cloud-init status --wait"
  ]
}

# Install the root ssh key.
provisioner "file" {
    source = "files/id_dsa"
    destination = "/tmp/"
  }

provisioner "shell" {
    inline = [
      "sudo cp /tmp/id_dsa /root/.ssh"
    ]
  }

provisioner "shell" {
    script = "./scripts/sys_motd.sh"
  }

}