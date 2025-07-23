resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Name        = "${var.cluster_name}-zone"
  }
}

# Create a record for the API server
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.api_endpoint
    zone_id                = var.api_endpoint_zone_id
    evaluate_target_health = true
  }
}

# Create a wildcard record for applications
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.nlb_hostname
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}