resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "JardinaliaDashboard"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.autoscaling_group_name],
            [".", "MemoryUtilization", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 Resource Utilization"
        }
      },
      # RDS Metrics
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.rds.db_instance_identifier],
            [".", "FreeStorageSpace", ".", "."],
            [".", "DatabaseConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "RDS Metrics"
        }
      },
      # Redis Metrics
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", module.elasticache.cluster_cache_nodes[0].id],
            [".", "FreeableMemory", ".", "."],
            [".", "CurrConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Redis Metrics"
        }
      },
      # ALB Metrics
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.alb.arn],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "ALB Metrics"
        }
      },
      # EFS Metrics
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EFS", "StorageBytes", "FileSystemId", aws_efs_file_system.jardinalia_efs.id],
            [".", "ClientConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EFS Metrics"
        }
      }
    ]
  })
}