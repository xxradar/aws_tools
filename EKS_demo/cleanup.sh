#!/bin/bash
aws eks delete-nodegroup --cluster-name EKSdemocluster --nodegroup-name EKSdemocluster-ng
aws eks delete-cluster --cluster-name EKSdemocluster

