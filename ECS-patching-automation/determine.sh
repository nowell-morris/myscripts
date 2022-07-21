#!/bin/bash
#############################################################################
# this is for automated patching of underlying AMIs of our ecs clusters
# nowell.morris@linuxacademy.com v 0.1
# august 2019
#############################################################################
#
#
#
#1st cron job to see if there is a new AMI
#2nd cron job to see if we need to patch staging
#3rd cron job to see if staging is patched, if so patch production
#
#
# 1st cron script run on monday every 2 weeks
#	Is there a new AMI?  to find out we need to check our current AMI and compare against recommended ami AND check for cycle complete 
#	if there is a new AMI, then mark Y for patch staging and mark ami version to use for next staging
#
#
# 2nd cron script run on a thursday night, early friday morning bi weekly
#	staging do we need to patch?  check our file for a Y, and validate that the current AMI is different than recommended
#	if both are true, then we begin patching by 1. find current number of running instances 2. update cloudformation script with new ami 3. start instance replacement loop
#	when complete, disable mark for patching staging, and mark Y for production patching
#
#
# 3rd cron script on opposite thursday nights, early friday mornings biweekly
#	production do we need to patch? check our file for a Y, and validate that the current AMI is different than recommended AND the recommended is the same as staging
#	if all is true, then we begin patching cycle as we did above
#	when complete, disable mark for patching production, mark cycle complete

# cd <directory tbd>
source files/afilethatwecreated.txt  

# read mode of use by cron.
# options are: amicheck staging production 
# var $mode is used in the case statement below
mode=$1

# this is function: check_the_ami
function check_the_ami () {
	
	# timestamp date_ami_was_checked in files/afilethatwecreated.txt
	# this timestamp is merely informational at this time 
	# ******************************************************************************** add fail if it hasn't been 10 days since last check <---------
	newtimestampvariable=$(date +"%m%d%y-%H:%M")
	timestampvariable=$(grep date_ami_was_checked files/afilethatwecreated.txt | awk -F= '{print $2}' )
	sed -i "s/$timestampvariable/$newtimestampvariable/" files/afilethatwecreated.txt 
	
	recommended_ami=$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended --region us-east-1 | jq '.Parameters[].Value ' | awk -F, '{print $3}' |tr -d '"'|awk -F\\ '{print $4}'|tr -d '.')
	current_ami=$($awsc autoscaling describe-launch-configurations --launch-configuration-names $CFprod | jq '.LaunchConfigurations[].ImageId' | tr -d '"' )

	if [ "$current_ami" != "$recommended_ami" ]
		then
			# write the amiversiontouse in files/afilethatwecreated.txt
			amiversiontousevariable=$(grep amiversiontouse files/afilethatwecreated.txt | awk -F= '{print $2}' )
			sed -i "s/$amiversiontousevariable/$recommended_ami/" files/afilethatwecreated.txt
			
			# set shouldwepatchstaging to Y 
			sed -i "s/shouldwepatchstaging=./shouldwepatchstaging=Y/" files/afilethatwecreated.txt
			
			
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
			
# amiversiontousevariable is grepped from files/afilethatwecreated.txt
# cluster_size needs to be how many instances are running before we began
amiversiontousevariable=$(grep amiversiontouse files/afilethatwecreated.txt | awk -F= '{print $2}' )
cluster_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscaling_group_staging | jq -r '.AutoScalingGroups[].DesiredCapacity')
# var stackname_staging is sourced at the beginning from files/afilethatwecreated.txt

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

sed -i "s/shouldwepatchstaging=./shouldwepatchstaging=Y/" files/afilethatwecreated.txt




}
# end of function: begin_staging



# this is function: begin_production
function begin_production () {

			# edit the cloudfunction launch configuration to use new AMI
			# this also requires that the configs should be the same (or not)
			# maybe it would be better to obtain the script from repo, edit, then apply changes
			# otherwise the script would have to be updated here anytime we wanted to make changes
			# *************************** use of David's script here *****************************
			
# amiversiontousevariable is grepped from files/afilethatwecreated.txt
# cluster_size needs to be how many instances are running before we began
amiversiontousevariable=$(grep amiversiontouse files/afilethatwecreated.txt | awk -F= '{print $2}' )
cluster_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscaling_group_prod | jq -r '.AutoScalingGroups[].DesiredCapacity')
# var stackname_staging is sourced at the beginning from files/afilethatwecreated.txt

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


sed -i "s/shouldwepatchprod=./shouldwepatchprod=Y/" files/afilethatwecreated.txt



}
# end of function: begin_production


# main script process/function
# let's make sure that we are not already running this script in a prior process
# this script is called determine.sh (because I am not feeling very creative)
arewerunning=$(ps aux | grep "[de]termine.sh")
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
			begin_staging
			;;
			
		production)
			# call function
			begin_production
			;;
		*)
			echo "usage: determine.sh [mode] where mode is amicheck staging or production"
			echo "something other than accepted modes was declared.  exiting."
			;;
						
	esac  

  else
  	echo "You must declare a mode.  Choices are: amicheck staging production"
  fi	
  
# end very first if statement #####
fi 


  
