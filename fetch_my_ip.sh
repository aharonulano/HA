#!/bin/bash

# Fetch the IP from ipinfo.io
LOCAL_IP=$(curl -s https://ipinfo.io/ip)

# Write the IP into a Terraform variables file
cat <<EOF > terraform.tfvars
remoteip = "${LOCAL_IP}"
EOF

echo "Generated terraform.tfvars with local_ip = ${LOCAL_IP}"
