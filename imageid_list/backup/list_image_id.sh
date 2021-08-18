#!/bin/bash
echo "-------------- Availble AWS regions ----------------"
aws ec2 describe-regions | jq -r .Regions[].RegionName
echo "----------------------------------------------------"


LOOKUP="Name=name,Values=*FortiGate-VM64-AWSONDEMAND*6.4.6*"
REGION=eu-north-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >list.txt
REGION=ap-south-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=eu-west-3; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=eu-west-2; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=eu-west-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ap-northeast-3; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ap-northeast-2; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ap-northeast-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=sa-east-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ca-central-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ap-southeast-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=ap-southeast-2; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=eu-central-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=us-east-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=us-east-2; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=us-west-1; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
REGION=us-west-2; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $REGION| jq -r .Images[].ImageId) >>list.txt
cat list.txt











