#!/bin/bash
# patching_execution.sh
#############################################################################
# this is for automated patching of underlying AMIs of our ecs clusters
# nowell.morris@linuxacademy.com v 0.1
# October 2019
#############################################################################
#
#
#


cd ~/PatchingAutomation
source vars_to_source

# read mode of use by cron.
# options are: amicheck staging production
# var $mode is used in the case statement below
mode=$1


################ Functions ########################


# this is function: check_the_ami
function check_the_ami () {

	# timestamp date_ami_was_checked in vars_to_source
	# this timestamp is merely informational at this time
	# ***************************************************** add fail if it hasn't been 10 days since last check <---------
	newtimestampvariable=$(date +"%m%d%y-%H:%M")
	timestampvariable=$(grep date_ami_was_checked vars_to_source | awk -F= '{print $2}' )
	sed -i "s/$timestampvariable/$newtimestampvariable/" vars_to_source

	recommended_ami=$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended --region us-east-1 | jq '.Parameters[].Value ' | awk -F, '{print $3}' |tr -d '"'|awk -F\\ '{print $4}'|tr -d '.')
	current_ami=$(aws autoscaling describe-launch-configurations --launch-configuration-names $CFprod | jq '.LaunchConfigurations[].ImageId' | tr -d '"' )

	if [ "$current_ami" != "$recommended_ami" ]
		then
			# write the amiversiontouse in vars_to_use
			amiversiontousevariable=$(grep amiversiontouse vars_to_source | awk -F= '{print $2}' )
			sed -i "s/$amiversiontousevariable/$recommended_ami/" vars_to_source

			# set shouldwepatchstaging to Y
			sed -i "s/shouldwepatchstaging=./shouldwepatchstaging=Y/" vars_to_source


		else
			# add a log entry here saying we checked and at specific time newtimestampvariable
			# this only needs to be a stdout or echo statement.  time has already been stamped above

	fi
}
# end of function: check_the_ami



# this is function: begin_staging
function begin_staging () {

			# edit the cloudfunction launch configuration to use new AMI
			# this also requires that the configs should be the same (or not)
			# maybe it would be better to obtain the script from repo, edit, then apply changes
			# otherwise the script would have to be updated here anytime we wanted to make changes
			# *************************** use of David's script here *****************************

# amiversiontousevariable is grepped from vars_to_source
# cluster_size needs to be how many instances are running before we began
amiversiontousevariable=$(grep amiversiontouse vars_to_source | awk -F= '{print $2}' )
cluster_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscaling_group_staging | jq -r '.AutoScalingGroups[].DesiredCapacity')
# var stackname_staging is sourced at the beginning from vars_to_source

aws cloudformation update-stack --stack-name $stackname_staging --use-previous-template --parameters ParameterKey=AsgMaxSize,UsePreviousValue=true \
ParameterKey=DeviceName,UsePreviousValue=true \
ParameterKey=EbsIops,UsePreviousValue=true \
ParameterKey=EbsVolumeSize,UsePreviousValue=true \
ParameterKey=EbsVolumeType,UsePreviousValue=true \
ParameterKey=EcsClusterName,UsePreviousValue=true \
ParameterKey=EcsEndpoint,UsePreviousValue=true \
ParameterKey=EcsInstanceType,UsePreviousValue=true \
ParameterKey=IamRoleInstanceProfile,UsePreviousValue=true \
ParameterKey=IamSpotFleetRoleName,UsePreviousValue=true \
ParameterKey=KeyName,UsePreviousValue=true \
ParameterKey=SecurityGroupId,UsePreviousValue=true \
ParameterKey=SecurityIngressCidrIp,UsePreviousValue=true \
ParameterKey=SecurityIngressFromPort,UsePreviousValue=true \
ParameterKey=SecurityIngressToPort,UsePreviousValue=true \
ParameterKey=SpotAllocationStrategy,UsePreviousValue=true \
ParameterKey=SpotPrice,UsePreviousValue=true \
ParameterKey=SubnetCidr1,UsePreviousValue=true \
ParameterKey=SubnetCidr2,UsePreviousValue=true \
ParameterKey=SubnetCidr3,UsePreviousValue=true \
ParameterKey=SubnetIds,UsePreviousValue=true \
ParameterKey=UseSpot,UsePreviousValue=true \
ParameterKey=VpcAvailabilityZones,UsePreviousValue=true \
ParameterKey=VpcCidr,UsePreviousValue=true \
ParameterKey=VpcId,UsePreviousValue=true \
ParameterKey=AsgDesiredSize,ParameterValue=$cluster_size \
ParameterKey=EcsAmiId,ParameterValue=$amiversiontousevariable

# to be changed in the future where build command is pulled from git

sed -i "s/shouldwepatchstaging=./shouldwepatchstaging=Y/" vars_to_source

cog staging

}
# end of function: begin_staging




