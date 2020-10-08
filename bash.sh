# Open-SSL
openssl x509 -in $CRT_FILE -text -noout
openssl x509 -in $CRT_FILE -text -noout | head

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
