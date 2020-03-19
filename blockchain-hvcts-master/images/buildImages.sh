#!/bin/bash

#Builds the four nodes required to start the network as singularity images. If a new node is to be built from a recipe file, It should be added here.
# Note that it deletes previous images. The build may take a while.
rm -f peer0.simg peer1.simg peer2.simg orderer.simg cli.simg
sudo singularity build peer0.simg Peer0Recipe
sudo singularity build peer1.simg Peer1Recipe
sudo singularity build peer2.simg Peer2Recipe
sudo singularity build orderer.simg OrdererRecipe
sudo singularity build cli.simg CLIRecipe