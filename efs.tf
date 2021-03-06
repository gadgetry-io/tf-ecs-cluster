resource "aws_efs_file_system" "main" {
  creation_token                  = "${var.cluster_name}-docker-storage"
  encrypted                       = true
  kms_key_id                      = "${var.kms_key_id}"
  throughput_mode                 = "${var.efs_throughput == "0" ? "bursting" : "provisioned"}"
  provisioned_throughput_in_mibps = "${var.efs_throughput}"

  tags {
    Name        = "${var.cluster_name} Docker Storage"
    Environment = "${terraform.workspace}"
    Stack       = "ecs-cluster"
  }
}

resource "aws_efs_mount_target" "main" {
  count           = "${length(var.private_subnets)}"
  file_system_id  = "${aws_efs_file_system.main.id}"
  subnet_id       = "${element(var.private_subnets,count.index)}"
  security_groups = ["${var.private_security_group}"]
}
