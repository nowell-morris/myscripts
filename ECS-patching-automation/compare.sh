#!/bin/bash
#
# this is for automated patching of underlying AMIs of our ecs clusters
# nowell.morris@linuxacademy.com v 0.1
#
# -----------------------
# let's source a file we created that tells us which environment we are patching
source files/afilethatwecreated.txt     
# from this we can get our $environment2patch var and other vars
# environment2patch=nowell-test-cluster1
# stackname2patch=
#awsc='aws --profile nowell-test'

# we want to know which env we are patching
# we will set var thisenv with either staging or production
checkstaging=$(grep shouldwepatchstaging files/afilethatwecreated.txt | awk -F= '{print $2}' )
checkprod=$(grep shouldwepatchprod files/afilethatwecreated.txt | awk -F= '{print $2}' )
if [ $checkstaging == $checkprod ]
	then
		echo "something in files/afilethatwecreated.txt is not right"
		exit 
	elif [ $checkstaging == Y ]  &&  [ $checkprod == N ] 
		then
			thisenv=staging
		else
			thisenv=production
fi 

	
# now that we know our environment, we need to designate our stackname

if [ $thisenv == "staging" ] 
	then 
		stackname2patch=
	elif [ $thisenv  == "production" ]
		then 
			stackname2patch=
		else 
			echo "something is wrong. exiting"
			exit
fi	



# as we begin, we will see how many instances we have
# aws cloudformation describe-stacks --stack $stackname2patch
desiredinstancecount=$(aws cloudformation describe-stacks --stack $stackname2patch | jq -r '.Stacks[].Parameters | .[] |select(.ParameterKey == "AsgDesiredSize") | .ParameterValue' )
# aws autoscaling describe-auto-scaling-groups (gives DesiredCapacity and it gives AutoScalingGroupName)
autoscalegroupname=$(aws autoscaling describe-auto-scaling-groups | jq -r --arg stackname2patch "$stackname2patch" '.AutoScalingGroups[].Tags | .[] |  select(.Value == $stackname2patch)  | .ResourceId' )
# set a variable so we know how many instances we should finish with
autoscalegroupdesiredcapacity=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname  | jq -r '.AutoScalingGroups[].DesiredCapacity')


# check for differences that we ought to know about.  this will not stop the process, only acknowledge a finding
if [ $desiredinstancecount != $autoscalegroupdesiredcapacity ]
    then 
        echo "Our stack: $stackname2patch wants $desiredinstancecount instances for desired instance count.  However, the autoscaling group: $autoscalegroupname is currently using $autoscalegroupdesiredcapacity instances.  When patching is complete, we will use the beginning desired capacity of the autoscaling group, not the stack definition.  We may wish to update the stack definition accordingly."
fi



# ****************************** this is one at a time, but we could do all or more if we decide *****************************************
# ************ rough draft begin*****************
#get list of existing instances
#aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/originals.list
# add a new instance
#aws autoscaling set-desired-capacity
# aws autoscaling set-desired-capacity --auto-scaling-group-name $autoscalegroupname --desired-capacity 3
#now I will need to find out which instance is new so I can set scalein protection on it, then select an old instance and turn scalein protection off   set-instance-protection
#aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname 
#aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[] |[ .InstanceId,.ProtectedFromScaleIn] |@csv' | tr -d '"'
#i-<instanceID>,true
#i-<instanceID>,true
#i-<instanceID>,false
#
#get list of instances now
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/nowwithnew.list
# get the difference
goo=$(comm -3 files/originals.list files/nowwithnew.list)
if instance_id(goo) has new_ami then set-instance-protection true

aws autoscaling set-instance-protection --instance-ids <instanceID> --auto-scaling-group-name $autoscalegroupname --protected-from-scale-in

aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[] |[ .InstanceId,.ProtectedFromScaleIn] |@csv' | tr -d '"'



# --protected-from-scale-in | --no-protected-from-scale-in

aws autoscaling set-desired-capacity --auto-scaling-group-name $autoscalegroupname --desired-capacity 2
about 3-4 min
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[] |[ .InstanceId,.ProtectedFromScaleIn] |@csv' | tr -d '"'

#start draining identified instance
aws ecs update-container-instances-state --cluster nowell-test-cluster1 --container-instances <container instanceID> --status draining
#validate it is drained
aws ecs describe-container-instances --cluster $environment2patch --container-instances <container instanceID> | grep runningTasksCount | tr -d '"'|awk -F: '{print$2}'|tr -d ','|tr -d ' '
# $ 0
# *****************end rough draft *****************


