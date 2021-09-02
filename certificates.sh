# View certificate
openssl x509 -in $CRT_FILE -text -noout

# View CSR
openssl req -in $CSR_FILE -noout -text

# CA Certificate

## Create private key for CA
openssl genrsa -out ca.key 2048

## Comment line starting with RANDFILE in /etc/ssl/openssl.cnf definition to avoid permission issues
sudo sed -i '0,/RANDFILE/{s/RANDFILE/\#&/}' /etc/ssl/openssl.cnf

## Create CSR using the private key
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

## Self sign the csr using its own private key
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000

# Admin client certificate

## Generate private key for admin user
openssl genrsa -out admin.key 2048

## Generate CSR for admin user. Note the OU.
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr

## Sign certificate for admin user using CA servers private key
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out admin.crt -days 1000

# More commands on certificates: https://github.com/mmumshad/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md