# this is function: begin_production
function begin_production () {

			# edit the cloudfunction launch configuration to use new AMI
			# this also requires that the configs should be the same (or not)
			# maybe it would be better to obtain the script from repo, edit, then apply changes
			# otherwise the script would have to be updated here anytime we wanted to make changes
			# *************************** use of David's script here *****************************

# change name from vars_to_source to vars_to_source

# amiversiontousevariable is grepped from vars_to_source
# cluster_size needs to be how many instances are running before we began
amiversiontousevariable=$(grep amiversiontouse vars_to_source | awk -F= '{print $2}' )
cluster_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscaling_group_prod | jq -r '.AutoScalingGroups[].DesiredCapacity')
# var stackname_staging is sourced at the beginning from vars_to_source

aws cloudformation update-stack --stack-name $stackname_prod --use-previous-template --parameters ParameterKey=AsgMaxSize,UsePreviousValue=true \
ParameterKey=DeviceName,UsePreviousValue=true \
ParameterKey=EbsIops,UsePreviousValue=true \
ParameterKey=EbsVolumeSize,UsePreviousValue=true \
ParameterKey=EbsVolumeType,UsePreviousValue=true \
ParameterKey=EcsClusterName,UsePreviousValue=true \
ParameterKey=EcsEndpoint,UsePreviousValue=true \
ParameterKey=EcsInstanceType,UsePreviousValue=true \
ParameterKey=IamRoleInstanceProfile,UsePreviousValue=true \
ParameterKey=IamSpotFleetRoleName,UsePreviousValue=true \
ParameterKey=KeyName,UsePreviousValue=true \
ParameterKey=SecurityGroupId,UsePreviousValue=true \
ParameterKey=SecurityIngressCidrIp,UsePreviousValue=true \
ParameterKey=SecurityIngressFromPort,UsePreviousValue=true \
ParameterKey=SecurityIngressToPort,UsePreviousValue=true \
ParameterKey=SpotAllocationStrategy,UsePreviousValue=true \
ParameterKey=SpotPrice,UsePreviousValue=true \
ParameterKey=SubnetCidr1,UsePreviousValue=true \
ParameterKey=SubnetCidr2,UsePreviousValue=true \
ParameterKey=SubnetCidr3,UsePreviousValue=true \
ParameterKey=SubnetIds,UsePreviousValue=true \
ParameterKey=UseSpot,UsePreviousValue=true \
ParameterKey=VpcAvailabilityZones,UsePreviousValue=true \
ParameterKey=VpcCidr,UsePreviousValue=true \
ParameterKey=VpcId,UsePreviousValue=true \
ParameterKey=AsgDesiredSize,ParameterValue=$cluster_size \
ParameterKey=EcsAmiId,ParameterValue=$amiversiontousevariable

# to be changed in the future where build command is pulled from git

sed -i "s/shouldwepatchprod=./shouldwepatchprod=Y/" vars_to_source

cog production 

}
# end of function: begin_production


function cog () {
	
# depends upon which function calls this one 
environment2patch=$1
#cluster2patch=figure out the logic here
if [ "$environment2patch" == "production" ]
	then cluster2patch="master1"
	elif [ "$environment2patch" == "staging" ]
	then cluster2patch="staging1" 
	else 
		echo "$environment2patch is not a valid environment to patch, cannot assign cluster"
		exit
fi

echo \
echo "We will be patching the $environment2patch environment now."
echo \

# obtain list of container-instances (these are not EC2 instnace IDs, but Container IDs from ECS
aws ecs list-container-instances --cluster $cluster2patch --output text | awk -F/ '{print$2}' > files/cluster-$environment2patch-container-instances.list 
#cat files/cluster-$environment2patch-container-instances.list

# using our above list, let's query each to get the EC2 instance ID
for i in `cat files/cluster-$environment2patch-container-instances.list`
do
	aws ecs describe-container-instances --cluster $cluster2patch --container-instances $i |jq '.containerInstances[0].ec2InstanceId' | tr -d '"' >> files/cluster-$environment2patch-ec2-instances.list 
done
#cat files/cluster-$environment2patch-ec2-instances.list

# now we use the EC2 Instance IDs to find the AMI ID that they were built from
for j in `cat files/cluster-$environment2patch-ec2-instances.list`
do
	aws ec2 describe-instances --instance-ids $j | jq '.Reservations[].Instances[].ImageId' | tr -d '"' >> files/cluster-$environment2patch-ec2-ami-ids.list
done
#cat files/cluster-$environment2patch-ec2-ami-ids.list


# finally, we will take the output and put it into a csv file format
paste -d',' files/cluster-$environment2patch-container-instances.list files/cluster-$environment2patch-ec2-instances.list files/cluster-$environment2patch-ec2-ami-ids.list > files/2bpatched.csv


# print our csv file that we just generated
#cat files/2bpatched.csv

# call function patch_it_now
patch_it_now $environment2patch

}
# end of cog function




