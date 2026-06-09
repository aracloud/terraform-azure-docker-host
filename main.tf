# make sure create unambiguous object definition for xc smsv2 site
# in this case for azure linux host only!!!
resource "random_id" "xc-mcn-random-id" {
  byte_length = 2
}


####################################
# azure resource definitions

resource "azurerm_resource_group" "azure_rg" {
  name     = "${var.prefix}-rg-${random_id.xc-mcn-random-id.hex}"
  location = "${var.azure-location}"
  tags = {
    source = var.tag_source_git
    owner  = var.tag_owner
    host  = local.hostname
  }

}

resource "azurerm_virtual_network" "azure_vn" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}

resource "azurerm_subnet" "azure_sn" {
  name                 = "${var.prefix}-sn-internal"
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "azure_pip_dkr" {
  name                = "${var.prefix}-pip-dkr"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "azure_nic_dkr" {
  name                = "${var.prefix}-nic-dkr"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.azure_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_pip_dkr.id
  }
}

resource "azurerm_network_security_group" "azure_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.src_ip_ctrl
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-All"
    priority                   = 1101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1024-65535"
    source_address_prefix      = var.src_ip_ctrl
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.src_ip_ctrl
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "azure_nisga_dkr" {
  network_interface_id    = azurerm_network_interface.azure_nic_dkr.id
  network_security_group_id = azurerm_network_security_group.azure_nsg.id
}

# azure docker host running workloads
resource "azurerm_linux_virtual_machine" "azure_dkr" {
  depends_on          = [azurerm_network_interface_security_group_association.azure_nisga_dkr]
  name                = "${var.prefix}-dkr-node"
  resource_group_name = azurerm_resource_group.azure_rg.name
  location            = azurerm_resource_group.azure_rg.location
  size                = var.docker-instance-type
  admin_username      = var.docker-node-user

  network_interface_ids = [
    azurerm_network_interface.azure_nic_dkr.id,
  ]

  admin_ssh_key {
    username   = var.docker-node-user
    public_key = file("${var.docker-pub-key}")
  }

  os_disk {
    name                 = "${var.prefix}-dkr-node-disk"
    caching              = "ReadWrite"
    storage_account_type = var.docker-storage-account-type
  }

  source_image_reference {
    publisher = var.src_img_ref_docker.publisher
    offer     = var.src_img_ref_docker.offer
    sku       = var.src_img_ref_docker.sku
    version   = var.src_img_ref_docker.version
  }

  custom_data = filebase64("${path.module}/custom-data.tpl")
}
