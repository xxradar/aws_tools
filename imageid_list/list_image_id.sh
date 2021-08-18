#!/bin/bash
echo "-------------- Listing all imageid for all regions -------------"

export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-AWSONDEMAND*6.4.4*"


for value in $REGIONSLIST
do
    REGION=$value; echo $REGION"="$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId) 
done



