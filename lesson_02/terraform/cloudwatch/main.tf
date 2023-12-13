/*
    Check EC2 CPU usage
*/

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "[${element(var.ec2_instance_names, 0)}] cpu_usage_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric checks if EC2 CPU usage exceeds 80 percent."
  dimensions = {
    InstanceId = element(var.ec2_instance_ids, 0) # Replace with your instance ID
  }
}
