#!/bin/bash


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
  echo "sh $0 list"
  echo ""
  exit 0
fi

#------------------------------------
#              Functions
#------------------------------------

function get_repo {

  #FilePath
  Store_Path="data/repo/list/${account}/${region}"
  mkdir -p ${Store_Path}
  cd ${Store_Path}

  if [ $account == "default" ]; then
    aws codecommit list-repositories --region $region --output json > aws-${account}-${region}-repo.json
  else
    aws codecommit list-repositories --region $region --output json --profile ${account} > aws-${account}-${region}-repo.json
  fi
  
  
  #Get RepoURL
  for repo in $(cat aws-${account}-${region}-repo.json | jq -r '.repositories[] | {repositoryName: .repositoryName} | join(",")' | sort)
  do
    ((i++))
    #GetRepoMetaData
    if [ $account == "default" ]; then
      aws codecommit get-repository  --repository-name $repo --region $region --output json > aws-${account}-${region}-repo-meta.json
    else
      aws codecommit get-repository  --repository-name $repo --region $region --output json --profile ${account} > aws-${account}-${region}-repo-meta.json
    fi

    #GetData
    if [ i == 1 ]; then
      cat aws-${account}-${region}-repo-meta.json |  jq -r '.repositoryMetadata | {repositoryName: .repositoryName,cloneUrlHttp: .cloneUrlHttp,Arn: .Arn} | join(",")' > aws-${account}-${region}-repo.csv
    else
      cat aws-${account}-${region}-repo-meta.json |  jq -r '.repositoryMetadata | {repositoryName: .repositoryName,cloneUrlHttp: .cloneUrlHttp,Arn: .Arn} | join(",")' >> aws-${account}-${region}-repo.csv
    fi
   
  done 

  echo ""
  cat aws-${account}-${region}-repo.csv

}

function clone_repo {

  read -p "Region :" region
  read -p "Account :" account
  read -p "Repo :" repo

  #FilePath
  Store_Path="data/repo/data/${account}/${region}"
  mkdir -p ${Store_Path}
  cd ${Store_Path}

  git clone codecommit::$region://$account@$repo $repo

}

#------------------------------------
#              Execute
#------------------------------------

case "$command" in
    list)
       read -p "Region :" region
       read -p "Account :" account
       get_repo
        ;;
    clone) 
        clone_repo        
        ;;
    *) echo "Unknow command "
       exit 0
esac