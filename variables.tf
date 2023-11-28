variable "rg-name"{
    type = string
    default = "testing1996"
}
variable "vpc-name" {
     type = string
     default = "ashok-vpc"
     
}

variable "subnet-name" {
  type =list(string)
  default = ["ashok-subnet-1a","ashok-subnet-1b"]
}
variable "public-ip-name"{
    type = string
}

variable "nic-name"{
    type = string
    default = "ashok-nic"
}

variable "vm-name"{
    type = string
    default = "ashok-vm"
  
}
variable "test" {
  type = bool
  default = true
  
}

variable "nsg-name"{
    type = string
    default = "ashok-nsg"
}


variable "tags" {
  type = map(any)
  default = {
    Name        = "testing_project"
    Environment = "DEV"
    Terraform   = "true"
  }
}

# variable "vpc_tags" {
#   type = map
#   default = {}
# }

# variable "resource_group_tags" {
#   type = map
#   default = {}
# }

variable "vm_tags" {
  type = map
  default = {}
}

# variable "subnet_tags" {
#   type = map
#   default = {}
# }

variable "nsg_tags" {
  type = map
  default = {}
}

variable "key_vault_name"{
   type = string
   default = "ashok-key-vault"
}
variable "key_vault_secret_name"{
   type = string
   default = "ashok-secret"
}

variable "image_name" {
  type = string
}