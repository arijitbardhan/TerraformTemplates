# Configure the Microsoft Azure Provider
provider "azurerm" {
	subscription_id = "${var.subscription_id}"
	client_id	= "${var.client_id}"
	client_secret	= "${var.client_secret}"
	tenant_id	= "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "rg1" {
	name 		= "devops-pipeline-terraform"
	location 	= "Southeast Asia"
}

# Create a virtual network
resource "azurerm_virtual_network" "demoVnet1"{
	name 		= "DevopsPipelineVNet"
	location 	= "Southeast Asia"
	address_space 	= ["10.0.0.0/16"]
	resource_group_name = "${azurerm_resource_group.rg1.name}"
}

# Web Subnet
resource "azurerm_subnet" "subnet1" {
	name 		= "WebSubnet"
	address_prefix 	= "10.0.1.0/24"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	virtual_network_name = "${azurerm_virtual_network.demoVnet1.name}"
	network_security_group_id = "${azurerm_network_security_group.nsg1.id}"
}

#App Subnet
resource "azurerm_subnet" "subnet2" {
	name 		= "AppSubnet"
	address_prefix 	= "10.0.2.0/24"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
        virtual_network_name = "${azurerm_virtual_network.demoVnet1.name}"
	network_security_group_id = "${azurerm_network_security_group.nsg2.id}"
}

#DB Subnet
resource "azurerm_subnet" "subnet3" {
	name 		= "DbSubnet"
	address_prefix 	= "10.0.3.0/24"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
        virtual_network_name = "${azurerm_virtual_network.demoVnet1.name}"
	network_security_group_id = "${azurerm_network_security_group.nsg3.id}"
}

# Create Public IP for Nginx
resource "azurerm_public_ip" "publicIP" {
	name 		= "NginxPublicIP"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	public_ip_address_allocation = "dynamic"
	domain_name_label = "nginx2312"
}

# Create Network Interface for Nginx VM
resource "azurerm_network_interface" "nic1" { 
	name 		= "NginxNIC"
	location 	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	ip_configuration {
		name	= "nginxnicipconfig"
		subnet_id = "${azurerm_subnet.subnet1.id}"
		private_ip_address_allocation = "static"
		private_ip_address = "10.0.1.19"
		public_ip_address_id = "${azurerm_public_ip.publicIP.id}"
	}
}

# Create a Network Interface for Jenkins
resource "azurerm_network_interface" "nic2" {
	name		= "JenkinsNIC"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	ip_configuration {
		name	= "jenkinsnicipconfig"
		subnet_id = "${azurerm_subnet.subnet2.id}"
		private_ip_address_allocation = "static"
		private_ip_address = "10.0.2.20"
	}
}

# Create a Network Interface for Sonar
resource "azurerm_network_interface" "nic3" {
        name            = "SonarNIC"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        ip_configuration {
                name    = "sonarnicipconfig"
                subnet_id = "${azurerm_subnet.subnet2.id}"
                private_ip_address_allocation = "static"
                private_ip_address = "10.0.2.21"
        }
}

# Create a Network Interface for MySql
resource "azurerm_network_interface" "nic4" {
        name            = "MySqlNIC"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        ip_configuration {
                name    = "mysqlnicipconfig"
                subnet_id = "${azurerm_subnet.subnet3.id}"
                private_ip_address_allocation = "static"
                private_ip_address = "10.0.3.31"
        }
}

