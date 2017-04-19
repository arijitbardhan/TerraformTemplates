# Configure the AWS Provider
provider "aws" {
	access_key = "${var.access_key}"
  	secret_key = "${var.secret_key}"
  	region     = "us-east-1"
}

# Creating an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id	= "${var.subscription_id}"
	client_id	= "${var.client_id}"
	client_secret	= "${var.client_secret}"
	tenant_id	= "${var.tenant_id}"
}

# Create a Resource Group
resource "azurerm_resource_group" "rg1" {
	name		= "Simple-Linux-VM"
	location	= "Southeast Asia"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet1" {
	name		= "SimpleVnet"
	location	= "Southeast Asia"
	address_space	= ["10.0.0.0/16"]
	resource_group_name = "${azurerm_resource_group.rg1.name}"
}

#Subnet inside a Vnet
resource "azurerm_subnet" "subnet1" {
	name		= "Subnet-1"
	address_prefix	= "10.0.1.0/24"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
	network_security_group_id = "${azurerm_network_security_group.nsg1.id}"
}

# Create a public IP
resource "azurerm_public_ip" "publicIP" {
	name		= "VMPublicIP"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	public_ip_address_allocation = "dynamic"
	domain_name_label = "demodnsterraform"
}

# Create a Network Interface for VM
resource "azurerm_network_interface" "nic1" {
	name		= "NIC1"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	ip_configuration {
		name		= "ipconfigfornic"
		subnet_id	= "${azurerm_subnet.subnet1.id}"
		private_ip_address_allocation = "dynamic"
	}
}

# Create a NSG for Subnet1
resource "azurerm_network_security_group" "nsg1" {
        name            = "NSG1"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"

        security_rule {
                name = "Allow_web"
                priority = 100
                direction = "Inbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "*"
                source_address_prefix = "*"
                destination_address_prefix = "*"
        }
}

# Create a storage account for VM
resource "azurerm_storage_account" "sa1" {
	name		= "terraformsademo"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	account_type	= "Standard_LRS"
}

# Create a container for storage account
resource "azurerm_storage_container" "container" {
	name		= "vhds"
	storage_account_name	= "${azurerm_storage_account.sa1.name}"
	resource_group_name	= "${azurerm_resource_group.rg1.name}"
	container_access_type	= "private"
}
# Create a VM
resource "azurerm_virtual_machine" "vm1" {
        name            = "UbuntuVM"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        vm_size         = "Basic_A0"
        network_interface_ids = ["${azurerm_network_interface.nic1.id}"]
        storage_image_reference {
                publisher = "Canonical"
                offer   = "UbuntuServer"
                sku     = "14.04.2-LTS"
                version = "latest"
        }
        storage_os_disk {
                name    = "myosdisk1"
                vhd_uri = "${azurerm_storage_account.sa1.primary_blob_endpoint}${azurerm_storage_container.container.name}/myosdisk1.vhd"
                caching = "ReadWrite"
                create_option = "FromImage"
        }
        os_profile {
                computer_name   = "nginx"
                admin_username  = "azureUser"
                admin_password  = "Password@123"
        }
        os_profile_linux_config {
                disable_password_authentication = false
        }
}

