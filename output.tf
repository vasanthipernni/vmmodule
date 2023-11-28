output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "image_id" {
  value = data.azurerm_image.search.id
}