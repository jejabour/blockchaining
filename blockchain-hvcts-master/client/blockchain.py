from subprocess import Popen, PIPE
import json

def setAssociation(fromField, fromValue, ofType, json, checkCurrent):

    cmd = ["peer", "chaincode", "invoke", "-C", "mychannel", "-n", "myscc", "-c", '{"Args":["set-association", "' + fromField+ '", "' + fromValue+ '", "' + ofType+ '", "' + json+ '", "' + checkCurrent+ '"]}']
    p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    response = p.communicate()[1]
    print(response)

def getAssociation(fromField, fromValue, types):
    inputs = ''
    for t in types:
        inputs = inputs + ', "' + t + '"'

    cmd = ["peer", "chaincode", "invoke", "-C", "mychannel", "-n", "myscc", "-c", '{"Args":["get-association", "' + fromField+ '", "' + fromValue+ '"' + inputs + ']}']
    p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    response = p.communicate()[1]
    response = response.split("payload:")
    response = response[1]
    response = response[1:len(response)-3]
    # response = response.replace('\\"', '"')
    jsonResult = json.loads(response.decode("string_escape"))
    return jsonResult


# getAssociation("Component", "1", ["InstallHistory"])