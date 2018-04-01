Content-Type: multipart/mixed; boundary="===============BOUNDARY=="
MIME-Version: 1.0

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -e

# Configure ECS
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

PATH=$PATH:/usr/local/bin

# Configure AWS Monitoring
# Source http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/mon-scripts.html
yum install perl-Digest-SHA perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https unzip -y
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm CloudWatchMonitoringScripts-1.2.1.zip

crontab -l | { cat; echo "* * * * * /aws-scripts-mon/mon-put-instance-data.pl --mem-util --auto-scaling=only --from-cron"; } | crontab -

echo "Grabbing Meta Data..."
PRIVATE_IP=$(curl -n http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
yum install -y unzip >/dev/null

# Fetching AWS CLI
cd /tmp
curl -n "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws
rm -rf ./awscli-bundle awscli-bundle.zip

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/cloud-boothook; charset="us-ascii"

#cloud-boothook

PATH=$PATH:/usr/local/bin

yum update -y

--===============BOUNDARY==--