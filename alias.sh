alias k='kubectl '
alias kpoa='kubectl get pods --all-namespaces '
alias kpv='kubectl get pv '
alias kpvc='kubectl get pvc '
alias kd='kubectl describe '
alias kdhc='kubectl get dhcluster -o=custom-columns=NAME:.metadata.name,STATE:.status.state,SHOOT:.status.clusterName,VERSION:.status.version '
alias kdel="kubectl delete "
alias kdelf="kubectl delete --force --grace-period=0 "
alias kc="kubectl create "
alias ke="kubectl edit "
alias kg="kubectl get "
alias kgt="kubectl get --sort-by=.metadata.creationTimestamp "
alias kall="kubectl get all --all-namespaces "
alias kpo="kubectl get pods --all-namespaces "
alias kci="kubectl cluster-info "
alias kuc="kubectl config use-context "
alias kpf="kubectl port-forward "
alias kl="kubectl logs --tail=20 -f "
alias klf="kubectl logs -f "
alias myk="printenv KUBECONFIG "
alias ka="kubectl apply "
alias ke="kubectl edit "
alias kgy="kubectl get -oyaml "
alias node-resources='kubectl get nodes --no-headers | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''
kns ()
{
    kubectl config set-context $(kubectl config current-context) --namespace ${1}
}
