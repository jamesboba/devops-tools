#!/bin/bash

datetime=$(date +%Y%m%d-%H%M)

#-------------------------------------------------------------------------------
#                                 Upload
#-------------------------------------------------------------------------------

#cd "${WORKSPACE}"
#mkdir -p "${ProjectId}_${datetime}"
#cat -v CVM_List | sed -e 's/\^M//g' >> List
#echo "" >> List
#rm -rf CVM_List
#mv List ${ProjectId}_${datetime}
#cd ${ProjectId}_${datetime}

#-------------------------------------------------------------------------------
#                               Functions
#-------------------------------------------------------------------------------

function create_cvm_prepaid() {

  count_prepaid=$((count_prepaid+1))

  secretId=$1
  secretKey=$2
  DataDisks=$3
  InternetAccessible=$4

  #no DataDisks & no InternetAccessible
  if [[ $DataDisks == "NO" && $InternetAccessible == "NO" ]]; then
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1
      --InstanceChargeType $InstanceChargeType \
      --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW \
      --InstanceChargePrepaid.Period 1 \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
     echo a
  fi

  #no DataDisks & yes InternetAccessible
  if [[ $DataDisks == "NO" && $InternetAccessible == "YES" ]]; then
    
    count_ip=$((count_ip+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW \
      --InstanceChargePrepaid.Period 1 \
      --InternetAccessible.PublicIpAssigned TRUE \
      --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE \
      --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
     echo b
  fi

  #yes DataDisks & no InternetAccessible
  if [[ $DataDisks == "YES" && $InternetAccessible == "NO" ]]; then
  
    count_datadisk=$((count_datadisk+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW \
      --InstanceChargePrepaid.Period 1 \
      --DataDisks.0.DiskSize $DataDisksSize \
      --DataDisks.0.DiskType $DataDisksType \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
  	echo c
  fi

  #yes DataDisks & yes InternetAccessible
  if [[ $DataDisks == "YES" && $InternetAccessible == "YES" ]]; then
  
    count_ip=$((count_ip+1))
    count_datadisk=$((count_datadisk+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --InstanceChargePrepaid.RenewFlag NOTIFY_AND_AUTO_RENEW \
      --InstanceChargePrepaid.Period 1 \  
      --DataDisks.0.DiskSize $DataDisksSize \
      --DataDisks.0.DiskType $DataDisksType \  
      --InternetAccessible.PublicIpAssigned TRUE \
      --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE \
      --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
  	echo d
  
  fi

}

function create_cvm_hour() {

  count_hour=$((count_hour+1))

  secretId=$1
  secretKey=$2
  DataDisks=$3
  InternetAccessible=$4

  #no DataDisks & no InternetAccessible
  if [[ $DataDisks == "NO" && $InternetAccessible == "NO" ]]; then

    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "

     echo e
  fi

  #no DataDisks & yes InternetAccessible
  if [[ $DataDisks == "NO" && $InternetAccessible == "YES" ]]; then
  
    count_ip=$((count_ip+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --InternetAccessible.PublicIpAssigned TRUE \
      --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE \
      --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
     echo f
  fi

  #yes DataDisks & no InternetAccessible
  if [[ $DataDisks == "YES" && $InternetAccessible == "NO" ]]; then
  
    count_datadisk=$((count_datadisk+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --DataDisks.0.DiskSize $DataDisksSize \
      --DataDisks.0.DiskType $DataDisksType \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
    echo g
  fi

  #yes DataDisks & yes InternetAccessible
  if [[ $DataDisks == "YES" && $InternetAccessible == "YES" ]]; then
  
    count_ip=$((count_ip+1))
    count_datadisk=$((count_datadisk+1))
    docker exec tccli bash -c " \
    tccli cvm RunInstances --cli-unfold-argument \
      --region $Region \
      --Placement.ProjectId $ProjectId \
      --Placement.Zone $Zone \
      --InstanceName $InstanceName \
      --HostName $InstanceName \
      --InstanceType $InstanceType \
      --ImageId $Image \
      --LoginSettings.Password $LoginSettingsPassword \
      --SystemDisk.DiskSize $SystemDiskSize \
      --SystemDisk.DiskType $SystemDiskType \
      --VirtualPrivateCloud.SubnetId $SubnetId \
      --VirtualPrivateCloud.VpcId $VpcId \  
      --SecurityGroupIds $SecurityGroupIds \
      --InstanceCount 1 \
      --InstanceChargeType $InstanceChargeType \
      --DataDisks.0.DiskSize $DataDisksSize \
      --DataDisks.0.DiskType $DataDisksType \
      --InternetAccessible.PublicIpAssigned TRUE \
      --InternetAccessible.InternetChargeType BANDWIDTH_PACKAGE \
      --InternetAccessible.InternetMaxBandwidthOut 65535 \
      --secretId $secretId \
      --secretKey $secretKey \
      --DryRun TRUE "
     echo h 
  fi

}


function get_subnet_id() {

  tccli vpc DescribeVpcs --cli-unfold-argument \
    --Limit 20 \
    --secretId $secretId \
    --secretKey $secretKey \
    --Filters.0.Values $VpcId \
    --Filters.0.Name VpcId \
    --Offset 0 > subnet_id.txt

}

function get_security_group_id() {
 echo "first Line"

}

function check_cvm_status() {
 echo "first Line"

}

function check_vpc_id() {
 echo "first Line"

}

function check_subnet_id() {
 echo "first Line"

}

#-------------------------------------------------------------------------------
#                                 Execute
#-------------------------------------------------------------------------------

filename='List'
ProjectId=$ProjectId
secretId=$secretId 
secretKey=$secretKey

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
     
    
    if [[ $InstanceChargeType == "PREPAID" ]] ; then
      echo "Start Create PREPAID CVM"
      create_cvm_prepaid $secretId $secretKey $DataDisks $InternetAccessible
    elif [[ $InstanceChargeType == "PAID_BY_HOUR" ]] ; then
      echo "Start Create HOUR CVM"
      create_cvm_hour $secretId $secretKey $DataDisks $InternetAccessible
    fi  

  fi

done < ${filename}

echo "Total: $((n-1)) | 包年包月: ${count_prepaid} | 按量計費: ${count_hour} | Public IP: ${count_ip} | DataDisk: ${count_datadisk} "








