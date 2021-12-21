#!/bin/bash
echo "-------------- Listing all imageid for all regions -------------"

export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-*AWSONDEMAND*7.0.2*"
#export LOOKUP="Name=name,Values=*FortiGate-VM64-AWS?build*7.0.2*"


echo  "Mappings:"
echo  "  RegionMap:"


for value in $REGIONSLIST
do
    REGION=$value;
    echo -e "    "$REGION":"
    echo -e "       fgtami: "$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId)
done

