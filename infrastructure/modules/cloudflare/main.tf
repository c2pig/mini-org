terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Data source to get zone information
data "cloudflare_zone" "main" {
  name = var.zone_name
}

# DNS Records
resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.main.id
  name    = "api"
  value   = var.api_endpoint
  type    = "CNAME"
  proxied = true
  
  comment = "API endpoint for ${var.environment}"
}

resource "cloudflare_record" "app" {
  zone_id = data.cloudflare_zone.main.id
  name    = "app"
  value   = var.app_endpoint
  type    = "CNAME"
  proxied = true
  
  comment = "App endpoint for ${var.environment}"
}

# WAF Rules
resource "cloudflare_ruleset" "waf" {
  zone_id = data.cloudflare_zone.main.id
  name    = "${var.environment}-waf-rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action = "block"
    expression = "(http.request.uri.path contains \"/admin\" and ip.geoip.country ne \"US\")"
    description = "Block admin access from outside US"
    enabled = true
  }

  rules {
    action = "challenge"
    expression = "(cf.threat_score gt 10)"
    description = "Challenge suspicious requests"
    enabled = true
  }
}

# Rate Limiting
resource "cloudflare_rate_limit" "api" {
  zone_id = data.cloudflare_zone.main.id
  
  threshold = 1000
  period    = 60
  
  match {
    request {
      url_pattern = "${var.zone_name}/api/*"
      schemes     = ["HTTPS"]
      methods     = ["GET", "POST", "PUT", "DELETE"]
    }
    response {
      statuses = [200, 201, 202, 204, 301, 302, 307, 308]
    }
  }
  
  action {
    mode    = "simulate"
    timeout = 86400
    response {
      content_type = "application/json"
      body = jsonencode({
        error = "Rate limit exceeded"
      })
    }
  }
  
  correlate {
    by = "nat"
  }
  
  disabled = false
  description = "Rate limit API endpoints"
}

# Page Rules for caching
resource "cloudflare_page_rule" "api_cache" {
  zone_id = data.cloudflare_zone.main.id
  target  = "api.${var.zone_name}/v1/static/*"
  
  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 86400
  }
}

resource "cloudflare_page_rule" "assets_cache" {
  zone_id = data.cloudflare_zone.main.id
  target  = "*.${var.zone_name}/assets/*"
  
  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 604800
    browser_cache_ttl = 86400
  }
}

# SSL/TLS Configuration
resource "cloudflare_zone_settings_override" "ssl" {
  zone_id = data.cloudflare_zone.main.id
  
  settings {
    ssl = "strict"
    always_use_https = "on"
    min_tls_version = "1.2"
    opportunistic_encryption = "on"
    tls_1_3 = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl = "on"
    
    # Security settings
    security_level = "medium"
    challenge_ttl = 1800
    browser_check = "on"
    
    # Performance settings
    brotli = "on"
    minify {
      css = "on"
      js = "on"
      html = "on"
    }
    
    # Caching
    browser_cache_ttl = 14400
    cache_level = "aggressive"
    
    # IPv6
    ipv6 = "on"
    
    # HTTP/2
    http2 = "on"
    http3 = "on"
  }
}