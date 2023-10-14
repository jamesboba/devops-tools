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

function get_clb_list {

tccli clb DescribeLoadBalancers --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset $5 --Limit 100
}

function get_clb_total {

tccli clb DescribeLoadBalancers --cli-unfold-argument \
  --region $4 --ProjectId $3 \
  --secretId $1 --secretKey $2 \
  --Offset 0 --Limit 1 | jq -r '.TotalCount'
}

function get_clb_pages {

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
tmp="clb_list.csv"
jsonfile="clb_list.json"
file="${ProjectId}_${Region}_clb_list.csv"
total=`get_clb_total $secretId $secretKey $ProjectId $Region`
pages=`get_clb_pages $total`

echo "ProjectId,MasterRegion,MasterZone,TargetRegion,LoadBalancerId,LoadBalancerName,Domain,Forward,LoadBalancerType,OpenBgp,LoadBalancerVips,ChargeType,InternetChargeType,InternetMaxBandwidthOut,Status,StatusTime,CreateTime" >> ${file}


if [[ -z  "${total}" ]]; then
  echo "This ${Region} no clb"
  total=0
else

  for ((i=0; i<$pages; i++))
  do
    if [ $i -eq "0" ]; then
      offset=0
      # 建立初始第一頁
      get_clb_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.LoadBalancerSet[]' >> $jsonfile
    else
      offset=$(($i*100))
      # 將第一頁以外的資料新增至 json 檔案裡
      get_clb_list $secretId $secretKey $ProjectId $Region $offset | jq -r '.LoadBalancerSet[]' >> $jsonfile
    fi
  done

  #擷取資料
  cat ${jsonfile} | jq -r '. | {ProjectId: .ProjectId,MasterRegion: .MasterZone.ZoneRegion,MasterZone: .MasterZone.Zone,TargetRegion: .TargetRegionInfo.Region,LoadBalancerId: .LoadBalancerId,LoadBalancerName: .LoadBalancerName,Domain: .Domain,Forward: .Forward,LoadBalancerType: .LoadBalancerType,OpenBgp: .OpenBgp,lb: .LoadBalancerVips[0],ChargeType: .ChargeType,InternetChargeType: .NetworkAttributes.InternetChargeType,InternetMaxBandwidthOut: .NetworkAttributes.InternetMaxBandwidthOut,Status: .Status,StatusTime: .StatusTime,CreateTime: .CreateTime} | join(",")' >> ${file}

fi

#-------------------------------------------------------------------------------
#                                 Ｃalculate
#-------------------------------------------------------------------------------

#Total_LoadBalancerType
Total_LoadBalancerType=`cat ${jsonfile} | jq -r '. | {LoadBalancerType: .LoadBalancerType} | join(",")' | sort | uniq -c`
#Total_ChargeType
Total_ChargeType=`cat ${jsonfile} | jq -r '. | {ChargeType: .ChargeType} | join(",")' | sort | uniq -c`
#Total_Status
Total_Status=`cat ${jsonfile} | jq -r '. | {Status: .Status} | join(",")' | sort | uniq -c`
#Total_Open
Total_Open=`cat ${jsonfile} | jq -r '. | select (.LoadBalancerType == "OPEN") | {lb: .LoadBalancerVips[0]} | join(",")'`
#Total_Internal
Total_Internal=`cat ${jsonfile} | jq -r '. | select (.LoadBalancerType == "INTERNAL") | {lb: .LoadBalancerVips[0]} | join(",")'`


echo " ProjectId: $ProjectId \n Region: $Region \n LoadBalancerType: \n $Total_LoadBalancerType \n ChargeType: \n $Total_ChargeType \n Status: \n $Total_Status \n OpenIP: \n $Total_Open \n InternalIP: \n $Total_Internal \n Total: $total "