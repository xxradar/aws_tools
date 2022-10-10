#!/bin/bash

if [[ -n "$1" ]];
then
echo "Version: "$1
else
echo "Set version as ex. ./list_image_id.sh 7.2.2";exit;
fi


# Cleanup
rm  $1_PAYG_json.txt 
rm  $1_BYOL_json.txt 
rm  $1_PAYG_yaml.txt 
rm  $1_BYOL_yaml.txt 

# Prep file
echo  "Mappings:" >$1_PAYG_yaml.txt
echo  "  RegionMap:" >>$1_PAYG_yaml.txt
echo  "Mappings:" >$1_BYOL_yaml.txt
echo  "  RegionMap:" >>$1_BYOL_yaml.txt

echo "-------------- Listing all imageid for all regions PAYG -------------"

export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-*AWSONDEMAND*$1*"

for value in $REGIONSLIST
do
    REGION=$value; echo -e '\t\t\t'"\""$REGION"\":{\"fgtami\": \""$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId)"\"}," >>$1_PAYG_json.txt
    echo -e "    "$REGION":" >>$1_PAYG_yaml.txt >>$1_PAYG_yaml.txt
    echo -e "       fgtami: "$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId) >>$1_PAYG_yaml.txt



done


echo "-------------- Listing all imageid for all regions BYOL -------------"
#export REGIONSLIST=$(aws ec2 describe-regions | jq -r .Regions[].RegionName)
export LOOKUP="Name=name,Values=*FortiGate-VM64-AWS?build*$1*"

for value in $REGIONSLIST
do
    REGION=$value; echo -e '\t\t\t'"\""$REGION"\":{\"fgtami\": \""$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId)"\"}," >>$1_BYOL_json.txt
    echo -e "    "$REGION":" >>$1_BYOL_yaml.txt
    echo -e "       fgtami: "$(aws ec2 describe-images --filters $LOOKUP --region $value| jq -r .Images[].ImageId) >>$1_BYOL_yaml.txt
done



# Cleanup file
truncate  -s -2 $1_PAYG_json.txt
echo -e "\n" >>$1_PAYG_json.txt
truncate  -s -2 $1_BYOL_json.txt
echo -e "\n" >>$1_BYOL_json.txt
