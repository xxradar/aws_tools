#!/bin/bash
echo "-------------- Listing all imageid for all regions PAYG -------------"

export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-*AWSONDEMAND*$1*"

for value in $REGIONSLIST
do
    REGION=$value; echo -e '\t\t\t'"\""$REGION"\":{\"fgtami\": \""$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId)"\"}," >$1_PAYG_json.txt
done


echo "-------------- Listing all imageid for all regions BYOL -------------"
export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-AWS?build*$1*"

for value in $REGIONSLIST
do
    REGION=$value; echo -e '\t\t\t'"\""$REGION"\":{\"fgtami\": \""$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId)"\"}," >$BYOL.txt
done

