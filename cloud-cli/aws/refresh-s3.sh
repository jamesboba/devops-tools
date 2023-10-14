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
datetime=$(date +%Y-%m-%d-%H:%M:%S)


#FilePath
Store_Path="data/${env}/${account}/${region}/${datetime}"
mkdir -p ${Store_Path}
cd ${Store_Path}

#------------------------------------
#              Functions
#------------------------------------

function get_cdn {

  if [ $account == "default" ]; then
    aws cloudfront list-distributions --region $region --output json > aws-${env}-${account}-${region}-cdn.json
  else
    aws cloudfront list-distributions --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-cdn.json
  fi

  cat aws-${env}-${account}-${region}-cdn.json | jq -r '.DistributionList.Items[] | {name: .Aliases.Items[0],id: .Id,Staging: .Staging,Enabled: .Enabled} | join(",")' | sort > aws-${env}-${account}-${region}-cdn.csv
  echo ""
  echo "get_cdn list"
  echo ""

}



#------------------------------------
#              Execute
#------------------------------------

| jq -r '.DistributionList.Items[] | {name: .Aliases.Items[0],id: .Id,Staging: .Staging,Enabled: .Enabled} | join(",")'