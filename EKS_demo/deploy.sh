#!/bin/bash


# 1. Create a VPC
VpcID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq -r .Vpc.VpcId)
aws ec2 create-tags --resources $VpcID --tags Key=Name,Value=EKSdemo


# Create 2 (or more) subnets 
#    - public auto-assign
#    - makes ure there is routing / igw 
aws ec2 create-subnet --vpc-id $VpcID --cidr-block 10.0.1.0/24 --availability-zone eu-west-3a --output text
aws ec2 create-subnet --vpc-id $VpcID --cidr-block 10.0.2.0/24 --availability-zone eu-west-3b --output text

# Create Internet Gateway
IgwID=$(aws ec2 create-internet-gateway | jq -r .InternetGateway.InternetGatewayId)
aws ec2 attach-internet-gateway --vpc-id $VpcID --internet-gateway-id $IgwID --output text

# Get default routing table
RtbID=$(aws ec2 create-route-table --vpc-id $VpcID | jq -r .RouteTable.RouteTableId)
aws ec2 create-route --route-table-id $RtbID --destination-cidr-block 0.0.0.0/0 --gateway-id $IgwID --output text
aws ec2 describe-route-tables --route-table-id $RtbID --output text

# List all subnetID
SubnetID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values="$VpcID --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock}" | jq -r .[].ID)

# Associate routing table to subnets
for value in $SubnetID
do
	aws ec2 associate-route-table  --subnet-id $value --route-table-id $RtbID --output text
	aws ec2 modify-subnet-attribute --subnet-id $value  --map-public-ip-on-launch --output text
done




