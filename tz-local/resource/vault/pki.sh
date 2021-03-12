#!/usr/bin/env bash

# https://learn.hashicorp.com/tutorials/vault/pki-engine

#set -x
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

mkdir tmp
cd tmp
############################################################
## Step 1: Generate Root CA
############################################################
vault secrets disable pki
vault secrets enable \
  -description="PKI Root CA" \
  pki

vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
        common_name="example.com" \
        ttl=87600h > CA_cert.crt
cat ca_cert.crt
vault write pki/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

############################################################
# Step 2: Generate Intermediate CA
############################################################
vault secrets disable pki_int
vault secrets enable -path=pki_int pki
vault secrets list
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \
        common_name="example.com Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

############################################################
# Step 3: Create a Role
############################################################
vault write pki_int/roles/example-dot-com \
        allowed_domains="example.com" \
        allow_subdomains=true \
        max_ttl="720h"

############################################################
# Step 4: Request Certificates
############################################################
vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"

############################################################
# Step 5: Revoke Certificates
############################################################
vault write pki_int/revoke serial_number=48:5b:62:ca:a0:8c:7d:a7:46:54:ae:8b:d7:b3:b0:4b:14:9c:2d:c9

############################################################
# Step 6: Remove Expired Certificates
############################################################
vault write pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true

exit 0


