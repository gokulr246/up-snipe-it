
resource "azurerm_resource_group" "snipe-it" {
  name     = "snipe-it"
  location = "eastus"
}


resource "azurerm_virtual_network" "snipe-it" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.snipe-it.name
  location            = azurerm_resource_group.snipe-it.location
  address_space       = ["10.0.0.0/16"]

}


resource "azurerm_subnet" "snipe-it" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.snipe-it.name
  virtual_network_name = azurerm_virtual_network.snipe-it.name
  address_prefixes     = ["10.0.1.0/24"]
}



resource "azurerm_public_ip" "snipe-it" {
  name                = "public_ip"
  location            = azurerm_resource_group.snipe-it.location
  resource_group_name = azurerm_resource_group.snipe-it.name
  allocation_method   = "Static"

}

data "azurerm_public_ip" "vm_public_ip" {
  name                = azurerm_public_ip.snipe-it.name
  resource_group_name = azurerm_resource_group.snipe-it.name
}



resource "azurerm_network_security_group" "snipe-it" {
  name                = "sec_gro"
  location            = azurerm_resource_group.snipe-it.location
  resource_group_name = azurerm_resource_group.snipe-it.name


  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # security_rule {
  #   name                    = "allow-ports-10000-10050"
  #   protocol                = "Tcp"
  #   destination_port_ranges = ["10000-10050"]
  #   access                  = "Allow"
  #   priority                = 200
  #   direction               = "Inbound"
  # }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "snipe-it" {
  name                = "nic"
  location            = azurerm_resource_group.snipe-it.location
  resource_group_name = azurerm_resource_group.snipe-it.name


  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.snipe-it.id
    public_ip_address_id          = azurerm_public_ip.snipe-it.id
  }
}

resource "azurerm_network_interface_security_group_association" "snipe-it" {
  network_interface_id      = azurerm_network_interface.snipe-it.id
  network_security_group_id = azurerm_network_security_group.snipe-it.id
}

resource "azurerm_linux_virtual_machine" "snipe-it" {
  name                = "snipe-it-machine"
  resource_group_name = azurerm_resource_group.snipe-it.name
  location            = azurerm_resource_group.snipe-it.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  depends_on          = [azurerm_public_ip.snipe-it]
  custom_data         = base64encode(local.data_inputs)

  network_interface_ids = [
    azurerm_network_interface.snipe-it.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("demo.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  # provisioner "remote-exec" {
  #   script = "test.sh"
  #   connection {
  #     host = azurerm_linux_virtual_machine.snipe-it.public_ip_address
  #     user = "adminuser"

  #   }
  # }

}

locals {
  data_inputs = <<-EOT
    #!/bin/bash

    # Step 1: Clone the Snipe-IT repository
    git clone https://github.com/snipe/snipe-it

    # Step 2: Change directory to the Snipe-IT folder
    cd snipe-it

    # Step 3: Run the install.sh script
    ./install.sh <<EOF
    ${data.azurerm_public_ip.vm_public_ip.ip_address}
    y
    n
    EOF
  EOT
}
