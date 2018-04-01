data "template_file" "readme" {
  template = <<EOF
# Docker Cluster
This stack provisions the ${aws_ecs_cluster.main.name} docker cluster in ECS.

## CLUSTER ECS HOSTS
Each host in the docker cluster is provisioned using auto-scaling groups. Some key notes about these hosts:

| Name | ${aws_autoscaling_group.ecs.name} |
| AMI | ${aws_launch_configuration.ecs.image_id} |
| Size | ${aws_launch_configuration.ecs.instance_type} |
| Key | ${aws_launch_configuration.ecs.key_name} |
| IAM Role | ${aws_launch_configuration.ecs.iam_instance_profile} |
| Max Cluster Size | ${aws_autoscaling_group.ecs.max_size} |
| Min Cluster Size | ${aws_autoscaling_group.ecs.min_size} |

EOF
}

output "readme" {
  value = "${data.template_file.readme.rendered}"
}
