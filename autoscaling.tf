resource "aws_autoscaling_policy" "upscale_ecs" {
  name                   = "upscale-${aws_autoscaling_group.ecs.name}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
}

resource "aws_autoscaling_policy" "downscale_ecs" {
  name                   = "downscale-${aws_autoscaling_group.ecs.name}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"
}
