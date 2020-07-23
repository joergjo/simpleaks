# simpleaks
Simple script to bring up a AKS cluster that is integrated with ACR registry, Log Analytics and a Subnet. It deploy a seperated isolated VNET with APPGW. The AppGw will serve as the central ingrees point.   
* :warning: This script requires the AppGw addon to be enabled 
* :warning: This script requires that you have owner rights on the subscription. 
* :warning: The script requires a the App Gw preview to be used. a help script is provided to enable this `appgw-addon.sh`

If none of these are defined then the script will created them. The brings up a landscape with the following features. 
* Enables Autoscaler, sets a min and max node count. 
* integrated with a Registry so the cluster can pull images 
* Deploys Container insight 
* Configures a system node pool. Ensures system pods  are deployed across only system nodes 
* Worker nodes distributed across zones 
* Uses Kubenet routing 
* Uses a generated ssh key for backing vms
* App Gateway Vnet
* App Gateway public ip 
* App Gateway Instance 
The purpose is to ensure the AKS cluster and AKSvnet is not directly exposed to the internet and is always faced with an APPGW 

![GitHub Logo](/images/appgw.png)
# How to Deploy

* :warning: This script requires the AppGw addon preview to be enabled 
* :warning: This script requires that you have owner rights on the subscription. 
* :warning: This script requires that the SP has owner rights also
### Config setup
The script expects the following variables are set in a file called ./env.sh on relative path of `./simpleaks.sh.` Simply create this file or set the variables. The `env.sh` file is loaded as a source in `simpleAKS.sh`
* `SUBSCRIPTIONID`
* `SP_ID`
* `SP_PASS`
* `ACR_REGISTRY (optional)`
* `WORKSPACE_ID (optional)`
* `SUBNET_ID (optional`

```
## Subscription where everything will be deployed
SUBSCRIPTIONID=""
## Service principal for AKS. known as APPID
## https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#specify-a-service-principal-for-an-aks-cluster
SP_ID=""
## Service principal passwork
SP_PASS=""
## optional Azure Container Registry ID. If empty a new one will be created 
ACR_REGISTRY=""
## Optional Azure log analytics Workspace ID. If empty a new one will be created 
WORKSPACE_ID=""
## Optional Subnetid.AKS will be deployed into this subnet. If empty a new one will be created 
SUBNET_ID="" 
```
### Deploying the Cluster
The script expects one parameter which is used as the basis for all the resources. 
```./simpleAKS.sh letsgo```
The script will generate a random uuid to ensure the resource are unique within Azure. Mainly this is to ensure the Azure Container registry is unique. The about example will generate a random uuid, 0798c, and  resources with the following names 
* ResourceGroup: `letsgo-0798c`
* AKS: `letsgo-0798c`
* vnet: `letsgo-0798c`
* vnet: `letsgo-0798c-logs`
* Registry: `letsgo0798creg`


### Modify other configs 
```VM_SIZE=Standard_D2s_v3
MIN_NODE_COUNT=3
MAX_NODE_COUNT=4
KUBE_VERSION=1.17.7
LOCATION=westeurope
network_prefix='10.3.0.0/16'
network_aks_subnet='10.3.0.0/22'
network_aks_system='10.3.4.0/24'
LB_IDLE_TIMEOUT=10
OS_DISK_SIZE=50
## Some basic tags 
tags=`echo Environment=dev Project=minipoc Department=engineering`
pool_tags=`echo Environment=dev Project=minipoc Department=engineering` 

```

## Setup Flux and gitops 

### Prerequistes 
 * Ensure you are logged into the kubernetes cluster 
 * Fork git repo https://github.com/ivanthelad/configrepo
 * In flux.sh replace REPO_USER's value with the your user. The script will then deploy all resource from  https://github.com/$REPO_USER/configrepo 

Flux needs to authenicate against the git repo. We need to generate a ssh private key locally and upload public key to [git hub!](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account). First we need to generate a sshkey. if you already have an exiting key then simply reference it by  updating the field `SSH_PRIVATE_KEY` in `./flux.sh`
 * `ssh-keygen -t rsa -f ~/.ssh/githubid_rsa -q -P ""`
 * upload the generated key found under ` ~/.ssh/githubid_rsa.pub` to your github [account!](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) 
 ### Deploy flux
* execute the ./flux.sh scritp

 