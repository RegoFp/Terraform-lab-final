resource "aws_route53_zone" "private" {
  name = "backend.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name  = "R53_Jardinalia"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.backend.com"
  type    = "CNAME"
  records = [split(":", module.rds.db_instance_endpoint)[0]]
  ttl     = 60
}



resource "aws_route53_record" "redis" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "redis.backend.com"
  type    = "CNAME"
  records = [module.elasticache.cluster_cache_nodes[0].address]
  ttl     = 60
}

resource "aws_route53_record" "memcached" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "memcached.backend.com"
  type    = "CNAME"
  records = [module.memcached.cluster_cache_nodes[0].address]
  ttl     = 60
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "alb.backend.com"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