# Create a NSG for WebSubnet
resource "azurerm_network_security_group" "nsg1" {
	name		= "WebSubnetNSG"
	location	= "Southeast Asia"
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

# Create a NSG for AppSubnet
resource "azurerm_network_security_group" "nsg2" {
        name            = "AppSubnetNSG"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"

        security_rule {
                name = "Allow_jenkins"
                priority = 100
                direction = "Inbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "8080"
                source_address_prefix = "10.0.1.0/24"
                destination_address_prefix = "10.0.2.0/24"
        }

	security_rule {
		name = "Allow_Sonar"
		priority = 101
		direction = "Inbound"
		access = "Allow"
		protocol = "Tcp"
		source_port_range = "*"
		destination_port_range = "9000"
		source_address_prefix = "10.0.1.0/24"
		destination_address_prefix = "10.0.2.0/24"
	}
	
	security_rule {
                name = "Allow_SSH"
                priority = 102
                direction = "Inbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "22"
                source_address_prefix = "10.0.1.0/24"
                destination_address_prefix = "10.0.2.0/24"
        }

	security_rule {
                name = "Allow_MySql"
                priority = 103
                direction = "Outbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "3306"
                source_address_prefix = "10.0.2.0/24"
                destination_address_prefix = "10.0.3.0/24"
        }
}

# Create a NSG for DbSubnet
resource "azurerm_network_security_group" "nsg3" {
        name            = "DBSubnetNSG"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"

        security_rule {
                name = "Allow_mysql"
                priority = 100
                direction = "Inbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "3306"
                source_address_prefix = "10.0.2.0/24"
                destination_address_prefix = "10.0.3.0/24"
        }

	 security_rule {
                name = "AllowSSH"
                priority = 101
                direction = "Inbound"
                access = "Allow"
                protocol = "Tcp"
                source_port_range = "*"
                destination_port_range = "22"
                source_address_prefix = "10.0.1.0/24"
                destination_address_prefix = "10.0.3.0/24"
        }

}

# Create a storage account for Nginx
resource "azurerm_storage_account" "sa1" {
	name		= "nginxsa2012"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	account_type	= "Standard_LRS"
}

# Create a storage account for Jenkins
resource "azurerm_storage_account" "sa2" { 
	name		= "jenkinssa2612"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	account_type	= "Standard_LRS"
}

# Create a storage account for Sonar
resource "azurerm_storage_account" "sa3" {
	name		= "sonarsa2612"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	account_type	= "Standard_LRS"
}

# Create a storage account for MySql
resource "azurerm_storage_account" "sa4" {
	name		= "mysqlsa2612"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	account_type	= "Standard_LRS"
}

# Create a container for Nginx sa
resource "azurerm_storage_container" "container1" { 
	name		= "vhds"
	storage_account_name	= "${azurerm_storage_account.sa1.name}"
	resource_group_name 	= "${azurerm_resource_group.rg1.name}"
	container_access_type	= "private"
}

# Create a container for Jenkins sa
resource "azurerm_storage_container" "container2" {
        name            = "vhds"
        storage_account_name    = "${azurerm_storage_account.sa2.name}"
        resource_group_name     = "${azurerm_resource_group.rg1.name}"
        container_access_type   = "private"
}

# Create a container for Sonar sa
resource "azurerm_storage_container" "container3" {
        name            = "vhds"
        storage_account_name    = "${azurerm_storage_account.sa3.name}"
        resource_group_name     = "${azurerm_resource_group.rg1.name}"
        container_access_type   = "private"
}

# Create a container for MySql sa
resource "azurerm_storage_container" "container4" {
        name            = "vhds"
        storage_account_name    = "${azurerm_storage_account.sa4.name}"
        resource_group_name     = "${azurerm_resource_group.rg1.name}"
        container_access_type   = "private"
}

# Create a Nginx VM
resource "azurerm_virtual_machine" "vm1" {
	name		= "Nginx"
	location	= "Southeast Asia"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	vm_size		= "Basic_A0"
	network_interface_ids = ["${azurerm_network_interface.nic1.id}"]
	storage_image_reference {
		publisher = "Canonical"
		offer	= "UbuntuServer"
		sku	= "14.04.2-LTS"
		version = "latest"
	}
	storage_os_disk {
		name	= "myosdisk1"
		vhd_uri	= "${azurerm_storage_account.sa1.primary_blob_endpoint}${azurerm_storage_container.container1.name}/myosdisk1.vhd"
		caching = "ReadWrite"
		create_option = "FromImage"
	}
	os_profile {
		computer_name	= "nginx"
		admin_username	= "azureUser"
		admin_password	= "Password@123"
	}
	os_profile_linux_config {
		disable_password_authentication = false
	}
}

# Create a Jenkins VM
resource "azurerm_virtual_machine" "vm2" {
        name            = "Jenkins"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        vm_size         = "Basic_A0"
        network_interface_ids = ["${azurerm_network_interface.nic2.id}"]
        storage_image_reference {
                publisher = "Canonical"
                offer   = "UbuntuServer"
                sku     = "14.04.2-LTS"
                version = "latest"
        }
        storage_os_disk {
                name    = "myosdisk1"
                vhd_uri = "${azurerm_storage_account.sa2.primary_blob_endpoint}${azurerm_storage_container.container2.name}/myosdisk1.vhd"
                caching = "ReadWrite"
                create_option = "FromImage"
        }
        os_profile {
                computer_name   = "jenkins"
                admin_username  = "azureUser"
                admin_password  = "Password@123"
        }
        os_profile_linux_config {
                disable_password_authentication = false
        }
}

# Create a Sonar VM
resource "azurerm_virtual_machine" "vm3" {
        name            = "Sonar"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        vm_size         = "Basic_A0"
        network_interface_ids = ["${azurerm_network_interface.nic3.id}"]
        storage_image_reference {
                publisher = "Canonical"
                offer   = "UbuntuServer"
                sku     = "14.04.2-LTS"
                version = "latest"
        }
        storage_os_disk {
                name    = "myosdisk1"
                vhd_uri = "${azurerm_storage_account.sa3.primary_blob_endpoint}${azurerm_storage_container.container3.name}/myosdisk1.vhd"
                caching = "ReadWrite"
                create_option = "FromImage"
        }
        os_profile {
                computer_name   = "sonar"
                admin_username  = "azureUser"
                admin_password  = "Password@123"
        }
        os_profile_linux_config {
                disable_password_authentication = false
        }
}

# Create a MySql VM
resource "azurerm_virtual_machine" "vm4" {
        name            = "MySQL"
        location        = "Southeast Asia"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        vm_size         = "Basic_A0"
        network_interface_ids = ["${azurerm_network_interface.nic4.id}"]
        storage_image_reference {
                publisher = "Canonical"
                offer   = "UbuntuServer"
                sku     = "14.04.2-LTS"
                version = "latest"
        }
        storage_os_disk {
                name    = "myosdisk1"
                vhd_uri = "${azurerm_storage_account.sa4.primary_blob_endpoint}${azurerm_storage_container.container4.name}/myosdisk1.vhd"
                caching = "ReadWrite"
                create_option = "FromImage"
        }
        os_profile {
                computer_name   = "mysql"
                admin_username  = "azureUser"
                admin_password  = "Password@123"
        }
        os_profile_linux_config {
                disable_password_authentication = false
        }
}

# Script to install Nginx
resource "azurerm_virtual_machine_extension" "extn1" {
	name	= "install_nginx"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	virtual_machine_name = "${azurerm_virtual_machine.vm1.name}"
	publisher = "Microsoft.OSTCExtensions"
	type = "CustomScriptForLinux"
	type_handler_version = "1.2"
	location = "Southeast Asia"
	settings = <<SETTINGS
	{
		"fileUris" : [
			"https://raw.githubusercontent.com/arijitbardhan/MyShellScripts/master/Scripts/nginx-without-docker.sh"
		],
		"commandToExecute" : "sh nginx-without-docker.sh"
	}	
	SETTINGS
}

# Script to install Jenkins
resource "azurerm_virtual_machine_extension" "extn2" {
	name	= "install_jenkins"
	resource_group_name = "${azurerm_resource_group.rg1.name}"
	virtual_machine_name = "${azurerm_virtual_machine.vm2.name}"
	publisher = "Microsoft.OSTCExtensions"
	type = "CustomScriptForLinux"
        type_handler_version = "1.2"
        location = "Southeast Asia"
        settings = <<SETTINGS
        {
                "fileUris" : [
                        "https://raw.githubusercontent.com/arijitbardhan/MyShellScripts/master/Scripts/simple-java-jenkins.sh"
                ],
                "commandToExecute" : "sh simple-java-jenkins.sh"
        }
        SETTINGS
}

# Script to install Sonar
resource "azurerm_virtual_machine_extension" "extn3" {
        name    = "install_sonar"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        virtual_machine_name = "${azurerm_virtual_machine.vm3.name}"
        publisher = "Microsoft.OSTCExtensions"
        type = "CustomScriptForLinux"
        type_handler_version = "1.2"
        location = "Southeast Asia"
        settings = <<SETTINGS
        {
                "fileUris" : [
                        "https://raw.githubusercontent.com/arijitbardhan/MyShellScripts/master/Scripts/sonar-without-docker.sh"
                ],
                "commandToExecute" : "sh sonar-without-docker.sh"
        }
        SETTINGS
}

# Script to install MySql
resource "azurerm_virtual_machine_extension" "extn4" {
        name    = "install_mysql"
        resource_group_name = "${azurerm_resource_group.rg1.name}"
        virtual_machine_name = "${azurerm_virtual_machine.vm4.name}"
        publisher = "Microsoft.OSTCExtensions"
        type = "CustomScriptForLinux"
        type_handler_version = "1.2"
        location = "Southeast Asia"
        settings = <<SETTINGS
        {
                "fileUris" : [
                        "https://raw.githubusercontent.com/arijitbardhan/MyShellScripts/master/Scripts/install-mysql-standalone.sh"
                ],
                "commandToExecute" : "sh install-mysql-standalone.sh"
        }
        SETTINGS
}

