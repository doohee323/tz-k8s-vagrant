#!/bin/bash

TZ_PROJECT=tz-aws-terraform

cd /vagrant/${TZ_PROJECT}
terraform destroy -auto-approve

sleep 60

rm -Rf .terraform
rm -Rf terraform.tfstate
rm -Rf terraform.tfstate.backup
rm -Rf s3_bucket_id
rm -Rf /home/vagrant/.aws/config

#- master-role in IAM Roles
aws iam remove-role-from-instance-profile --instance-profile-name master-role --role-name master-role
aws iam delete-instance-profile --instance-profile-name master-role
aws iam delete-role --role-name master-role
policy_name=`aws iam list-role-policies --role-name master-role --output=text | awk '{print $2}'`
if [[ "${policy_name}" != "" ]]]; then
    aws iam delete-role-policy --role-name master-role --policy-name ${policy_name}
fi
echo "#################################################"
echo "You might need to delete s3 bucket."
echo "#################################################"


