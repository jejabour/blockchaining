#!/bin/bash

# This script starts the containers that make up the blockchain and shells into the last container from which the client queries are executed.
singularity instance.start -B ../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/etc/hyperledger/msp/orderer,../network-config/basic-network/crypto-config/ordererOrganizations/example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./orderer:/var/hyperledger/production/orderer orderer.simg orderer
sleep 2
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer0:/var/hyperledger/production peer0.simg peer0
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer1:/var/hyperledger/production peer1.simg peer1
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer2:/var/hyperledger/production peer2.simg peer2
singularity shell -B ../network-config/basic-network/config:/opt/gopath/src/github.com/hyperledger/fabric/peer/,../network-config/basic-network/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ cli.simg