import argparse
import os
import subprocess
import csv
import json
import blockchain

def trackAssetFromFile(args):
    fromField = args.field
    fromAlias = args.assetType
    if(not fromAlias):
        fromAlias = fromField

    toFields = args.targets
    ofTypes = args.dataTypes
    if(len(toFields) != len(ofTypes)):
        print("ERROR: toFields and types must have the same number of arguments")
        return

    filename = args.file
    allowDup = args.allowDuplicates
    rows = args.rowcount

    data = open(filename, "r")
    reader = csv.DictReader(data)

    components = {}
    rotorcrafts = {}

    x = 0
    for dataRow in reader:
        fields = reader._fieldnames

        for i in range(len(toFields)):
            if(toFields[i] == "all"):
                allJson = json.dumps(dataRow)
                allJson = allJson.replace('"', '\\"')
                checkCurrent = "true"
                if(allowDup == "true"):
                    checkCurrent = "false"
                blockchain.setAssociation(fromAlias, dataRow[fromField], ofTypes[i], allJson, checkCurrent)

            else:
                toJson = json.dumps(dataRow[toFields[i]].replace('"', '\\"'))
                print(toJson)

                checkCurrent = "true"
                
                if(allowDup == "true"):
                    checkCurrent = "false"
                
                toJson = toJson.replace('"', '\\"')
                blockchain.setAssociation(fromAlias, dataRow[fromField], ofTypes[i], toJson, checkCurrent)

        x = x+1
        if(x >= rows):
            break

    data.close()


    
def getAsset(args):
    field = args.assetType
    asset = args.asset
    types = args.dataTypes
    cascade = args.cascade

    result = blockchain.getAssociation(field, asset, types)
    
    if(cascade):
        for c in cascade:
            s = c.split("***")
            if(not s[0] in result):
                print("ERROR: Invalid key "+s[0])
                return
            for i in range(len(result[s[0]])):
                field = s[0]
                if (len(s) > 1):
                    field = s[1]
                asset = result[s[0]][i]
                cResult = blockchain.getAssociation(str(field), str(asset), ["all"])
                result[s[0]][i] = {asset: cResult}

    print(str(json.dumps(result, indent=4)))



parser = argparse.ArgumentParser()
subparser = parser.add_subparsers()


parser_input = subparser.add_parser("track-asset")
parser_input.add_argument("--file", required=True)
parser_input.add_argument("-f", "--field", required=True)
parser_input.add_argument("-t", "--targets", required=True, nargs="*")
parser_input.add_argument("-at", "--assetType")
parser_input.add_argument("-dt", "--dataTypes", required=True, nargs="*")
parser_input.add_argument("-d", "--allowDuplicates", choices=['true', 'false'], default="false")
parser_input.add_argument("-r", "--rowcount", type=int, default=1000000)
parser_input.set_defaults(func=trackAssetFromFile)


parser_ga = subparser.add_parser("get-asset")
parser_ga.add_argument("-at", "--assetType", required=True)
parser_ga.add_argument("-a", "--asset", required=True)
parser_ga.add_argument("-dt", "--dataTypes", default=["all"], nargs="*")
parser_ga.add_argument("-c", "--cascade", nargs="*")
parser_ga.set_defaults(func=getAsset)


args = parser.parse_args()
args.func(args)
