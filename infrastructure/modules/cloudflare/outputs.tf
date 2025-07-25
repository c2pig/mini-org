output "zone_id" {
  description = "Cloudflare zone ID"
  value       = data.cloudflare_zone.main.id
}

output "zone_name" {
  description = "Cloudflare zone name"
  value       = data.cloudflare_zone.main.name
}

output "api_record_id" {
  description = "API DNS record ID"
  value       = cloudflare_record.api.id
}

output "app_record_id" {
  description = "App DNS record ID"
  value       = cloudflare_record.app.id
}