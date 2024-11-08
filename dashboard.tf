resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "metricas-jardinalia"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "rds-jardinalia"],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "rds-jardinalia"],
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "rds-jardinalia"],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "rds-jardinalia"],
            ["AWS/RDS", "DiskQueueDepth", "DBInstanceIdentifier", "rds-jardinalia"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Metricas de RDS"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Utilizacion de CPU en instancias"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "StatusCheckFailed_Instance", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "StatusCheckFailed_System", "AutoScalingGroupName", module.asg.autoscaling_group_name]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Salud de instancias"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "NetworkPacketsIn", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "NetworkPacketsOut", "AutoScalingGroupName", module.asg.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Trafico a instancias"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "EBSReadOps", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "EBSWriteOps", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "EBSReadBytes", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "EBSWriteBytes", "AutoScalingGroupName", module.asg.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Metricas de EBS de instancias"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", "redisjardinalia"],
            ["AWS/ElastiCache", "GetLatency", "CacheClusterId", "redisjardinalia"],
            ["AWS/ElastiCache", "SetLatency", "CacheClusterId", "redisjardinalia"],
            ["AWS/ElastiCache", "Evictions", "CacheClusterId", "redisjardinalia"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Metricas de cache REDIS"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "GetMisses", "CacheClusterId", "memcached-jardinalia"],
            ["AWS/ElastiCache", "GetHits", "CacheClusterId", "memcached-jardinalia"],
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", "memcached-jardinalia"],
            ["AWS/ElastiCache", "Evictions", "CacheClusterId", "memcached-jardinalia"]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Metricas de cache MEMCACHED"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "StatusCheckFailed_Instance", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            ["AWS/EC2", "StatusCheckFailed_System", "AutoScalingGroupName", module.asg.autoscaling_group_name]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Instance Health Status"
        }
      }
    ]
  })
}