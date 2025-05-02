Create a terraform config to create a azure virtual machine. 


Move the resource "azurerm_network_interface" from parent module to child module 

Run terraform plan, the output must be No changes "


**Answer**:
terraform mv aws_network_interface.app_server_nic module.app_server_nic.aws_network_interface.app_server_nic
