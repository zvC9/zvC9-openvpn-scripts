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


#mkdir -p "created_files_for_use/client/generated/${netname}" || exit 1
#pushd    "created_files_for_use/client/generated/${netname}" || exit 2

mkdir -p "created_files_for_use/client" || exit 1
pushd    "created_files_for_use/client" || exit 2


# not for android
cat > "${netname}-tls-client.conf" << EOF
mode p2p
# local 192.168.0.50
remote $server_public_ip $server_udp_port udp
float
connect-retry 3 7
## you can use hostname for server (it gets resolved)
resolv-retry infinite
nobind
dev ${netname}-clt
# dev-type tun
dev-type tap
#topology p2p
#topology net30
#topology subnet
topology subnet
#ifconfig  $client_private_ip  $subnet_netmask

pull

mssfix 1400
ping 3
ping-restart 8
persist-tun
tls-client

ca generated/${netname}/${netname}-ca.selfsigned.cert.pem
#dh output/dh.pem
cert generated/${netname}/${netname}-tls-client.ca-signed.cert.pem
key generated/${netname}/${netname}-tls-client.key.pem
tls-auth generated/${netname}/tls-auth-c0-s1.key 0
tls-auth generated/${netname}/tls-auth-c1-s0.key 1

tls-timeout 10
reneg-bytes 600485760
reneg-sec 60
# remote name
verify-x509-name ${netname}-tls-server name
cipher AES-256-CBC
tls-version-min 1.3

## route ip mask gw
## uncomment, if you want to route packets via server
#route 0.0.0.0   0.0.0.0
route-metric 34000
route-nopull
#route   0.0.0.0   0.0.0.0   $server_private_ip   5000
route-gateway $server_private_ip
route 0.0.0.0 0.0.0.0
EOF

popd

#mkdir -p "created_files_for_use/server/generated/${netname}" || exit 1
#pushd    "created_files_for_use/server/generated/${netname}" || exit 2

mkdir -p "created_files_for_use/server" || exit 3
pushd    "created_files_for_use/server" || exit 4

cat > "${netname}-tls-server.conf" << EOF
mode server
#mode p2p
#remote example.net 1194 udp
## if your interface has this address and you only listen on it (don't use if you are behind a router/gateway/NAT)
# local $server_public_ip
lport $server_udp_port
float
#nobind
dev ${netname}-srv
#dev-type tun
dev-type tap
#topology p2p
#topology net30
#topology subnet
topology subnet
ifconfig  $server_private_ip ${subnet_netmask}
ifconfig-pool $ifconfig_pool
#ifconfig-pool 10.12.12.2 10.12.12.254 255.255.255.0
#push "route-gateway $server_private_ip"
###push "route-gateway dhcp"
mssfix 1400
ping 3
ping-restart 8
persist-tun
tls-server
#ca dir/openssl/ca/ca.pem
#dh dir/openssl/dh/dh.pem
#cert dir/openssl/users/tls-server/tls-server.cert.pem
#key dir/openssl/users/tls-server/tls-server.key

ca generated/$netname/${netname}-ca.selfsigned.cert.pem
dh generated/$netname/${netname}-dh.pem
cert generated/$netname/${netname}-tls-server.ca-signed.cert.pem
key generated/$netname/${netname}-tls-server.key.pem
tls-auth generated/${netname}/tls-auth-c0-s1.key 1
tls-auth generated/${netname}/tls-auth-c1-s0.key 0

tls-timeout 10
reneg-bytes 600485760
reneg-sec 60
# remote name
#verify-x509-name ${netname}-tls-client name
cipher AES-256-CBC
#route   0.0.0.0   0.0.0.0   $client_private_ip   5000
#route 0.0.0.0   0.0.0.0
route-metric 34000
route-nopull
tls-version-min 1.3
EOF

popd

echo "You have to MANUALLY EDIT GENERATED OpenVPN CONFIGS"


