#!/bin/bash
export AWS_REGION="eu-west-3"
export REGION_AZ1="eu-west-3a"
export REGION_AZ2="eu-west-3b"

# Create a VPC
VpcID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq -r .Vpc.VpcId)
aws ec2 create-tags --resources $VpcID --tags Key=Name,Value=EKSdemo


# Create 2 (or more) subnets 
#    - public auto-assign
#    - makes ure there is routing / igw 
aws ec2 create-subnet --vpc-id $VpcID --cidr-block 10.0.1.0/24 --availability-zone $REGION_AZ1 --output text
aws ec2 create-subnet --vpc-id $VpcID --cidr-block 10.0.2.0/24 --availability-zone REGION_AZ2 --output text

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


# Make sure there is a EKS Cluster Role
cat  <<EOF >EKS_role_policy_doc.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role --role-name EKSdemoClusterRole  --assume-role-policy-document file://EKS_role_policy_doc.json --output text
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy --role-name EKSdemoClusterRole  --output text 
EKSdemoCluserRoleArn=$(aws iam get-role --role-name EKSdemoClusterRole | jq -r .Role.Arn)


# Make sure there is a EKS Node Role
cat  <<EOF >EKS_node_role_policy_doc.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


aws iam create-role --role-name EKSdemoNodeRole  --assume-role-policy-document file://EKS_node_role_policy_doc.json --output text 
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy --role-name EKSdemoNodeRole --output text 
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name EKSdemoNodeRole --output text 
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy --role-name EKSdemoNodeRole --output text 
aws iam get-role --role-name EKSdemoNodeRole  --output text 
EKSdemoNodeRoleArn=$(aws iam get-role --role-name EKSdemoNodeRole | jq -r .Role.Arn)



# Create your security-group
SGgroupID=$(aws ec2 create-security-group --group-name MySecurityGroup --description "My security group" --vpc-id $VpcID | jq -r .GroupId)
aws ec2 authorize-security-group-ingress --group-id $SGgroupID --protocol all --cidr 0.0.0.0/0 --output text


# Create your Cluster
aws eks create-cluster \
   --region $AWS_REGION \
   --name EKSdemocluster \
   --kubernetes-version 1.21 \
   --role-arn $EKSdemoCluserRoleArn \
   --resources-vpc-config subnetIds=$(echo $SubnetID | sed -e 's/ /,/g'),securityGroupIds=$SGgroupID \
   --output text

echo "Creating EKS cluster. This can take up to 15min"

while [ $(aws eks describe-cluster  --name EKSdemocluster --region eu-west-3 | jq -r .cluster.status) != "ACTIVE" ]
do
   sleep 15; echo -n ".";
done
echo -e "\n Completed"


# Create a Nodegroup
aws eks create-nodegroup  \
--cluster-name EKSdemocluster \
--nodegroup-name EKSdemocluster-ng \
--subnets $SubnetID \
--node-role $EKSdemoNodeRoleArn \
--output text 

# Export kubeconfig 
aws eks --region $AWS_REGION update-kubeconfig --name EKSdemocluster   --kubeconfig eksdemokubeconfig.yaml

# Check your nodes
export KUBECONFIG=$PWD/eksdemokubeconfig.yaml
echo -e "\n This can take up to a few minutes ... ctrl-C to exit"
watch kubectl get no
echo "run 'export KUBECONFIG=$PWD/eksdemokubeconfig.yaml' to connect to your cluster with kubectl"
