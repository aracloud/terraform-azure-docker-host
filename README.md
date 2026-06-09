# Docker Host deployment in Azure

## Overview
Simply deploy a docker host in Azure

## Prerequisites

Before using this Terraform project, ensure you have the following:

- **Terraform CLI** installed on your machine
- An **Azure account** (CLI "az login") to create **subnets**, **security groups** etc.
- SSH public key for Docker Host VM (adminuser) authentication 

---

```
project-directory/
├── azure.tf
├── custom-data.tpl
├── ext.tf
├── LICENSE
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars.example
└── vars.tf
```

---

## Configuration Steps

### 1. Clone the Repository

```bash
git clone <repository_url>
cd <repository_name>
```

### 2. Update Variables

#### Modify `terraform.tfvars`
```bash
cp terraform.tfvars.example terraform.tfvars
```
Update the values in `terraform.tfvars` to match your deployment needs.

Here are some key variables to configure:

- **Planet wide Variables:**
  ```hcl
  prefix = "your-prefix"
  ```

- **Azure wide Variables:**
  ```hcl
  azure-location = "westus"
  tag_owner = "your-email"
  src_ip_ctrl = "your_source_ip/32 or set * for ANY access"
  docker-pub-key = "your-machines-ssh-public-key"
  ```

### 3. Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply
```
