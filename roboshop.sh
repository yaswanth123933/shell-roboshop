#!/bim/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-04ef25cbf88a4d0ab"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #get private ip
    if [ $instance != "frontend" ]; then
        Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0]. 
        PrivateIpAddress' --output text)
    else
        
        Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].
        PublicIpAddress' --output text)
    fi

    echo "$instance:$IP"
done
    


