#!/bin/bash

# this is for automated patching of underlying AMIs of our ecs clusters
# nowell.morris@linuxacademy.com v 0.1

# opening script

# this script depends upon AMI availability and is run from a lambda job

# let's get our list of instances to be patched

awsc='aws --profile nowell-test'
environment2patch=nowell-test-cluster1
echo \
echo "We will be patching the $environment2patch environment now."
echo \

# obtain list of container-instances (these are not EC2 instnace IDs, but Container IDs from ECS
$awsc ecs list-container-instances --cluster $environment2patch --output text | awk -F/ '{print$2}' > files/cluster-$environment2patch-container-instances.list 
#cat files/cluster-$environment2patch-container-instances.list

# using our above list, let's query each to get the EC2 instance ID
for i in `cat files/cluster-$environment2patch-container-instances.list`
do
	$awsc ecs describe-container-instances --cluster $environment2patch --container-instances $i |jq '.containerInstances[0].ec2InstanceId' | tr -d '"' >> files/cluster-$environment2patch-ec2-instances.list 
done
#cat files/cluster-$environment2patch-ec2-instances.list

# now we use the EC2 Instance IDs to find the AMI ID that they were built from
for j in `cat files/cluster-$environment2patch-ec2-instances.list`
do
	$awsc ec2 describe-instances --instance-ids $j | jq '.Reservations[].Instances[].ImageId' | tr -d '"' >> files/cluster-$environment2patch-ec2-ami-ids.list
done
#cat files/cluster-$environment2patch-ec2-ami-ids.list


# finally, we will take the output and put it into a csv file format
paste -d',' files/cluster-$environment2patch-container-instances.list files/cluster-$environment2patch-ec2-instances.list files/cluster-$environment2patch-ec2-ami-ids.list > files/2bpatched.csv


# print our csv file that we just generated
cat files/2bpatched.csv



