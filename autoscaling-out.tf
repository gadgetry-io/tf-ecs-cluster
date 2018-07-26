# Scaling out the ECS Cluster based on Memory Reservation
resource "aws_autoscaling_policy" "scale_out_ecs" {
  name                   = "${aws_autoscaling_group.ecs.name}-scale-out"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_out_ecs" {
  alarm_name          = "${upper(terraform.workspace)} Scale Out ECS Cluster"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This scales out the ${terraform.workspace} ECS Cluster when memory usage is above 80%"
  alarm_actions       = ["${aws_autoscaling_policy.scale_out_ecs.arn}"]

  dimensions {
    ClusterName = "${terraform.workspace}"
  }
}
