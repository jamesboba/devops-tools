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

function get_redis_list {

tccli redis DescribeInstances --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset $5 --Limit 1000
}

function get_redis_total {

tccli redis DescribeInstances --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset 0 --Limit 1 | jq -r '.TotalCount'
}

function get_redis_pages {

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
tmp="redis_list.csv"
jsonfile="redis_list.json"
file="${ProjectId}_${Region}_redis_list.csv"
total=`get_redis_total $secretId $secretKey $ProjectId $Region`
pages=`get_redis_pages $total`

echo "Region,ZoneId,ProjectId,InstanceId,InstanceName,Type,ProductType,Engine,Size,RedisReplicasNum,RedisShardNum,RedisShardSize,NoAuth,AutoRenewFlag,BillingMode,Status,Createtime,DeadlineTime" >> ${file}


if [[ -z  "${total}" ]]; then
  echo "This ${Region} no redis"
  total=0
else

  for ((i=0; i<$pages; i++))
  do
    if [ $i -eq "0" ]; then
      offset=0
      # 建立初始第一頁
      get_redis_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.InstanceSet[]' >> $jsonfile
    else
      offset=$(($i*1000))
      # 將第一頁以外的資料新增至 json 檔案裡
      get_redis_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.InstanceSet[]' >> $jsonfile
    fi
  done

  #擷取資料
  cat ${jsonfile} | jq -r '. | {Region: .Region,ZoneId: .ZoneId,ProjectId: .ProjectId,InstanceId: .InstanceId,InstanceName: .InstanceName,Type: .Type,ProductType: .ProductType,Engine: .Engine,Size: .Size,RedisReplicasNum: .RedisReplicasNum,RedisShardNum: .RedisShardNum,RedisShardSize: .RedisShardSize,NoAuth: .NoAuth,AutoRenewFlag: .AutoRenewFlag,BillingMode: .BillingMode,Status: .Status,Createtime: .Createtime,DeadlineTime: .DeadlineTime} | join(",")' >> ${file}

  #Total_Size
  Total_Size=`cat ${jsonfile} | jq -r '. | {Size: .Size} | join(",")' | sort | uniq -c`
  #Total_resource
  Total_resource=`cat ${jsonfile} | jq -r '. | {RedisReplicasNum: .RedisReplicasNum,RedisShardNum: .RedisShardNum,RedisShardSize: .RedisShardSize} | join(",")' | sort | uniq -c`
  #Total_ProductType
  Total_ProductType=`cat ${jsonfile} | jq -r '. | {ProductType: .ProductType,Engine: .Engine} | join(",")' | sort | uniq -c`
  #Total_BillingMode
  Total_BillingMode=`cat ${jsonfile} | jq -r '. | {BillingMode: .BillingMode} | join(",")' | sort | uniq -c`
  #Total_Status
  Total_Status=`cat ${jsonfile} | jq -r '. | {Status: .Status} | join(",")' | sort | uniq -c`

fi

echo -e " ProjectId: $ProjectId \n Region: $Region \n Size(MB): \n $Total_Size \n ProductType: \n $Total_ProductType \n Resource(ReplicasNum,ShardNum,ShardSize(MB)): \n $Total_resource \n BillingMode(0-按量计费,1-包年包月): \n $Total_BillingMode \n Status(0-待初始化,1-实例在流程中,2-实例运行中,-2-实例已隔离,-3-实例待删除): \n $Total_Status \n Total: $total "