/*
# Output the Web App Name
output "web_app_name" {
  description = "The name of the Linux Web App"
  value       = azurerm_linux_web_app.front_web_app.name
}

# Output the Web App URL
output "web_app_url" {
  description = "The URL of the Linux Web App"
  value       = azurerm_linux_web_app.front_web_app.default_hostname
}
*/



output "dns_zone_name" {
  value = azurerm_dns_zone.dns-public.name
}

output "name_servers" {
  value = azurerm_dns_zone.dns-public.name_servers
}















