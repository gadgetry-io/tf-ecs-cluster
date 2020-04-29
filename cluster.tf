resource "aws_ecs_cluster" "main" {
  name               = "${var.cluster_name}"
  capacity_providers = ["FARGATE", "${aws_ecs_capacity_provider.main.name}"]
}

output "arn" {
  value = "${aws_ecs_cluster.main.id}"
}

resource "aws_ecs_capacity_provider" "main" {
  name = "${terraform.workspace}-default-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = "${aws_autoscaling_group.ecs.arn}"
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }

  lifecycle {
    ignore_changes        = ["auto_scaling_group_provider.managed_scaling.target_capacity"]
    create_before_destroy = true
  }
}
