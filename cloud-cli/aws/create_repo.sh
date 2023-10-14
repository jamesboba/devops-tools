#!/bin/bash

#region=$1
#account=$2
repo=$1

if [ $# -ne 1 ]; then
  echo ""
  echo "Please Input: sh $0 <command>"
  echo ""
  echo "Sample : "
  echo ""
  echo "sh $0 repo_list"
  echo ""
  exit 0
fi

aws codecommit create-repository --region us-east-2 \
    --profile  \
    --repository-name ${repo} \
    --repository-description ${repo}

#aws codecommit create-repository --region ${region} \
#    --profile ${account} \
#    --repository-name ${repo} \
#    --repository-description ${repo}