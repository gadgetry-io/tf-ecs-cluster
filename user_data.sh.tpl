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
echo ECS_ENGINE_AUTH_TYPE=docker >> /etc/ecs/ecs.config
echo 'ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"username":"${dockerhub_username}","password":"${dockerhub_password}"}}' >> /etc/ecs/ecs.config

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

${additional_user_data}

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/cloud-boothook; charset="us-ascii"

#cloud-boothook

PATH=$PATH:/usr/local/bin

yum update -y

yum install -y nfs-utils >/dev/null

# Get region of EC2 from instance metadata
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
DIR_SRC=$EC2_AVAIL_ZONE.${efs_id}.efs.$EC2_REGION.amazonaws.com
DIR_TGT=/mnt/efs

# Mount EFS
mkdir -p $DIR_TGT
mount -t nfs4 $DIR_SRC:/ $DIR_TGT

# Backup fstab
cp -p /etc/fstab /etc/fstab.back-$(date +%F)

# Append line to fstab
echo -e "$DIR_SRC:/ \t\t $DIR_TGT \t\t nfs \t\t defaults \t\t 0 \t\t 0" | tee -a /etc/fstab

--===============BOUNDARY==--