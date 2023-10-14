#!/bin/bash
#======================================================================
#
#       FILE: get-aws-resource.sh
#
#       USAGE:
#             SSO
#             sh get-aws-resource.sh <env> <account> <region> <resource>
#             NO SSO
#             sh get-aws-resource.sh <env> default <region> <resource>
#
#       AUTHOR: 
#       CREATED: 2023/08/09
#======================================================================


#------------------------------------
#              Input
#------------------------------------
env=$1
account=$2
region=$3
resource=$4
datetime=$(date +%Y-%m-%d-%H:%M:%S)

# read -p "" env
# read -p "" account
# read -p "" region
# read -p "" resource

if [ $# -ne 4 ]; then
  echo ""
  echo "Please Input: sh $0 <env> <account> <region> <resource>"
  echo ""
  echo "Sample : "
  echo ""
  echo "sh $0 alpha APP-OPS us-east-1 vpc"
  echo ""
  echo "sh $0 alpha default us-east-1 vpc"
  echo ""
  exit 0
fi

if [[ $env == "alpha" || $env == "prod" ]]; then
  echo "Env: $env"
else
  echo "Unknow Env: $env"
  echo ""
  echo "Use Env: alpha,prod"
  exit 0
fi

#FilePath
Store_Path="data/${env}/${account}/${region}/${datetime}"
mkdir -p ${Store_Path}
cd ${Store_Path}

#------------------------------------
#              Functions
#------------------------------------

function get_vpc {

  if [ $account == "default" ]; then
    aws ec2 describe-vpcs --region $region --output json > aws-${env}-${account}-${region}-vpc.json
  else
    aws ec2 describe-vpcs --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-vpc.json
  fi
  cat aws-${env}-${account}-${region}-vpc.json | jq -r '.Vpcs[] | {Name: .Tags[0].Value,VpcId: .VpcId,CidrBlock: .CidrBlock,State: .State} | join(",")' | sort > aws-${env}-${account}-${region}-vpc.csv
  echo ""
  echo "get_vpc list"
  echo ""
}


function get_subnet {

  if [ $account == "default" ]; then
    aws ec2 describe-subnets --region $region --output json > aws-${env}-${account}-${region}-subnet.json
  else
    aws ec2 describe-subnets --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-subnet.json
  fi
  cat aws-${env}-${account}-${region}-subnet.json | jq -r '.Subnets[] | {AvailabilityZone: .AvailabilityZone,Name: .Tags[0].Value,VpcId: .VpcId,SubnetId: .SubnetId,CidrBlock: .CidrBlock,State: .State} | join(",")' | sort > aws-${env}-${account}-${region}-subnet.csv
  echo ""
  echo "get_subnet list"
  echo ""

}

function get_ip {

  if [ $account == "default" ]; then
    aws ec2 describe-addresses --region $region --output json > aws-${env}-${account}-${region}-ip.json
  else
    aws ec2 describe-addresses --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-ip.json
  fi
  cat aws-${env}-${account}-${region}-ip.json | jq -r '.Addresses[] | {Name: .Tags[0].Value,AllocationId: .AllocationId,PublicIp: .PublicIp,PrivateIpAddress: .PrivateIpAddress,InstanceId: .InstanceId} | join(",")' | sort > aws-${env}-${account}-${region}-ip.csv
  echo ""
  echo "get_ip list"
  echo ""
}

function get_nat {

  if [ $account == "default" ]; then
    aws ec2 describe-nat-gateways --region $region --output json > aws-${env}-${account}-${region}-nat.json
  else
    aws ec2 describe-nat-gateways --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-nat.json
  fi
  cat aws-${env}-${account}-${region}-nat.json | jq -r '.NatGateways[] | {Name: .Tags[0].Value,PublicIp: .NatGatewayAddresses[0].PublicIp,PrivateIp: .NatGatewayAddresses[0].PrivateIp,NatGatewayId: .NatGatewayId,VpcId: .VpcId,SubnetId: .SubnetId,ConnectivityType: .ConnectivityType,Status: .NatGatewayAddresses[0].Status} | join(",")' | sort > aws-${env}-${account}-${region}-nat.csv
  echo ""
  echo "get_nat list"
  echo ""
}

function get_lb {

  if [ $account == "default" ]; then
    aws elbv2 describe-load-balancers --region $region --output json > aws-${env}-${account}-${region}-lb.json
  else
    aws elbv2 describe-load-balancers --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-lb.json
  fi
  cat aws-${env}-${account}-${region}-lb.json | jq -r '.LoadBalancers[] | {LoadBalancerName: .LoadBalancerName,LoadBalancerArn: .LoadBalancerArn,DNSName: .DNSName,Type: .Type,Scheme: .Scheme} | join(",")' | sort > aws-${env}-${account}-${region}-lb.csv
  echo ""
  echo "get_lb list"
  echo ""
}

function get_tg {

  if [ $account == "default" ]; then
    aws elbv2 describe-target-groups --region $region --output json > aws-${env}-${account}-${region}-tg.json
  else
    aws elbv2 describe-target-groups --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-tg.json
  fi
  cat aws-${env}-${account}-${region}-tg.json | jq -r '.TargetGroups[] | {TargetGroupName: .TargetGroupName,Protocol: .Protocol,Port: .Port,TargetType: .TargetType,LoadBalancerArns: .LoadBalancerArns[0]} | join(",")' | sort > aws-${env}-${account}-${region}-tg.csv
  echo ""
  echo "get_tg list"
  echo ""
}

function get_ec2 {

  if [ $account == "default" ]; then
    aws ec2 describe-instances --region $region --output json > aws-${env}-${account}-${region}-ec2.json
  else
    aws ec2 describe-instances --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-ec2.json
  fi
  cat aws-${env}-${account}-${region}-ec2.json | jq -r '.Reservations[].Instances[] | {Name: (.Tags[]?|select(.Key=="Name")|.Value),InstanceId: .InstanceId,InstanceType: .InstanceType,ImageId: .ImageId,PlatformDetails: .PlatformDetails,Architecture: .Architecture,PublicIpAddress: .PublicIpAddress,PrivateIpAddress: .PrivateIpAddress,VpcId: .VpcId,SubnetId: .SubnetId,State: .State.Name} | join(",")' | sort > aws-${env}-${account}-${region}-ec2.csv
  echo ""
  echo "get_ec2 list"
  echo ""
}

function get_sg {

  if [ $account == "default" ]; then
    aws ec2 describe-security-groups --region $region --output json > aws-${env}-${account}-${region}-sg.json
  else
    aws ec2 describe-security-groups --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-sg.json
  fi
  cat aws-${env}-${account}-${region}-sg.json | jq '[ .SecurityGroups[].IpPermissions[] as $a | { "ports": [($a.FromPort|tostring),($a.ToPort|tostring)]|unique, "cidr": $a.IpRanges[].CidrIp } ] | [group_by(.cidr)[] | { (.[0].cidr): [.[].ports|join("-")]|unique }] | add' > aws-${env}-${account}-${region}-sg.csv
  jq -M -r -f /Users/h0341/Documents/Hytech/filter.jq aws-${env}-${account}-${region}-sg.json | grep "0.0.0.0/0" | grep -v "OUTBOUND" > aws-${env}-${account}-${region}-sg-issue.csv
  echo ""
  echo "get_sg list"
  echo ""
}

function get_rds {

  if [ $account == "default" ]; then
    aws rds describe-db-instances --region $region --output json > aws-${env}-${account}-${region}-rds.json
  else
    aws rds describe-db-instances --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-rds.json
  fi
  cat aws-${env}-${account}-${region}-rds.json | jq -r '.DBInstances[] | {DBInstanceClass: .DBInstanceClass,DBInstanceIdentifier: .DBInstanceIdentifier,AllocatedStorage: .AllocatedStorage,EngineVersion: .EngineVersion} | join(",")' | sort > aws-${env}-${account}-${region}-rds.csv
  echo ""
  echo "get_rds list"
  echo ""
}

function get_redis {

  if [ $account == "default" ]; then
    aws elasticache describe-cache-clusters --region $region --output json > aws-${env}-${account}-${region}-redis.json
  else
    aws elasticache describe-cache-clusters --region $region --output json --profile ${account} > aws-${env}-${account}-${region}-redis.json
  fi
  cat aws-${env}-${account}-${region}-redis.json | jq -r '.CacheClusters[] | {CacheClusterId: .CacheClusterId,CacheNodeType: .CacheNodeType,Engine: .Engine,EngineVersion: .EngineVersion} | join(",")' | sort > aws-${env}-${account}-${region}-redis.csv
  echo ""
  echo "get_redis list"
  echo ""
}

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

echo ""
echo "Account: $account"
echo ""
echo "Resource: $resource"
echo ""

case "$resource" in
    ec2) get_ec2 
        ;;
    tg) get_tg
        ;;
    lb) get_lb
        ;;
    nat) get_nat
        ;;
    ip) get_ip
        ;;
    subnet) get_subnet
        ;;
    vpc) get_vpc
        ;;
    sg) get_sg
        ;;
    redis) get_redis
        ;;
    rds) get_rds
        ;;
    cdn) get_cdn
        ;;
    all) get_vpc
         get_subnet
         get_ip
         get_nat
         get_lb
         get_tg
         get_ec2
         get_sg
         get_redis
         get_rds
         get_cdn
        ;;
    *) echo "Unknow Resource $resource "
       echo "Use Resource : vpc,subnet,ip,nat,lb,tg,ec2,sg"
       exit 0
esac