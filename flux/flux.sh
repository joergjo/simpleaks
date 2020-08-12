REPO_USER="ivanthelad"
SSH_PRIVATE_KEY="$HOME/.ssh/githubid_rsa"
helm repo add fluxcd https://charts.fluxcd.io
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
kubectl create namespace flux

if [ -f "$SSH_PRIVATE_KEY" ]; then
    echo "$SSH_PRIVATE_KEY exists."
else 
    echo "$SSH_PRIVATE_KEY file does not exist. Generating"
    ssh-keygen -t rsa -f $SSH_PRIVATE_KEY -q -P ""
fi
## works 
## --sync-garbage-collection
## see  here for chart config https://github.com/fluxcd/flux/blob/master/chart/flux/values.yaml
kubectl create secret generic flux-git-deploy --from-file=identity=$SSH_PRIVATE_KEY -n flux
helm upgrade -i flux fluxcd/flux  -f values.yaml --set syncGarbageCollection.enabled=true  d --set sync.interval=2m --set git.url=git@github.com:ivanthelad/configrepo --set git-readonly=true   --set helm.versions=v3    --namespace flux --set git.secretName=flux-git-deploy --set registry.acr.enabled=true 
helm upgrade -i helm-operator fluxcd/helm-operator \
   --set git.ssh.secretName=flux-git-deploy  --set helm.versions=v3\
   --namespace flux

#helm upgrade -i flux fluxcd/flux --set sync.interval=2m --set git.url=git@github.com:$REPO/configrepo --set git-readonly=true   --set helm.versions=v3    --namespace flux  --set registry.acr.enabled=true 

## install operator 
#helm upgrade -i helm-operator fluxcd/helm-operator \
# --set helm.versions=v3\
#   --namespace flux