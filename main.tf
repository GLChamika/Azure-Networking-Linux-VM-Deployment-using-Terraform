terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "tfdemo"  # Change this prefix as needed
}

resource "azurerm_resource_group" "rg-tfdemo" {  
  name     = "${var.prefix}-resources"
  location = "eastasia"  # Change location as needed
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-tfdemo.location
  resource_group_name = azurerm_resource_group.rg-tfdemo.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg-tfdemo.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-publicip"
  location            = azurerm_resource_group.rg-tfdemo.location
  resource_group_name = azurerm_resource_group.rg-tfdemo.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg-tfdemo.location
  resource_group_name = azurerm_resource_group.rg-tfdemo.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg-tfdemo.location
  resource_group_name = azurerm_resource_group.rg-tfdemo.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"   # Allow from any source port
  destination_port_range      = "22"
  source_address_prefix       = "*"   # Change to "your ip" for better security (Ex: your_ip/32)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-tfdemo.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

# Associate NSG to NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Create the stored SSH public key (use RSA key)
resource "azurerm_ssh_public_key" "ssh-pubkey" {
  name                = "${var.prefix}-sshkey"
  resource_group_name = azurerm_resource_group.rg-tfdemo.name
  location            = azurerm_resource_group.rg-tfdemo.location
  public_key = file("C:/Users/Lahiru Galhena/.ssh/id_rsa.pub")  # Full path to your RSA pub key
}

# Data source to fetch the key content
data "azurerm_ssh_public_key" "ssh-pubkey" {
  name                = azurerm_ssh_public_key.ssh-pubkey.name
  resource_group_name = azurerm_resource_group.rg-tfdemo.name
}

# Modern azurerm_linux_virtual_machine instead of deprecated azurerm_virtual_machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg-tfdemo.location
  resource_group_name   = azurerm_resource_group.rg-tfdemo.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_B2ats_v2"  # Change VM size as needed

  admin_username                  = "lahiru"  # Change as needed
  disable_password_authentication = true   # Enforce key-only auth

  admin_ssh_key {
    username   = "lahiru"  # Change as needed
    public_key = data.azurerm_ssh_public_key.ssh-pubkey.public_key  # Use fetched RSA key
  }

  os_disk {
    name                 = "myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "staging"
  }
}