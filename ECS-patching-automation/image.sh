#!/bin/bash

# this is for automated patching of underlying AMIs of our ecs clusters
# nowell.morris@linuxacademy.com v 0.1

#current_ami=$(cut -d ',' -f 3 files/2bpatched.csv)
latest_ami_date=$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended --region us-east-1 | jq '.Parameters[].Value ' | awk -F, '{print $2}' |tr -d '"'|awk -F\\ '{print $4}'|tr -d '.'|awk -F- '{print $5}')

recommended_ami=$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended --region us-east-1 | jq '.Parameters[].Value ' | awk -F, '{print $3}' |tr -d '"'|awk -F\\ '{print $4}'|tr -d '.')

while read -r line; do
current_ami=$(echo $line | cut -d ',' -f 3 )

if [ "$current_ami" == "$recommended_ami" ]
then
	echo yer all dun for $line
else
	echo these are diffrnt
	variable=$(grep recommended_ami files/afilethatwecreated.txt | awk -F= '{print $2}' )
	sed -i "s/$variable/$recommended_ami/" files/afilethatwecreated.txt 
#	get instance count and assign to var
#	cloudformation script with new AMI as part of def and number of instances
fi
done < files/2bpatched.csv
echo "recommended_ami=$recommended_ami" >> files/afilethatwecreated.txt

