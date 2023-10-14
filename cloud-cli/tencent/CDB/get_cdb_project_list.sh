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

function get_cdb_list {
tccli cdb DescribeDBInstances --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset $5 --Limit 2000
}

function get_cdb_total {
tccli cdb DescribeDBInstances --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset 0 --Limit 1 | jq -r '.TotalCount'
}

function get_cdb_pages {

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
tmp="cdb_list.csv"
jsonfile="cdb_list.json"
file="${ProjectId}_${Region}_cdb_list.csv"
total=`get_cdb_total $secretId $secretKey $ProjectId $Region`
pages=`get_cdb_pages $total`

#echo "Region,Zone,ProjectId,InstanceId,InstanceName,Cpu,Memory(MB),Volume(GB),Qps,InstanceNodes,SlaveInfo_First_Region,SlaveInfo_First_Zone,InstanceType(1-主实例;2-灾备实例;3-只读实例),EngineType,EngineVersion,ProtectMode(0 - 异步复制,1 - 半同步复制,2 - 强同步复制),DeployMode(0 - 单可用区,1 - 多可用区),WanStatus(0-未开通外网;1-已开通外网;2-已关闭外网),CdbError(0 -未被锁定;1 -已被锁定),MaxDelayTime,AutoRenew,PayType(0-包年包月;1-按量计费),Status,CreateTime,DeadlineTime" >> ${file}
echo "Region,Slave_Region,Zone,Slave_Zone,ProjectId,InstanceId,InstanceName,Cpu,Memory(MB),Volume(GB),Qps,InstanceNodes,InstanceType,EngineType,EngineVersion,ProtectMode,DeployMode,WanStatus,CdbError,MaxDelayTime,AutoRenew,PayType,Status,CreateTime,DeadlineTime" >> ${file}


if [[ -z  "${total}" ]]; then
  echo "This ${Region} no cdb"
  total=0
else

  for ((i=0; i<$pages; i++))
  do
    if [ $i -eq "0" ]; then
      offset=0
      # 建立初始第一頁
      get_cdb_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.Items[]' >> $jsonfile
    else
      offset=$(($i*2000))
      # 將第一頁以外的資料新增至 json 檔案裡
      get_cdb_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.Items[]' >> $jsonfile
    fi
  done

  #cat ${jsonfile} | jq -r '. | {Region: .Region,Zone: .Zone,ProjectId: .ProjectId,InstanceId: .InstanceId,InstanceName: .InstanceName,Cpu: .Cpu,Memory: .Memory,Volume: .Volume,Qps: .Qps,InstanceNodes: .InstanceNodes,SlaveInfoRegion: .SlaveInfo.First.Region,SlaveInfoZone: .SlaveInfo.First.Zone,InstanceType: .InstanceType,EngineType: .EngineType,EngineVersion: .EngineVersion,ProtectMode: .ProtectMode,DeployMode: .DeployMode,WanStatus: .WanStatus,CdbError: .CdbError,MaxDelayTime: .MaxDelayTime,AutoRenew: .AutoRenew,PayType: .PayType,Status: .Status,CreateTime: .CreateTime,DeadlineTime: .DeadlineTime} | join(",")' >> ${file}
  cat ${jsonfile} | jq -r '. | {Region: .Region,SlaveRegion: .SlaveInfo.First.Region,Zone: .Zone,SlaveZone: .SlaveInfo.First.Zone,ProjectId: .ProjectId,InstanceId: .InstanceId,InstanceName: .InstanceName,Cpu: .Cpu,Memory: .Memory,Volume: .Volume,Qps: .Qps,InstanceNodes: .InstanceNodes,InstanceType: .InstanceType,EngineType: .EngineType,EngineVersion: .EngineVersion,ProtectMode: .ProtectMode,DeployMode: .DeployMode,WanStatus: .WanStatus,CdbError: .CdbError,MaxDelayTime: .MaxDelayTime,AutoRenew: .AutoRenew,PayType: .PayType,Status: .Status,CreateTime: .CreateTime,DeadlineTime: .DeadlineTime} | join(",")' >> ${file}


  #Total_InstanceType
  Total_InstanceType=`cat ${jsonfile} | jq -r '. | {InstanceType: .InstanceType} | join(",")' | sort | uniq -c`
  #Total_resource
  Total_resource=`cat ${jsonfile} | jq -r '. | {Cpu: .Cpu,Memory: .Memory,Volume: .Volume} | join(",")' | sort | uniq -c`
  #Total_Engine
  Total_Engine=`cat ${jsonfile} | jq -r '. | {EngineType: .EngineType,EngineVersion: .EngineVersion} | join(",")' | sort | uniq -c`
  #Total_PayType
  Total_PayType=`cat ${jsonfile} | jq -r '. | {PayType: .PayType} | join(",")' | sort | uniq -c`
  #Total_Status
  Total_Status=`cat ${jsonfile} | jq -r '. | {Status: .Status} | join(",")' | sort | uniq -c`
  

fi

echo -e " ProjectId: $ProjectId \n Region: $Region \n InstanceType(1-主实例,2-灾备实例,3-只读实例): \n $Total_InstanceType \n Resource(CPU,Memory(MB),Volume(GB)): \n $Total_resource \n  Engine: \n $Total_Engine \n PayType(0-包年包月,1-按量计费): \n $Total_PayType \n Status(0-创建中,1-运行中,4-隔离中,5-已隔离): \n $Total_Status \n Total: $total "