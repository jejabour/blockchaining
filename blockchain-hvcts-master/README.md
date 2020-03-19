# Asset Tracking System using Blockchain

This project is a proof of concept to demonstrate how an asset tracking system could be developed using blockchain. The blockchain was built using [Hyperledger Fabric v1.3](https://hyperledger-fabric.readthedocs.io/en/release-1.3/). For more information about their implementation details, refer to their documentation. 

## Requirements

- MacOS or Linux
- [Singularity](https://singularity.lbl.gov/docs-installation) 2.4 or higher.

## Quick Start 

This guide shows how to build and use the default configuration for the blockchain network that comes with the project using 3 peer nodes and 1 orderer node. 

The first thing to do is to build the singularity images that will be used to start the containers which will act as the nodes in the network. Go to the *images* directory and run the *buildImages* bash script:

```bash
# Within the project root directory
cd ./images
./buildImages.sh
```

This will create five image files called peer0.simg, peer1.simg, peer2.simg, orderer.simg and cli.simg, in the current directory. 

Next, run the *initialSetup* bash script:

```bash
# Within the project root directory
cd ./images
./initialSetup.sh # NOTE: ONLY USED ONCE ON FIRST TIME SETUP! Running it again erases all blockchain data. Useful for development.
```
This will create the directories that will be used by the containers to store the blockchain, start the constainers so that Hyperledger does all the initial setup on each node, create a channel of communication between the nodes in the network, and finally shut down the network in a state ready for restart and transaction proccessing. 

To start using the CLI and record asset data, run the *start* bash script:

```bash
# Within the project root directory
cd ./images
./start.sh
```
This will start the containers and shell into the cli container. From there, you can go into the client directory and use the hvct.py script which acts as a command line interface to manage data in the blockchain. For more information on how to use the CLI, refer to the guide in a subsequent section of this document.

## Blockchain Network Configuration

In this section, we go deeper into how the network is configured by default and how it can be modified or expanded.

### Nodes

The blockchain network is composed of peer nodes and orderer nodes. The peers can submit transactions, the orderer receives those transactions, orders them into blocks and then sends those blocks back to the peers to add to the blockchain. Then every node has a copy of the complete blockchain. See [Hyperledger Fabric docs](https://hyperledger-fabric.readthedocs.io/en/release-1.3/) for more details on how they work. 

To create a blockchain network with more peers, there are a some steps that you need to follow.

First, open the file called *crypto-config.yaml*, located in the *network-config/basic-network/* directory. In the PeerOrgs section, change the Count value under Template to the number of nodes desired in the network. 

```yaml
PeerOrgs:
    Template:
        Count: 3
```

Then, run the script *generate* in the same directory.

```bash
./generate.sh
```
This will generate all the crypto-material for all the nodes and create a channel transaction with which to create a channel for all the nodes to communicate once the network is up.

**NOTE: This will generate new crypto-material for all nodes, not just the new nodes added.**

Next, navigate to the *images* directory. Here, we need to create the recipe file for the new nodes and modify the scripts to initialize and start the new nodes. 

To create the recipe file, you can follow the Peer0 or Peer1 files as an example. For more information on what the exported variables affect, see the Hyperledger documentation. Finally, modify the scripts *start stop initialSetup buildImages* to include the new peers. Make sure to bind the correct directories in the singularity *instance.start* command, and make sure the initialSetup script create the directory where the the data will be stored for the node.


### Chaincode

Chaincode is the code that runs on the peer nodes to submit transactions. It was written in the Go programing languange and is located in the *network-config/config* directory. To add more chaincode and expand the functionality of the blockchain, write the code using the [Hyperledger Fabric Go SDK](https://github.com/hyperledger/fabric-sdk-go) and build it as a go plugin:

```bash
go build -buildmode=plugin
```

Once the plugin is compiled, place it in the *network-config/config* directory. Then specify the new system chaincode in the *core.yaml* in the following seccions:

```yaml
chaincode:
    system:
        newchaincodename: enable
    systemPlugins:
        - enabled: true
            name: newchaincodename
            path: /etc/hyperledger/fabric/chaincodeplugin.so
            invokableExternal: true
            invokableCC2CC: true
```

The path specified above refers to the path within the container where the plugin is located, depending on how directories within the container where bound. The directory */etc/hyperledger/fabric* of the container is bound to the *network-config/config* directory in the host.

Once this is done, the chaincode can now be invoked by client applications.

#### Chaincode installation details.

This specific type of chaincode installation refers to "system chaincode". System chaincode was disabled in Hyperledger. To enable it, the peer binary was recompiled by downloading the [Hyperledger Fabric source code v1.3.0](https://github.com/hyperledger/fabric/tree/v1.3.0) and running the following command:

```bash
GO_TAGS+=" pluginsenabled" make peer
```

The resulting binary is located in the *network-config/bin* directory. This directory was bound to the */usr/local/bin* directory in the container so that it uses that binary instead of the one that comes with the Hyperledger Peer image with which the contained was built.

## Command Line Interface Guide

If you follow the quick guide and run the *start* script, you are shelled into the cli container. In there, navigate to the *client* directory, where the command line interface python script is located.

The python script *hvct.py* is the CLI program used to interact with the blockchain. The CLI program has two commands:

- track-asset
- get-asset

### Track-Asset

The command structure is as follows:

```bash
python hvct.py track-asset --file INPUT_FILE -f FIELD -t [TARGETS [TARGETS ...]] [-at ASSET_TYPE] [-dt DATA_TYPES [DATA_TYPES ...]] [-d {true,false}] [-r ROW_COUNT]
```

Flags:
- file - The file that will be used as input for the command. The file is meant to be a csv representing table data.
- f - The field flag is used to specify the the column name which represents the asset that we want to track.
- t - The targets flag recieves a list of column names which are the data values that we want to track for the specified field.
- at - The type of asset that we are tracking. Ex. Component, Aircraft
- dt - List of names that represent the type of data that is being tracked. List has to be the same size as the targets because for each target column, the type is specified with this flag. Ex. Corrections, Maintainers, AircraftHistory.
- d - This flag receives either true or false and specifies whether to record duplicate data of a type. Defaults to false. Ex. Whether to record the same aircraft multiple times as it appears in the input data.
- r - Number of rows that are processed from the input file

### Get-Asset

The command structure is as follows:

```bash
python hvct.py get-asset -at ASSET_TYPE -a ASSET_ID [-dt DATA_TYPES [DATA_TYPES ...]] [-c [DEPENDENCY [DEPENDENCY ...]]]
```

Flags:
- at - The type of asset that you want to query. This value corresponds to what was entered in "ASSET_TYPE" in the track asset command Ex. Component, Aircraft
- a - The identifier of the asset that we are interested in. This are the row values for the column specified as the field in the track asset command. Ex. 8012468
- dt - List of names which represent what type of data you want to return for the given asset. This corresponds to the types specified in the "DATA_TYPES" in the track asset command.
- c - If the values of a data type represent another asset that is being tracked, and you want to return data for those assets, you specify the data type that contains those assets and the asset type that they represent, seperated by three asteriscs. Ex. If the asset has a data type called "InstallHistory" and the values returned of that type are actually assets of asset type "Aircraft", then under the c flag you write "InstallHistory***Aircraft".

Example using data.csv

```bash
python hvct.py track-asset -f Aircraft -t Component -dt CompHistory --file data.csv
python hvct.py track-asset -f Component -t Aircraft CORR_NARR -dt Air Narrative --file data.csv
python hvct.py get-asset -at Aircraft -a AC-41
python hvct.py get-asset -at Aircraft -a AC-41 -c CompHistory***Component
```




