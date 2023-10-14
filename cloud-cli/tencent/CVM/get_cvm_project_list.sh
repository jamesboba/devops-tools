#!/bin/bash

#-------------------------------------------------------------------------------
#                       Comfirm Input & Store Data Path
#-------------------------------------------------------------------------------

datetime=$(date +%Y-%m-%d-%H:%M:%S)

if [ $# -ne 4 ]; then

 echo "使用方式：$0 <secretId> <secretKey> <ProjectId> <Region>"

 exit 0
fi

secretId=$1 
secretKey=$2
ProjectId=$3
Region=$4

#Store path
mkdir -p "${ProjectId}/${Region}/${datetime}"
cd ${ProjectId}/${Region}/${datetime}

#-------------------------------------------------------------------------------
#                               Functions
#-------------------------------------------------------------------------------

function get_cvm_list {
tccli cvm DescribeInstances --cli-unfold-argument \
  --region $4 --Filters.0.Name project-id --Filters.0.Values $3 \
  --secretId $1 --secretKey $2 \
  --Offset $5 --Limit 100
}

function get_cvm_total {
tccli cvm DescribeInstances --cli-unfold-argument \
  --region $4 --Filters.0.Name project-id --Filters.0.Values $3 \
  --secretId $1 --secretKey $2 \
  --Offset 0 --Limit 1 | jq -r '.TotalCount'
}

function get_cvm_pages {

# 預設頁數為1
pages=1

 # 餘數不為0 則頁數為 "1+VM 數量/100"
if [[ `expr $1 % 100` != "0" && `expr $1 / 100` > "0" ]]; then
  pages=$(($pages+$1/100))
  echo $pages
# 餘數為0 則頁數為 "VM 數量/100"
elif [ `expr $1 % 100` == "0" ]; then
  pages=$(($1/100))
  echo $pages
# 頁數為1
else
    echo $pages
fi 

}

#-------------------------------------------------------------------------------
#                                 Execute
#-------------------------------------------------------------------------------

#ENV
tmp="cvm_list.csv"
jsonfile="cvm_list.json"
file="${ProjectId}_${Region}_cvm_list.csv"
total=`get_cvm_total $secretId $secretKey $ProjectId $Region`
pages=`get_cvm_pages $total`
echo "Region,Zone,ProjectId,InstanceId,HostId,InstanceName,InstanceType,CPU,Memory,Image,PrivateIpAddresses,PublicIpAddresses,InstanceChargeType,InstanceState" >> ${file}


if [[ -z  "${total}" ]]; then
  echo "This ${Region} no server"
  total=0
else

  for ((i=0; i<$pages; i++))
  do
    if [ $i -eq "0" ]; then
      offset=0
      # 建立初始第一頁
      get_cvm_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.InstanceSet[]' >> $jsonfile
    else
      offset=$(($i*100))
      # 將第一頁以外的資料新增至 json 檔案裡
      get_cvm_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.InstanceSet[]' >> $jsonfile
    fi
  done

  cat ${jsonfile} | jq -r '. | {Zone: .Placement.Zone,ProjectId: .Placement.ProjectId,InstanceId: .InstanceId,HostId: .Placement.HostId,InstanceName: .InstanceName, InstanceType: .InstanceType, CPU: .CPU,Memory: .Memory, Image: .ImageId,PrivateIpAddresses : .PrivateIpAddresses[0], PublicIpAddresses: .PublicIpAddresses[0], InstanceChargeType: .InstanceChargeType,InstanceState: .InstanceState} | join(",")' >> ${tmp}


  #補欄位資料
  while read -r line; do
    echo "${Region},${line}" >> ${file}
  done < ${tmp}

  #Total_InstanceType
  Total_InstanceType=`cat ${jsonfile} | jq -r '. | {InstanceChargeType: .InstanceType,CPU: .CPU,Memory: .Memory} | join(",")' | sort | uniq -c`
  #Total_InstanceChargeType
  Total_InstanceChargeType=`cat ${jsonfile} | jq -r '. | {InstanceChargeType: .InstanceChargeType} | join(",")' | sort | uniq -c`
  #Total_InstanceState
  Total_InstanceState=`cat ${jsonfile} | jq -r '. | {InstanceState: .InstanceState} | join(",")' | sort | uniq -c`
  #Total_HostId
  Total_HostId=`cat ${jsonfile} | jq -r '. | select (.Placement.HostId != null) | {HostId: .Placement.HostId} | join(",")' | sort | uniq -c`


fi

echo -e " ProjectId: $ProjectId \n Region: $Region \n InstanceType: \n $Total_InstanceType \n CDH_HostId: \n $Total_HostId \n  InstanceChargeType: \n $Total_InstanceChargeType \n InstanceState: \n $Total_InstanceState \n Total: $total "