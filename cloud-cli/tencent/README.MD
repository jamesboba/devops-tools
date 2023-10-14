# TencentCloud SDK - tccli command line

## Requirement
### Package
1. Python3 >= 3.7
2. pip3
3. Tencent Cloud User API Tonken
4. tccli SDK https://github.com/TencentCloud/tencentcloud-cli
### Install tccli
```bash
pip3 install tccli
tccli --version
```



## Feature
#### CVM(Create,Get)
#### CDB(Get)
#### Redis(Get)
```bash
├── CDB
│   ├── get_cdb_project_list_price.sh
│   ├── get_cdb_project_list.sh
├── CVM
│   ├── create_cvm.sh
│   ├── create_cvm_check.sh
│   ├── create_cvm_price_check.sh
│   ├── docker_create_cvm.sh
│   ├── get_cvm_project_list.sh
│   ├── get_cvm_project_list_price.sh
│   └── get_cvm_region_list.sh
├── Redis
│   ├── get_redis_project_list.sh
│   └── get_redis_project_list_price.sh
```

# How to use
## CVM
### get_cvm_project_list.sh

```bash
sh get_cvm_project_list.sh <secretId> <secretKey> <ProjectId> <Region>
```

### get_cvm_region_list.sh

```bash
sh get_cvm_region_list.sh <secretId> <secretKey> <Region>
```

### get_cvm_project_list_price.sh

```bash
sh get_cvm_project_list_price.sh <secretId> <secretKey> <ProjectId> <Region>sh
```

### create_cvm.sh

```bash
sh create_cvm.sh <secretId> <secretKey> <ProjectId> <CSV FileName>
```

### create_cvm_check.sh 

```bash
sh create_cvm_check.sh <secretId> <secretKey> <ProjectId> <CSV FileName>
```

### create_cvm_price_check.sh

```bash
sh create_cvm_price_check.sh <secretId> <secretKey> <CSV FileName>
```

## CDB
### get_cdb_project_list.sh
```bash
sh get_cdb_project_list.sh <secretId> <secretKey> <ProjectId> <Region>
```
### get_cdb_project_list_price.sh
```bash
sh get_cdb_project_list_price.sh <secretId> <secretKey> <ProjectId> <Region>
```

## Redis
### get_redis_project_list.sh
```bash
sh get_redis_project_list.sh <secretId> <secretKey> <ProjectId> <Region>
```
### get_redis_project_list_price.sh
```bash
sh get_redis_project_list_price.sh <secretId> <secretKey> <ProjectId> <Region>
```


# Docker tccli command(Option)

### create images
```bash
docker build -t gto/tccli:v1.0 -f Dockerfile .
docker run -itd gto/tccli bash
```
### privilege
```bash
usermod -aG docker jenkins
chmod 777 /var/run/docker.sock
```

### test 
```bash
docker exec -it tccli $command
docker exec -it tccli tccli --version
```