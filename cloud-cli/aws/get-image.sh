#!/bin/bash -
#======================================================================
#
#       FILE: get-image.sh
#
#       USAGE: get-image.sh command
#
#       AUTHOR: 
#       CREATED: 2023/08/09
#======================================================================



#------------------------------------
#              Input
#------------------------------------

command=$1

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

#------------------------------------
#              Functions
#------------------------------------


function get_ecr_repo {

  #FilePath
  Store_Path="data/image/${account}/${region}"
  mkdir -p ${Store_Path}
  cd ${Store_Path}

  if [ $account == "default" ]; then
    aws ecr describe-repositories --region $region --output json > aws-${account}-${region}-ecr-repo.json
  else
    aws ecr describe-repositories --region $region --output json --profile ${account} > aws-${account}-${region}-ecr-repo.json
  fi
  cat aws-${account}-${region}-ecr-repo.json | jq -r '.repositories[].repositoryUri' > aws-${account}-${region}-ecr-repo.csv

  echo ""
  cat aws-${account}-${region}-ecr-repo.csv
  echo ""
}

function get_ecr_image {

  #FilePath
  Store_Path="data/image/${account}/${region}"
  mkdir -p ${Store_Path}
  cd ${Store_Path}

  if [ $account == "default" ]; then
    aws ecr describe-images --region $region --output json --repository-name $repo > aws-${account}-${region}-${repo}-ecr-image.json
  else
    aws ecr describe-images --region $region --output json --repository-name $repo --profile ${account} > aws-${account}-${region}-${repo}-ecr-image.json
  fi


}



function all_image {

set -o nounset       # Treat unset variables as an error

for repo in \
        $(aws ecr describe-repositories |\
        jq -r '.repositories[].repositoryArn' |\
        sort -u |\
        awk -F ":" '{print $6}' |\
        sed 's/repository\///')
do
        echo "$1.dkr.ecr.eu-west-1.amazonaws.com/${repo}@$(aws ecr describe-images\
        --repository-name ${repo}\
        --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageDigest' |\
        tr -d '"')"
done > latest-image-per-ecr-repo-${1}.list

}

#------------------------------------
#              Execute
#------------------------------------


case "$command" in
    repo_list)
       read -p "Region : " region
       read -p "Account : " account
       get_ecr_repo
        ;;
    image_list) 
       read -p "Region : " region
       read -p "Account : " account
       read -p "Repo : " repo  
       get_ecr_image
        ;;
    *) echo "Unknow command "
       exit 0
esac