#!/bin/bash
# Generating self-signed key manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:State
 #Locality Name (eg, city) []:City
 #Organization Name (eg, company) [Internet Widgits ...]:Company
 #Organizational Unit Name (eg, section) []:Section
 #Common Name (e.g. server FQDN or YOUR name) []:ca
 #Email Address []:

source bashlib/openvpn-openssl-vars.bash || exit 1


mkdir -p "created_files_for_use/server/generated/${netname}" || exit 1
pushd    "created_files_for_use/server/generated/${netname}" || exit 2


openssl dhparam -outform PEM -out ${netname}-dh.pem  $dhbits

