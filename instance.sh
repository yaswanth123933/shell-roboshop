#!/bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-04ef25cbf88a4d0ab"

for instance in $@; do
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

  #  Wait until instance is running
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID

  #  Get IP based on instance name
  if [ "$instance" = "frontend" ]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)
  fi

  echo "$instance: $IP"
done
