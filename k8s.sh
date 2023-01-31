# Open-SSL
openssl x509 -in $CRT_FILE -text -noout
openssl x509 -in $CRT_FILE -text -noout | head

# Write to file:

cat > k8s-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: demouser
spec:
  groups:
  - system:authenticated
  request: $(cat demouser.base64.csr)
  usages:
  - client auth
EOF


# Kubernetes

## Extract the client certificate
kubectl config view --raw -o jsonpath='{ .users[*].user.client-certificate-data }' | base64 --decode > admin.crt

## Use to "-v 6" to see the API requests
kubectl get pods -v 6

## Execute request to API Server with CURL from inside a pod
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

## API Discovery Roles: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#discovery-roles
curl --cacert $CACERT --header "Authorization: Bearer $TOKEN" -X GET https://kubernetes.default.svc/api/

## Use impersonation to execute authorization testing
# kubectl auth can-i list pods --as=system:serviceaccount:$NAMESPACE:$SVC_ACCOUNT
# kubectl get pods -v 6 --as=system:serviceaccount:$NAMESPACE:$SVC_ACCOUNT
kubectl auth can-i list pods --as=system:serviceaccount:default:default
kubectl get pods -v 6 --as=system:serviceaccount:default:default

## Change kubeconfig context
kubectl config get-contexts
kubectl config use-context $CONTEXT_NAME

## Get public certificate of K8S CA
k config view --raw \
-o jsonpath='{ .clusters[0].cluster.certificate-authority-data }' | base64 -D > ca.crt


## Create kubeconfig
openssl genrsa -out demouser.key 2048
openssl req -new -key demouser.key -out demouser.csr -subj "/CN=USERNAME_HERE"
#The CertificateSigningRequest needs to be base64 encoded
#And also have the header and trailer pulled out.
cat demouser.csr | base64 | tr -d "\n" > demouser.base64.csr

#Submit the CertificateSigningRequest to the API Server
#Key elements, name, request and usages (must be client auth)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: demouser
spec:
  groups:
  - system:authenticated  
  request: $(cat demouser.base64.csr)
  usages:
  - client auth
EOF

kubectl get certificatesigningrequests

kubectl certificate approve demouser

kubectl get certificatesigningrequests demouser \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > demouser.crt 

kubectl create clusterrolebinding demouserclusterrolebinding \
  --clusterrole=view --user=demouser

#Create the cluster entry, notice the kubeconfig parameter, this will generate a new file using that name.
# embed-certs puts the cert data in the kubeconfig entry for this user
kubectl config set-cluster kubernetes-demo \
  --server=https://172.16.94.10:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=demouser.conf

#Add user to new kubeconfig file demouser.conf
#Keep in mind there's several authentication methods, we're focusing on certificates here
kubectl config set-credentials demouser \
  --client-key=demouser.key \
  --client-certificate=demouser.crt \
  --embed-certs=true \
  --kubeconfig=demouser.conf

#Add the context, context name, cluster name, user name
kubectl config set-context demouser@kubernetes-demo  \
  --cluster=kubernetes-demo \
  --user=demouser \
  --kubeconfig=demouser.conf

#Set the current-context in the kubeconfig file
#Set the context in the file this is a per kubeconfig file setting
kubectl config use-context demouser@kubernetes-demo --kubeconfig=demouser.conf


# Get all namespace secret values with kdecode
kubectl get secrets -oname --no-headers | awk -F '/' '{print $2}' | xargs -I {} sh -c 'echo {}; kdecode {}'