function patch_it_now () {
env2patch=$1
if [ "$env2patch" == "production" ]
	then autoscalegroupname="<name of autoscaling group in Prod>"
		stackname2patch="<name of stack in Prod>"
	elif [ "$env2patch" == "staging" ]
	then autoscalegroupname="<name of autoscaling group in Staging>"
		stackname2patch="<name of stack in Staging>"
	else echo "$env2patch not correct, error in function patch_it_now" # exit script and echo error to stdout
		exit
fi
	
autoscalegroupdesiredcapacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname | jq -r '.AutoScalingGroups[].DesiredCapacity')

#
# This section is what AWS has now created as "Instance Refresh" available now as of 2021
#
#cloudformation script will have just been updated from image.sh to include new AMI and instance count
#get list of existing instances so we can later compare 
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/originals.list
#add new instance(s)  - # we'll add just one for now, and we'll figure out soon how to add more than one at a time
let "temporaryplus1 = $autoscalegroupdesiredcapacity + 1"
aws autoscaling set-desired-capacity --auto-scaling-group-name $autoscalegroupname --desired-capacity $temporaryplus1
sleep 4m    
    
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/withchange.list

delta=$(comm -12 --nocheck-order 2bpatched.csv withchange.csv | head -1)

# start while loop here
#while something good till all instances are replaced and validated  # becareful of desiredcapacity growing each iteration
while [ -n "$delta" ] 
do
#identify an instance that is old, then drain it and watch for it to be ready to remove
#lets do a loop through a list and compare instance underlying ami between old and newly identified one
#when it finds a difference, identify instance, and then exit loop
#this means the output-list will need to get rewritten 
#compare files/originals.list with output of files/updated.list

aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/withchange.list

delta=$(comm -12 --nocheck-order 2bpatched.csv withchange.csv | head -1)
continstance2drain=$(echo $delta | awk -F, '{print $1}')
instance2drain=$(echo $delta | awk -F, '{print $2}')

#drain instance(s) 
aws ecs update-container-instances-state --cluster $cluster2patch --container-instances $continstance2drain --status draining
			  
# this is a one at a time loop to follow draining until completion 
# watch status  
aws ecs describe-container-instances --cluster $cluster2patch --container-instances $continstance2drain > .tmpout 
if [ $(grep -ci draining .tmpout) -ne 0]
	then	
	while [ .tmptasks -gt 0 ]
		do
		echo -n $i
		grep  runningTasksCount .tmpout 
		grep  runningTasksCount .tmpout | tr -d '"'|awk -F: '{print$2}'|tr -d ','|tr -d ' ' > .tmptasks
		howmany=$(cat .tmptasks)
		if [ $howmany -gt 0 ]
		then
			echo Will wait 5 min, there are still $howmany tasks running
			sleep 5m
			# n +1  - we'll let this loop for a while, but not indefinitely (this loop checker is not finished, this line is a placeholder) find a loop till n = 12 and then exit with error stopping further patching because draining is stuck
# *************************add notification to this 'if' statement so that if a job doesn't end and remains running, the patching process lets us know (email or slack)*********************
		fi
	done
fi

# now remove scale-in protection and shrink desiredsize by one
aws autoscaling set-instance-protection --instance-ids $instance2drain  --auto-scaling-group-name $autoscalegroupname --no-protected-from-scale-in
	
#shrink pool by one, or back to original desired capacity
aws autoscaling set-desired-capacity --auto-scaling-group-name $autoscalegroupname --desired-capacity $autoscalegroupdesiredcapacity
sleep 4m
	
#future task - validate that $instance2drain is no longer in cluster
	
done	
	
}
# end of function: patch_it_now









################### End of Functions section ############################



################### Main script process/function #######################
# let's make sure that we are not already running this script in a prior process
# this script is called patching_execution.sh 
arewerunning=$(ps aux | grep "patching_execution.sh")
if [[ -n $arewerunning ]]
	then
	echo "We may be already running this script in another process.  If this is so, it is likely"
	echo "that is should not be.  This script should exit cleanly.  Check for hung processes. "
	echo $arewerunning

	else
# begin rest of script #

# make sure a mode was declared upon script execution, 
# if not, then echo to user to relaunch with chosen mode
if [[ -n $mode ]]
  then 

	case $mode in 
		
		amicheck)
			# call check_the_ami function
			check_the_ami
			;;
			
		staging)
			# call function
			autoscalegroupname="<name of autoscaling group in Staging>"
        	        stackname2patch="<name of stack in Staging>"
			cluster2patch="<name of cluster in staging>"
			begin_staging $mode
			;;
			
		production)
			# call function
			begin_production
			autoscalegroupname="<name of autoscaling group in Prod>"
                	stackname2patch="<name of stack in Prod>"
			cluster2patch="<name of cluster in Prod>"
			begin_production $mode
			;;
		*)
			echo "usage: determine.sh [mode] where mode is amicheck staging or production"
			echo "something other than accepted modes was declared.  exiting."
			;;
						
	esac  

  else
  	echo "You must declare a mode.  Choices are: amicheck staging production"
  fi	
  
######## end very first if statement where we checked if we were already running #####
fi 


