# Terraform Azure VM

Provisions a Linux virtual machine on Microsoft Azure using Terraform.

## Resources Created

| Resource | Name |
|---|---|
| Resource Group | `terraform-rg` |
| Virtual Network | `terraform-vnet` (10.0.0.0/16) |
| Subnet | `terraform-subnet` (10.0.1.0/24) |
| Public IP | `terraform-pip` (Static, Standard) |
| Network Security Group | `terraform-nsg` |
| Network Interface | `terraform-nic` |
| Linux Virtual Machine | `terraform-vm` (Ubuntu 22.04 LTS) |

## NSG Rules

| Rule | Port | Source |
|---|---|---|
| allow-ssh | 22 | Specific IP only |
| allow-http | 80 | Any |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in

```bash
az login
```

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

## Outputs

| Output | Description |
|---|---|
| `public_ip` | Public IP address of the VM |
| `private_ip` | Private IP address of the VM |
| `vm_name` | Name of the virtual machine |
| `resource_group` | Name of the resource group |

## Connect to VM

```bash
ssh azureuser@<public_ip>
```
