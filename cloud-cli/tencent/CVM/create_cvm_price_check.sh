#!/bin/bash

#-------------------------------------------------------------------------------
#                       Comfirm Input & Store Data Path
#-------------------------------------------------------------------------------

datetime=$(date +%Y-%m-%d-%H:%M:%S)

if [ $# -ne 3 ]; then

 echo "使用方式：$0 <secretId> <secretKey> <CSV FileName>"

 exit 0
fi

secretId=$1
secretKey=$2
filename=$3
tmp="tmp_cvm_list.csv"
file="price_cvm_list.csv"

#Store path
mkdir -p ${datetime}
cat -v $3 | sed -e 's/\^M//g' >> $tmp
echo "" >> $tmp
mv $3 ${datetime}
mv $tmp ${datetime}
cd ${datetime}

#-------------------------------------------------------------------------------
#                               Functions
#-------------------------------------------------------------------------------

function price_cvm_prepaid() {

  #no DataDisks
  if [[ $3 == "NO" ]]; then
    tccli cvm InquiryPriceRunInstances --cli-unfold-argument \
      --region $Region --Placement.Zone $Zone --InstanceType $InstanceType --ImageId $Image \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType \
      --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW --InstanceChargePrepaid.Period 1 \
      --secretId $1 --secretKey $2 \
      --InstanceCount 1 
  fi

  #yes DataDisks
  if [[ $3 == "YES" ]]; then
    count_datadisk=$((count_datadisk+1))
    tccli cvm InquiryPriceRunInstances --cli-unfold-argument \
      --region $Region --Placement.Zone $Zone --InstanceType $InstanceType --ImageId $Image \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType \
      --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW --InstanceChargePrepaid.Period 1 \
      --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType \
      --secretId $secretId --secretKey $secretKey \
      --InstanceCount 1
  fi
}

function price_cvm_hour() {

  #no DataDisks & no InternetAccessible
  if [[ $3 == "NO" ]]; then
    tccli cvm InquiryPriceRunInstances --cli-unfold-argument \
      --region $Region --Placement.Zone $Zone --InstanceType $InstanceType --ImageId $Image \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType \
      --InstanceChargeType $InstanceChargeType \
      --secretId $1 --secretKey $2 \
      --InstanceCount 1
  fi

  #yes DataDisks & no InternetAccessible
  if [[ $3 == "YES" ]]; then
    count_datadisk=$((count_datadisk+1))
    tccli cvm InquiryPriceRunInstances --cli-unfold-argument \
      --region $Region --Placement.Zone $Zone --InstanceType $InstanceType --ImageId $Image \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType \
      --InstanceChargeType $InstanceChargeType \
      --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType \
      --secretId $1 --secretKey $2 \
      --InstanceCount 1
  fi
}


#-------------------------------------------------------------------------------
#                                 Execute
#-------------------------------------------------------------------------------


while read -r line; do

  # reading each line
  n=$((n+1))

  if [[ ${n} == "1" ]] ; then
    echo "first Line"
    touch price_list.csv
    echo "$line,OriginalPrice,DiscountPrice,Discount" >> $file

  else

    echo "Start Create Line No. $n : $line"

    Region=`echo $line | awk -F ',' '{print $1}'`  
    Zone=`echo $line | awk -F ',' '{print $2}'`  
    InstanceType=`echo $line | awk -F ',' '{print $3}'`  
    Image=`echo $line | awk -F ',' '{print $4}'` 
    SystemDiskType=`echo $line | awk -F ',' '{print $5}'`  
    SystemDiskSize=`echo $line | awk -F ',' '{print $6}'`  
    DataDisks=`echo $line | awk -F ',' '{print $7}'`    
    InstanceChargeType=`echo $line | awk -F ',' '{print $10}'`

    if [[ $DataDisks == "YES" ]]; then
      DataDisksType=`echo $line | awk -F ',' '{print $8}'`  
      DataDisksSize=`echo $line | awk -F ',' '{print $9}'`
    fi
     


    case "$InstanceChargeType" in
      PREPAID) 
        echo "Start Check PREPAID CVM Price"
      
        count_prepaid=$((count_prepaid+1))
        if [[ $DataDisks == "YES" ]]; then
          count_datadisk=$((count_datadisk+1))
        fi
      
        if [[ $InternetAccessible == "YES" ]]; then
          count_ip=$((count_ip+1))
        fi
  
        price=`price_cvm_prepaid $secretId $secretKey $DataDisks | jq -r '.Price.InstancePrice | {OriginalPrice: .OriginalPrice, DiscountPrice: .DiscountPrice, Discount: .Discount} | join(",")'`

        if [[ -z "$price" ]]; then
          echo "empty"
          fail=$((fail+1))
          echo "$line,,," >> $file
        else
          echo "not empty"
          succese=$((succese+1))
          echo "$line,$price" >> $file
        fi
      ;;
      POSTPAID_BY_HOUR) 
        echo "Start Check HOUR CVM Price"

        count_hour=$((count_hour+1))
        if [[ $DataDisks == "YES" ]]; then
          count_datadisk=$((count_datadisk+1))
        fi
      
        if [[ $InternetAccessible == "YES" ]]; then
          count_ip=$((count_ip+1))
        fi
  
        price=`price_cvm_hour $secretId $secretKey $DataDisks | jq -r '.Price.InstancePrice | {OriginalPrice: .UnitPrice, DiscountPrice: .UnitPriceDiscount, Discount: .Discount} | join(",")'`      

        if [[ -z "$price" ]]; then
          echo "empty"
          fail=$((fail+1))
          echo "$line,,," >> $file
        else
          echo "not empty"
          succese=$((succese+1))
          echo "$line,$price" >> $file
        fi
      ;;
      *) echo "InstanceChargeType unknow"
    esac 

  fi

done < ${tmp}

echo "Succese: $succese | Fail: $fail | Total: $((n-1)) | 包年包月: ${count_prepaid} | 按量計費: ${count_hour} | DataDisk: ${count_datadisk} "
