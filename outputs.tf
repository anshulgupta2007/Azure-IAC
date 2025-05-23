output "webapp_url" {
  description = "Web App URL"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}
