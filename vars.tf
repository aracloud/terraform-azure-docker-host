
####################################
# define planet wide vars :-)

variable "prefix" {
  description = "prefix for created objects"
  type = string
}

####################################
# define azure wide vars

variable "azure-location" {
  description = "azure location to run the deployment"
  type = string
}

# tag: source git for azure resource group 
variable "tag_source_git" {
  type = string
}

# tag: owner azure resource group
variable "tag_owner" {
  type = string
}

# azure docker node instance type
variable "docker-instance-type" {
  description = "instance type"
  type = string
}

# azure docker node disk type
variable "docker-storage-account-type" {
  description = "storage account type"
  type = string
}

# azure docker node user
variable "docker-node-user" {
  description = "docker user"
  type = string
}

# azure ssh public key
variable "docker-pub-key" {
  description = "public key on terraform machine"
  type = string
}

# azure docker node image reference
# (corresponds with custom-data.tpl)
variable "src_img_ref_docker" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

# source ip access control including subnet mask
variable "src_ip_ctrl" {
  description = "source ip access control"
  type = string
}
