resource "aws_cloudfront_distribution" "wordpress_distribution" {
  origin {
    domain_name = module.alb.dns_name
    origin_id   = "wordpress-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Use HTTP (not HTTPS) between CloudFront and ALB
      origin_ssl_protocols   = ["TLSv1.2"] # Not needed since we're using HTTP
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "wordpress-origin"


    cache_policy_id          = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    viewer_protocol_policy = "allow-all"

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Use the default CloudFront SSL certificate (for HTTPS only)
  }
}

# sed -i "s/Servername .*/Servername internal-albjardinalia-1790569059.us-east-1.elb.amazonaws.com/" /etc/httpd/conf.d/ssl.conf 
# sudo sed -i 's/^ *ServerName .*/    ServerName new_domain_or_IP/' /etc/httpd/conf.d/ssl.conf
