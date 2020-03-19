#!/bin/bash

read -p "WARNING! This operation deletes the complete blockchain to start from scratch. Do you wish to continue?" -r

if [[ $REPLY =~ ^[Yy]$ ]]
then

singularity instance.stop peer* orderer

rm -rf peer0
rm -rf peer1
rm -rf peer2
rm -rf orderer
mkdir peer0
mkdir peer1
mkdir peer2
mkdir orderer

echo "Starting nodes"
singularity instance.start -B ../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/etc/hyperledger/msp/orderer,../network-config/basic-network/crypto-config/ordererOrganizations/example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./orderer:/var/hyperledger/production/orderer orderer.simg orderer
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer0:/var/hyperledger/production peer0.simg peer0
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer1:/var/hyperledger/production peer1.simg peer1
singularity instance.start -B ../network-config/bin:/usr/local/bin,../network-config/config:/etc/hyperledger/fabric,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/peers/peer2.org1.example.com/msp:/etc/hyperledger/msp/peer,../network-config/basic-network/crypto-config/peerOrganizations/org1.example.com/users:/etc/hyperledger/msp/users,../network-config/basic-network/config:/etc/hyperledger/configtx,./peer2:/var/hyperledger/production peer2.simg peer2

echo "Waiting for nodes to initialize."
sleep 5

singularity exec -B ../network-config/basic-network/config:/opt/gopath/src/github.com/hyperledger/fabric/peer/,../network-config/basic-network/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ cli.simg ./createChannel.sh
echo "Waiting for channel creation."
echo "Waiting for channel transaction to commit"
sleep 10

singularity instance.stop peer* orderer
echo "Blockchain setup finalized."

else
echo "Operation canceled."
fi