# this is function: patch
function patch () {
	#breakup the $line -(maybe not.  i may not need this line)
	#line_ami=$(echo $line |awk -F, '{print $3}')
	#cloudformation script will have just been updated from image.sh to include new AMI and instance count
	#get list of existing instances so we can later compare 
    aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/originals.list
	#add new instance(s)  - # we'll add just one for now, and we'll figure out soon how to add more than one at a time
	let "temporaryplus1 = $autoscalegroupdesiredcapacity + 1"
	aws autoscaling set-desired-capacity --auto-scaling-group-name $autoscalegroupname --desired-capacity $temporaryplus1
    sleep 4m    
    
    #**************************************************************************if we force scaleinprotection in our stack, than this section becomes moot **********************************
    #now I will need to find out which instance is new so I can set scalein protection on it, then select an old instance and turn scalein protection off   set-instance-protection
    #aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname 
    #get list of instances now
    #aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[].InstanceId' > files/nowwithnew.list
    # get the difference
    #goo=$(comm -3 files/originals.list files/nowwithnew.list)
	#turn on scalein protection - # this should be a validation since it should already be on
	#I can use this to get a list of what has scaleinprotection and what notification
	#aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[] |[ .InstanceId,.ProtectedFromScaleIn] |@csv' | tr -d '"'
	# if the output from this ridiculously long command has a false, than we take $goo and set scaleinprotection on
	#aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $autoscalegroupname |  jq -r '.AutoScalingGroups[].Instances[] |[ .InstanceId,.ProtectedFromScaleIn] |@csv' | tr -d '"' | grep $goo   - this will look like: <instanceID>,true   but it could be <instanceID>,false   which implies scaleinprotection is not on
	# this section is not complete, but I will leave it here in case we ever want to use it
	#**************************************************end moot section***************************************************
		
	
	#drain instance(s) 
	#select an instance that has not already been patched, and drain it.  can validate one line at a time if the 
    #status is not already draining, and ami is not the recommended

			  
    # this is a one at a time loop to follow draining until completion 
    # watch status  
    # will have to have a waiting function, as well as print to stdout/log of progress with timestamp
    # *************************add notification to this 'if' statement so that if a job doesn't end and remains running, the patching process lets us know (email or slack)*********************
	for i in `cat cluster-$environment2patch-container-instances.list` 
	do aws ecs describe-container-instances --cluster $environment2patch --container-instances $i > .tmpout 
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
					# n +1  - we'll let this loop for a while, but not indefinitely (this loop checker is not finished, this line is a placeholder)
				fi
			done
		fi
		done
	done


	#remove $line from scalein # repeated (could be a sub part of above) to remove scalein protection when status has completed draining 
	
	
	#shrink pool
	
	
	#validate that $line is no longer in cluster
	
	
	
}
# end of function: patch


# FIX THIS ITTERATION 
# 
# this is the comparison, and if true, the call to function: patch
while read -r line; do

# we're doing the same thing as our first discovery, but this time we repeat the process to see changes during the process
# obtain list of container-instances (these are not EC2 instnace IDs, but Container IDs from ECS
aws ecs list-container-instances --cluster $environment2patch --output text | awk -F/ '{print$2}' > files/tmpcluster-$environment2patch-container-instances.list

# using our above list, let's query each to get the EC2 instance ID
for i in `cat files/tmpcluster-$environment2patch-container-instances.list`
do
        aws ecs describe-container-instances --cluster $environment2patch --container-instances $i |jq '.containerInstances[0].ec2InstanceId' | tr -d '"' >> files/tmpcluster-$environment2patch-ec2-instances.list
done

# now we use the EC2 Instance IDs to find the AMI ID that they were built from
for j in `cat files/tmpcluster-$environment2patch-ec2-instances.list`
do
        aws ec2 describe-instances --instance-ids $j | jq '.Reservations[].Instances[].ImageId' | tr -d '"' >> files/tmpcluster-$environment2patch-ec2-ami-ids.list
done

# finally, we will take the output and put it into a csv file format
paste -d',' files/tmpcluster-$environment2patch-container-instances.list files/tmpcluster-$environment2patch-ec2-instances.list files/tmpcluster-$environment2patch-ec2-ami-ids.list > files/newlist.csv



	if  grep -q "$line" files/newlist.csv 
	then patch $line
	fi
done < files/2bpatched.csv


