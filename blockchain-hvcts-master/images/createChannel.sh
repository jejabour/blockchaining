#!/bin/bash

rm mychannel.block
peer channel create -o 127.0.0.1:7050 -f ../network-config/basic-network/config/channel.tx -c mychannel
peer channel join -b mychannel.block