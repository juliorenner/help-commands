# https://kubernetes.io/docs/concepts/cluster-administration/certificates/#cfssl
# Create a private key
openssl genrsa -out username.key 2048

# Generate CSR
# CN (Common Name) is the username, O (Organization) is the Group
openssl req -new -key username.key -out username.csr -subj "/CN=username"


#The certificate request we'll use in the CertificateSigningRequest
cat username.csr


#The CertificateSigningRequest needs to be base64 encoded
#And also have the header and trailer pulled out.
cat username.csr | base64 | tr -d "\n" > username.base64.csr


#Submit the CertificateSigningRequest to the API Server
#Key elements, name, request and usages (must be client auth)
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: username
spec:
  groups:
  - system:authenticated  
  request: $(cat username.base64.csr)
  usages:
  - client auth
EOF


#Let's get the CSR to see it's current state. The CSR will delete after an hour
#This should currently be Pending, awaiting administrative approval
kubectl get certificatesigningrequests


#Approve the CSR
kubectl certificate approve username


#If we get the state now, you'll see Approved, Issued. 
#The CSR is updated with the certificate in .status.certificate
kubectl get certificatesigningrequests username 


#Retrieve the certificate from the CSR object, it's base64 encoded
kubectl get certificatesigningrequests username \
  -o jsonpath='{ .status.certificate }'  | base64 --decode


#Let's go ahead and save the certificate into a local file. 
#We're going to use this file to build a kubeconfig file to authenticate to the API Server with
kubectl get certificatesigningrequests username \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > username.crt 


#Check the contents of the file
cat username.crt


#Read the certficate itself
#Key elements: Issuer is our CA, Validity one year, Subject CN=usernames
openssl x509 -in username.crt -text -noout | head -n 15


#Now that we have the certificate we can use that to build a kubeconfig file with to log into this cluster.
#We'll use username.key and username.crt
#More on that in an upcoming demo
ls username.*
