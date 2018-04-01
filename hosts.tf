resource "aws_launch_configuration" "ecs" {
  name_prefix          = "${var.cluster_name}-ecs-"
  image_id             = "${var.ecs_host_ami}"
  instance_type        = "${var.ecs_host_size}"
  key_name             = "${var.provisioner_key_name}"
  security_groups      = ["${var.private_security_group}"]
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_host.name}"

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 128
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${var.cluster_name}-ecs"
  availability_zones   = ["${keys(var.vpc_private_subnets)}"]
  min_size             = "${var.ecs_autoscale_min}"
  max_size             = "${var.ecs_autoscale_max}"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier  = ["${var.private_subnets}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-ecs-host"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${lower(terraform.workspace)}"
      propagate_at_launch = true
    },
    {
      key                 = "Stack"
      value               = "ecs_cluster"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.main.name}"
    env         = "${terraform.workspace}"
    efs_id      = "${aws_efs_file_system.main.id}"
  }
}
