#!/bin/bash
aws eks delete-nodegroup --cluster-name EKSdemocluster --nodegroup-name EKSdemocluster-ng
aws eks delete-cluster --name EKSdemocluster


aws iam detach-role-policy --policy-arn  arn:aws:iam::aws:policy/AmazonEKSClusterPolicy --role-name EKSdemoClusterRole
aws iam delete-role --role-name EKSdemoClusterRole

aws iam detach-role-policy --policy-arn  arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy --role-name EKSdemoNodeRole
aws iam detach-role-policy --policy-arn  arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --role-name EKSdemoNodeRole
aws iam detach-role-policy --policy-arn  arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy --role-name EKSdemoNodeRole
aws iam delete-role --role-name EKSdemoNodeRole
