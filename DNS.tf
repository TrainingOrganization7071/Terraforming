/*
# DNS Zone 

resource "random_string" "azurerm_dns_zone_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_dns_zone" "dns-public" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  #name                = "apinostrada.com"
  name                =(
    var.dns_zone_name != null ?
    var.dns_zone_name :
    "www.${random_string.azurerm_dns_zone_name.result}.azurequickstart.org"
  )
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "record" {
  name                = "www"
  resource_group_name = azurerm_resource_group.rg.name
  zone_name           = azurerm_dns_zone.dns-public.name
  ttl                 = var.dns_ttl
  records             = var.dns_records
}
*/