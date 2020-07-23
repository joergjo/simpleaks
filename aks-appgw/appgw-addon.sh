az feature register --name AKS-IngressApplicationGatewayAddon --namespace microsoft.containerservice
while true; do
 state=$(az feature list -o table --query "[?contains(name, 'microsoft.containerservice/AKS-IngressApplicationGatewayAddon')].{State:properties.state}" -o tsv)
 if [[ "$state" == "Registered" ]]; then 
    echo "is registered going to now register."
    break;
  else 
  echo "Not Registered"  
  fi

  echo "Trying again in 5 seconds"
  
sleep 5
done 

az provider register --namespace Microsoft.ContainerService
az extension add --name aks-preview
az extension update --name aks-preview



#az provider register --namespace Microsoft.ContainerService