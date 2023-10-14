#!/bin/bash

#-------------------------------------------------------------------------------
#                       Comfirm Input & Store Data Path
#-------------------------------------------------------------------------------

datetime=$(date +%Y-%m-%d-%H:%M:%S)

if [ $# -ne 4 ]; then

 echo "使用方式：$0 <secretId> <secretKey> <ProjectId> <CSV FileName>"

 exit 0
fi

secretId=$1
secretKey=$2
ProjectId=$3
filename=$4
tmp="${ProjectId}_cvm_list.csv"

#Store path
mkdir -p "${ProjectId}/${datetime}"
cat -v $4 | sed -e 's/\^M//g' >> $tmp
echo "" >> $tmp
mv $4 ${ProjectId}/${datetime}
mv $tmp ${ProjectId}/${datetime}
cd ${ProjectId}/${datetime}


#-------------------------------------------------------------------------------
#                               Functions
#-------------------------------------------------------------------------------

function create_cvm_prepaid() {

  #no DataDisks & no InternetAccessible
  if [[ $3 == "NO" && $4 == "NO" ]]; then

    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName --InstanceType $InstanceType \
      --ImageId $Image --LoginSettings.Password $LoginSettingsPassword --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId --VirtualPrivateCloud.VpcId $VpcId \
      --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW \
      --InstanceChargePrepaid.Period 1 --secretId $1 --secretKey $2
  fi

  #no DataDisks & yes InternetAccessible
  if [[ $3 == "NO" && $4 == "YES" ]]; then
    
    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW --InstanceChargePrepaid.Period 1 \
      --InternetAccessible.PublicIpAssigned TRUE --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $1 --secretKey $2
  fi

  #yes DataDisks & no InternetAccessible
  if [[ $3 == "YES" && $4 == "NO" ]]; then
  
    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW --InstanceChargePrepaid.Period 1 \
      --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType --secretId $1 \
      --secretKey $2
  fi

  #yes DataDisks & yes InternetAccessible
  if [[ $3 == "YES" && $4 == "YES" ]]; then

    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW --InstanceChargePrepaid.Period 1 \
      --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType --InternetAccessible.PublicIpAssigned TRUE \
      --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE --InternetAccessible.InternetMaxBandwidthOut 65535 --secretId $1 \
      --secretKey $2
  fi

}

function create_cvm_hour() {

  #no DataDisks & no InternetAccessible
  if [[ $3 == "NO" && $4 == "NO" ]]; then

    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --secretId $1 --secretKey $2
  fi

  #no DataDisks & yes InternetAccessible
  if [[ $3 == "NO" && $4 == "YES" ]]; then

    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --InternetAccessible.PublicIpAssigned TRUE --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE \
      --InternetAccessible.InternetMaxBandwidthOut 65535 --secretId $1 --secretKey $2
  fi

  #yes DataDisks & no InternetAccessible
  if [[ $3 == "YES" && $4 == "NO" ]]; then

    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType \
      --secretId $1 --secretKey $2
  fi

  #yes DataDisks & yes InternetAccessible
  if [[ $3 == "YES" && $4 == "YES" ]]; then
  
    tccli cvm RunInstances --cli-unfold-argument --region $Region --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone --InstanceName $InstanceName --HostName $InstanceName \
      --InstanceType $InstanceType --ImageId $Image --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize --SystemDisk.DiskType $SystemDiskType --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId --SecurityGroupIds $SecurityGroupIds --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType --DataDisks.0.DiskSize $DataDisksSize --DataDisks.0.DiskType $DataDisksType \
      --InternetAccessible.PublicIpAssigned TRUE --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $1 --secretKey $2
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

  else

    echo "Start Create Line No. $n : $line"

    Region=`echo $line | awk -F ',' '{print $1}'`  
    Zone=`echo $line | awk -F ',' '{print $2}'`  
    VpcId=`echo $line | awk -F ',' '{print $3}'` 
    SubnetId=`echo $line | awk -F ',' '{print $4}'`  
    InstanceName=`echo $line | awk -F ',' '{print $5}'`  
    InstanceType=`echo $line | awk -F ',' '{print $6}'`  
    Image=`echo $line | awk -F ',' '{print $7}'` 
    SystemDiskType=`echo $line | awk -F ',' '{print $8}'`  
    SystemDiskSize=`echo $line | awk -F ',' '{print $9}'`  
    DataDisks=`echo $line | awk -F ',' '{print $10}'`    
    InternetAccessible=`echo $line | awk -F ',' '{print $13}'` 
    InstanceChargeType=`echo $line | awk -F ',' '{print $14}'` 
    LoginSettingsPassword=`echo $line | awk -F ',' '{print $15}'`  
    SecurityGroupIds=`echo $line | awk -F ',' '{print $16}'`
    
    if [[ $DataDisks == "YES" ]]; then
      DataDisksType=`echo $line | awk -F ',' '{print $11}'`  
      DataDisksSize=`echo $line | awk -F ',' '{print $12}'`
    fi
     
    
    case "$InstanceChargeType" in
      PREPAID) 
        echo "Start Create PREPAID CVM"
      
        count_prepaid=$((count_prepaid+1))
        if [[ $DataDisks == "YES" ]]; then
          count_datadisk=$((count_datadisk+1))
        fi
      
        if [[ $InternetAccessible == "YES" ]]; then
          count_ip=$((count_ip+1))
        fi
  
        cvm=`create_cvm_prepaid $secretId $secretKey $DataDisks $InternetAccessible | jq -r '.InstanceIdSet'`
  
        if [[ ${cvm} != null ]]; then
          fail=$((fail+1))
          echo "${cvm}"
        else
          succese=$((succese+1))
          echo "${cvm}"
        fi
      ;;
      POSTPAID_BY_HOUR) 
        echo "Start Create HOUR CVM"

        count_hour=$((count_hour+1))
        if [[ $DataDisks == "YES" ]]; then
          count_datadisk=$((count_datadisk+1))
        fi
      
        if [[ $InternetAccessible == "YES" ]]; then
          count_ip=$((count_ip+1))
        fi
  
        cvm=`create_cvm_hour $secretId $secretKey $DataDisks $InternetAccessible | jq -r '.InstanceIdSet'`
        
        if [[ ${cvm} != null ]]; then
          fail=$((fail+1))
          echo "${cvm}"
        else
          succese=$((succese+1))
          echo "${cvm}"
        fi
      ;;
      *) echo "InstanceChargeType unknow"
    esac 

  fi

done < $tmp

echo "包年包月: ${count_prepaid} | 按量計費: ${count_hour} | Public IP: ${count_ip} | DataDisk: ${count_datadisk} | Succese: $succese | Fail: $fail "