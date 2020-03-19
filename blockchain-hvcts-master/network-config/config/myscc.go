package main

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

func New() shim.Chaincode {
	return &SimpleAsset{}
}

type SimpleAsset struct {
}

func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (t *SimpleAsset) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	function, params := stub.GetFunctionAndParameters()

	if function == "set-association" {
		if len(params) != 5 {
			return shim.Error("Invalid number of arguments.")
		}
		return SetAssociation(params[0], params[1], params[2], params[3], params[4], stub)

	} else if function == "get-association" {
		if len(params) < 3 {
			return shim.Error("Invalid number of arguments.")
		}
		return GetAssociations(params[0], params[1], params[2:len(params)], stub)
	}

	return shim.Error("Function name is invalid.")
}

func SetAssociation(fromField string, fromValue string, ofType string, jsonString string, checkCurrent string, stub shim.ChaincodeStubInterface) peer.Response {

	key, err := stub.CreateCompositeKey(fromField, []string{fromValue, ofType})
	if err != nil {
		return shim.Error(err.Error())
	}

	var unmarshalled interface{}

	value := []byte(jsonString)
	err = json.Unmarshal(value, &unmarshalled)
	if err != nil {
		return shim.Error(err.Error() + "1")
	}

	if checkCurrent == "true" {
		current, err := stub.GetState(key)
		if err != nil {
			return shim.Error(err.Error())
		}
		if current != nil && string(value) == string(current) {
			return shim.Success([]byte("Current state left unchanged due to same json entry."))

		}
	}

	err = stub.PutState(key, value)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte("Successfully submitted data association."))
}

func GetAssociations(fromField string, fromValue string, types []string, stub shim.ChaincodeStubInterface) peer.Response {

	typesToQuery := make(map[string]bool)
	for i := 0; i < len(types); i++ {
		typesToQuery[types[i]] = true
	}

	iter, err := stub.GetStateByPartialCompositeKey(fromField, []string{fromValue})
	if err != nil {
		return shim.Error(err.Error())
	}

	jsonMap := make(map[string][]interface{})

	for iter.HasNext() {
		stateQuery, err := iter.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		_, keys, err := stub.SplitCompositeKey(stateQuery.GetKey())
		if err != nil {
			return shim.Error(err.Error())
		}

		ofType := keys[len(keys)-1]
		if !typesToQuery["all"] && !typesToQuery[ofType] {
			continue
		}

		histIter, err := stub.GetHistoryForKey(stateQuery.GetKey())
		if err != nil {
			return shim.Error(err.Error())
		}

		for histIter.HasNext() {
			var unmarshalled interface{}

			kvModification, err := histIter.Next()
			if err != nil {
				return shim.Error(err.Error())
			}

			err = json.Unmarshal(kvModification.GetValue(), &unmarshalled)
			if err != nil {
				return shim.Error(err.Error())
			}

			jsonMap[ofType] = append(jsonMap[ofType], unmarshalled)

		}
	}

	result, err := json.Marshal(jsonMap)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(result)
}

func main() {}
