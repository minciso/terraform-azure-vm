terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "terraform-rg"
  location = "Central India"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "terraform-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "terraform-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "158.62.20.52/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "terraform-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "terraform-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "terraform-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2als_v6"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssword1234!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo hostnamectl set-hostname dmi-websrv
    sudo adduser --gecos "" michael_inciso
    echo "michael_inciso:Admin.123" | sudo chpasswd
    sudo usermod -aG sudo michael_inciso
    sudo timedatectl set-timezone Asia/Manila
    sudo apt update && sudo apt upgrade -y
  EOF
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}
