 
resource "azurerm_public_ip" "example" {
  name                = var.public-ip-name
  location            = "East US 2"
  resource_group_name = var.rg-name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "example" {
  name                = var.nic-name
  location            = azurerm_resource_group.example.location
  resource_group_name = var.rg-name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.example[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}


resource "tls_private_key" "example" {
  algorithm = "RSA"
}

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "example" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "example" {
  name         = var.key_vault_secret_name
  value        = tls_private_key.example.private_key_pem
  key_vault_id = azurerm_key_vault.example.id
}

data "azurerm_image" "search" {
  name                = var.image_name
  resource_group_name = var.rg-name
}

resource "azurerm_virtual_machine" "example" {
  # for_each              = each.servers
  name                  = var.vm-name
  location              = azurerm_resource_group.example.location
  resource_group_name   = var.rg-name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.test? "Standard_B2s" : "Standard_DS1_v2"

  # admin_ssh_key {
  #   username   = "ashok"                  
  #   public_key = file("$(path.module)/terraform-azure.pub")
  # }

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  # storage_image_reference {
  #   publisher = "OpenLogic"
  #   offer     = "CentOS"
  #   sku       = "7.7"
  #   version   = "latest"
  # }

  storage_os_disk {
    name              = "testingdisk-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 30
  }

 os_profile {
    computer_name  = var.vm-name
    admin_username = "adminuser" 
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = tls_private_key.example.public_key_openssh
    }
  }


  tags = merge(var.tags,var.vm_tags,
  {"Name" = var.vm-name})
  
  
  
}

resource "azurerm_network_security_group" "example" {
  name                = var.nsg-name
  location            = azurerm_resource_group.example.location
  resource_group_name = var.rg-name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags,var.nsg_tags)
}


resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}