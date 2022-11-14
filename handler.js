'use strict';

// Set up libraries
//const uuid = require('uuid');
const AWS = require('aws-sdk');
// const AwsIoT = require('aws-iot-device-sdk');
const crypto = require('crypto');

// AWS.config.setPromisesDependency(require('bluebird'));

const dynamoDb = new AWS.DynamoDB.DocumentClient();
const FarmTable = process.env.FARM_TABLE;
const FarmUserTable = process.env.FARM_USER_TABLE;
const FarmDeviceTable = process.env.FARM_DEVICE_TABLE;

var iotdata = new AWS.IotData({endpoint: 'a3aez1ultxd7kc-ats.iot.ap-southeast-1.amazonaws.com', region: "ap-southeast-1"});
const ALLOWED_ORIGIN = [
  "https://project-three-dun.vercel.app"
];

// Encode Function
function encode(msg){
  const maximumLength = 8;
  if(msg.length > maximumLength){
    msg = msg.substr(0, maximumLength);
  } else if(msg.length < maximumLength){
    var diff = maximumLength - msg.length;
    var padding = '';
    for(var i = 0; i < diff; i++) padding += '0';
    msg = padding + msg;
  }
  return Buffer.from(msg).toString('base64');
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports.getFarmExample = (event, context, callback) => {
  let example = getFarm();
  var headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true,
  }
  const response =  {
    statusCode: 200,
    headers,
    body: JSON.stringify(example),
  };
  callback(null, response);
};

module.exports.getFarmList = (event, context, callback) => {
  var params = {
    TableName: FarmTable,
    ProjectionExpression: "ID, FarmName"
  };

  console.log("Scanning 'FARM' table ... ");
  const onScan = (err, data) => {
    if(err){
      console.log("Scan failed. Error: ", JSON.stringify(err, null, 2));
      callback(err);
    } else {
      console.log("Scan success. ");
      return callback(null, {
        statusCode: 200,
        body: JSON.stringify({
          farm: data.Items
        })
      });
    }
  };

  dynamoDb.scan(params, onScan).promise();
};

module.exports.getFarmByID = (event, context, callback) => {
  const params = {
    TableName: FarmTable,
    Key: {
      ID: event.pathParameters.ID
    }
  };

  dynamoDb.get(params).promise().then(
    result => {
      const response = {
        statusCode:200, 
        body: JSON.stringify(result.Item)
      };
      callback(null, response);
    }).catch(error => {
      console.error(error);
      callback(new Error("couldn't fetch farm by given ID."));
      return;
    });
};

module.exports.createFarm = async (event, context, callback) => {
  //console.log(JSON.stringify(event));
  //const requestBody = await JSON.parse(event);
  const FarmName = event.FarmName;
  const FarmOwner = event.Owner;
  const AllowedUsersInFarm = event.AllowedUsers;
  const AvailableDevicesInFarm = event.AvailableDevices;

  if(typeof FarmName !== 'string' || typeof FarmOwner !== 'string' || !(Array.isArray(AllowedUsersInFarm)) || !(Array.isArray(AvailableDevicesInFarm))){
    console.error("Validation failed.");
    // console.log("Users:"+Array.isArray(AllowedUsersInFarm)+" "+AllowedUsersInFarm.every((value) => typeof value !== 'string'));
    // console.log("Devices:"+Array.isArray(AvailableDevicesInFarm)+" "+AvailableDevicesInFarm.every((value) => typeof value !== 'string'));
    callback(new Error("Couldn't create because of validation errors"));
    return;
  }

  if(AllowedUsersInFarm.every((value) => typeof value !== 'string') || AvailableDevicesInFarm.every((value) => typeof value !== 'string')){
    console.error("Validation failed.");
    callback(new Error("Couldn't create because validation errors occured in the array"));
  }

  const farmInfo = (FarmName, Owner, AllowedUsers, AvailableDevices) => {
    const timestamp = new Date().getTime();
    return {
      ID: encode(FarmName),
      FarmName: FarmName,
      FarmOwner: Owner,
      AllowedUsersInFarm: AllowedUsers,
      AvailableDevicesInFarm: AvailableDevices,
      CreateAt: timestamp
    };
  };

  const submitFarm = farm => {
    console.log("Submitting Farm Info");
    const farmInfo = {
      TableName: process.env.FARM_TABLE,
      Item: farm
    };
    return dynamoDb.put(farmInfo).promise().then(res => farm);
  };

  await submitFarm(farmInfo(FarmName, FarmOwner, AllowedUsersInFarm, AvailableDevicesInFarm)).then(res => {
    callback(null, {
      statusCode: 200,
      body: JSON.stringify({
        message: "Successfully created ${Owner}'s farm ==> ${FarmName}",
        farmID: res.ID
      })
    });
  }).catch(err => {
    console.log(err);
    callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        message: "Unable to create farm === ${Owner}'s ${FarmName}"
      })
    });
  });
};

function getFarm(){
  return [
    {
      Name: 'first farm',
      ID: 'farm01',
      Owner:'Adam',
      AllowedUsers:[
        "Adam",
        "John",
        "Robert"
      ],
      AvailableDevices:[
        "farm01.DEVICE_01",
        "farm01.DEVICE_02"
      ]
    },
  ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// For User Table
module.exports.createUser = async (event, context, callback) => {
  // console.log(event);
  const User = event.user;
  const Email = event.email;
  var owned_farm = event.OwnedFarm ?? ["Wait for update"];

  const origin = event.headers.origin;
  let headers;

  if(ALLOWED_ORIGIN.includes(origin)){
    headers = {
      'Access-Control-Allow-Origin': 'https://project-three-dun.vercel.app/',
      'Access-Control-Allow-Credentials': true,
    }
  } else {
    headers = {
      'Access-Control-Allow-Origin': '*',
    }
  }

  if(typeof User !== 'string' || !Array.isArray(owned_farm)){
    console.error("Validation failed");
    // console.log(event.user);
    console.log(User);
    console.log(Email);
    callback(new Error("Couldn't create because of validation errors"));
  }

  if(owned_farm.every((value) => typeof value !== 'string')){
    console.error("Validation failed");
    callback(new Error("Couldn't create because validation errors occurred in the array"));
  }

  const UserID = crypto.randomUUID();
  
  // Generate farm ID
  if(owned_farm !== ["Wait for update"] || owned_farm !== null){
    owned_farm.forEach(function(part, index) {
      owned_farm[index] = encode(owned_farm[index]);
    });
  }

  const userInfo = (User, UserID, owned_farm) => {
    const timestamp = new Date().getTime();
    return {
      ID: UserID,
      FarmUser: User,
      Email: Email,
      OwnedFarm: owned_farm,
      Role: "user",
      Permissions: ["WaitForFarmsDataConfirmation","WaitForRoleConfirmation"],
      CreateAt: timestamp
    };
  };

  const submitUser = user => {
    console.log("Submitting User Info");
    const userInfo = {
      TableName: process.env.FARM_USER_TABLE,
      Item: user
    };
    return dynamoDb.put(userInfo).promise().then(res => user);
  };

  await submitUser(userInfo(User, UserID, owned_farm)).then(res => {
    callback(null, {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        message: "Successfully created "+res.FarmUser,
        userID: res.ID
      })
    })
  }).catch(err => {
    console.log(err);
    callback(null, {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        message: "Unable to create user"
      })
    });
  });
};

module.exports.createUserToTable = async (event, context, callback) => {
  const User = event.userName;
  const Email = event.request.userAttributes.email;
  var owned_farm = event.OwnedFarm ?? ["Wait for update"];

  if(typeof User !== 'string' || !Array.isArray(owned_farm)){
    console.error("Validation failed");
    // console.log(event.user);
    console.log(User);
    console.log(Email);
    callback(new Error("Couldn't create because of validation errors"));
  }

  if(owned_farm.every((value) => typeof value !== 'string')){
    console.error("Validation failed");
    callback(new Error("Couldn't create because validation errors occurred in the array"));
  }

  const UserID = crypto.randomUUID();
  
  // Generate farm ID
  if(owned_farm !== ["Wait for update"] || owned_farm !== null){
    owned_farm.forEach(function(part, index) {
      owned_farm[index] = encode(owned_farm[index]);
    });
  }

  const userInfo = (User, UserID, owned_farm) => {
    const timestamp = new Date().getTime();
    return {
      ID: UserID,
      FarmUser: User,
      Email: Email,
      OwnedFarm: owned_farm,
      Role: "user",
      Permissions: ["WaitForFarmsDataConfirmation","WaitForRoleConfirmation"],
      CreateAt: timestamp
    };
  };

  const submitUser = user => {
    console.log("Submitting User Info");
    const userInfo = {
      TableName: process.env.FARM_USER_TABLE,
      Item: user
    };
    return dynamoDb.put(userInfo).promise().then(res => user);
  };

  await submitUser(userInfo(User, UserID, owned_farm)).then(res => {
    callback(null, event)
  }).catch(err => {
    console.log(err);
    callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        message: "Unable to create user"
      })
    });
  });
};

module.exports.getUserList = (event, context, callback) => {
  var params = {
    TableName: FarmUserTable,
    ProjectionExpression: "ID, FarmUser"
  };
  console.log("Retrieving users ... ");
  const onScan = (err, data) => {
    if(err){
      console.log("Retreived failed. Error: ", JSON.stringify(err, null, 2));
      callback(err);
    } else {
      console.log("Retreived success.");
      return callback(null, {
        statusCode: 200,
        body: JSON.stringify({
          users: data.Items
        })
      });
    }
  };
  dynamoDb.scan(params, onScan).promise();
};

module.exports.getUserByID = (event, context, callback) => {
  const params = {
    TableName: FarmUserTable,
    Key: {
      ID: event.pathParameters.ID
    }
  };

  dynamoDb.get(params).promise().then(
    result => {
      const response = {
        statusCode: 200,
        body: JSON.stringify(result.Item)
      };
      callback(null, response);
    }).catch(error => {
      console.error(error);
      callback(new Error("couldn't fetch user by given ID."));
    });
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Device functions

module.exports.registerDevice = async (event, context, callback) => {
  const DeviceName = event.device;
  const DeviceType = event.type;
  const DeviceSerial = event.serialNumber;
  
  const FarmName = event.farmName;

  if(typeof DeviceType !== 'string' || typeof FarmName !== 'string' || typeof DeviceName !== 'string' || typeof DeviceSerial !== 'string'){
    console.error("Validation failed");
    callback(new Error("Couldn't create because of validation errors"));
  }

  const deviceInfo = (DeviceSerial, DeviceName, DeviceType, FarmName) => {
    const timestamp = new Date().getTime();
    return {
      ID: crypto.randomBytes(8).toString('hex'),
      SerialNumber: DeviceSerial,
      DeviceName: DeviceName,
      Type: DeviceType,
      Location: FarmName,
      CreateAt: timestamp
    };
  };

  const submitDevice = device => {
    console.log("Submitting User Info");
    const deviceInfo = {
      TableName: FarmDeviceTable,
      Item: device
    };
    return dynamoDb.put(deviceInfo).promise().then(res => device);
  };

  await submitDevice(deviceInfo(DeviceSerial, DeviceName, DeviceType, FarmName)).then(res => {
    callback(null, event)
  }).catch(err => {
    console.log(err);
    callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        message: "Unable to create device"
      })
    });
  });
};

module.exports.getDeviceByID = (event, context, callback) => {
  const params = {
    TableName: FarmDeviceTable,
    Key: {
      ID: event.pathParameters.ID
    },
    ProjectionExpression: "ID, DeviceName"
  };

  dynamoDb.get(params).promise().then(
    result => {
      const response = {
        statusCode: 200,
        body: JSON.stringify(result.Item)
      };
      callback(null, response);
    }).catch((err) => {
      console.error(err);
      callback(new Error("Couldn't fetch device"));
    });
};

module.exports.getAllDevices = (event, context, callback) => {
  var params = {
    TableName: FarmDeviceTable,
  };

  console.log("Scanning 'DEVICE' table ... ");
  const onScan = (err, data) => {
    if(err){
      console.log("Scan failed. Error: ", JSON.stringify(err, null, 2));
      callback(err);
    } else {
      console.log("Scan success. ");
      return callback(null, {
        statusCode: 200,
        body: JSON.stringify({
          farm: data.Items
        })
      });
    }
  };

  dynamoDb.scan(params, onScan).promise();
};

module.exports.getDevicesByFarmName = async (event, context, callback) => {
  console.log("GET ", event);
  var transData = JSON.parse(event.body);
  const loc = transData.DeviceLocation;
  console.log("location:=",loc);
  console.log("From body: ", event.body);
  var params = {
    TableName: FarmDeviceTable,
  };

  console.log("Scanning 'DEVICE' table ... ");
  // const onScan = (err, data) => {
  //   if(err){
  //     console.log("Scan failed. Error: ", JSON.stringify(err, null, 2));
  //     callback(err);
  //   } else {
  //     console.log("Scan success. ");
  //     return callback(null, {
  //       statusCode: 200,
  //       body: JSON.stringify({
  //         farm: data.Items
  //       })
  //     });
  //   }
  // };

  const raw = await dynamoDb.scan(params).promise();
  var listToReturn = {"Devices":[]};
  // raw.farm.forEach((device) => {
  //   console.log(device);
  //   if(device.Location == event.DeviceLocation){
  //     targetList.push(device);
  //   }
  // });
  console.log("scanned: ", raw);
  // console.log(event.DeviceLocation);
  raw.Items.forEach((device, index, arr) => {
    console.log(device);
    if(device.Location == loc){
      console.log(device, index);
      listToReturn.Devices[index] = device;
      console.log("Inside forEach :=>",listToReturn);
    }
  });
  console.log(listToReturn);
  return callback(null, {
    statusCode: 200,
    body: JSON.stringify(listToReturn.Devices)
  });
};

//////////////////////////////////////////////////////////////////////////////
// MQTT: manage mqtt-related functions

module.exports.liveDataHandler = async (event, context, callback) => {
  // Check if request is sent through json.
  if(event.RequestConfirm == null || event.RequestConfirm == undefined || event.RequestConfirm == ""){
    console.log("Suspicious request. Type: ", typeof event.Request);
    return Error("Unexpected request.");
  }

  if(event.topic == null || event.topic == undefined || typeof event.topic !== 'string'){
    console.log("Something went wrong with topic. ", event.topic);
    return Error("Unexpected at topic");
  }
  console.log(JSON.stringify(event));
  // Fetch data from topic

  // Separate a topic to get farm name and device
  let splitStr = event.topic.split("/");
  var farmName = splitStr[0];
  var targetDevice = splitStr[1];

  // 1. Connect to dynamoDB 
  // 2. Select columns from given device
  var params = {
    TableName: farmName,
    Key: {
      "DeviceID": targetDevice
    },
    ProjectionExpression: "DeviceValue",
  };
  // var temp = {};
  const data = await dynamoDb.get(params).promise();

  // Query latest 10 items
  // const data = await dynamoDb.query(params).promise();
  var itemToReturn = {"LatestItems":[]};
  if(data.Item["DeviceValue"].length >= 10){
    itemToReturn.LatestItems = data.Item.slice(data.Item["DeviceValue"].length - 10, data.Item["DeviceValue"].length);
  } else {
    itemToReturn.LatestItems = data.Item["DeviceValue"];
  }
  // const data = await dynamoDb.get(params).promise().then(
  //   result => {
  //     const response = {
  //       statusCode: 200,
  //       body: JSON.stringify(result.Item)
  //     };
  //     console.log(response);
  //     // temp = response;
  //     callback(null, response);
  //     // return response;
  //   }).catch((err) => {
  //     console.error(err);
  //     callback(new Error("Couldn't fetch live data from given device"));
  //   });
    // console.log("temp: ", temp);
  console.log("[itemToReturn] :===> PASSED");
  console.log(itemToReturn.LatestItems);

  // itemToReturn.LatestItems = itemToReturn.LatestItems.map((item) => JSON.stringify(item));

  // console.log("Test joining ===> ", itemToReturn.LatestItems.join(","));
  var paramsResponse = {
    topic: farmName+'/'+targetDevice+'/'+'data/live',
    payload: JSON.stringify(itemToReturn.LatestItems),
    qos: 1
  };
  const pub = iotdata.publish(paramsResponse);
  pub.on('success', ()=>console.log("success")).on('error', ()=>console.log("error"));
  return new Promise(() => pub.send(function(err, data){
    if(err){
      console.log(err);
    } else {
      console.log(data);
    }
  }));
  // return iotdata.publish(paramsResponse, function(err, data){
  //   if(err){
  //     console.log("ERROR: "+JSON.stringify(err));
  //   } else {
  //     console.log("Success!"+JSON.stringify(data));
  //   }
  // }).promise();
};

module.exports.createFarmAsTable = (event, context, callback) => {
  const params = {
    AttributeDefinitions: [
      {
        AttributeName: 'DeviceID',
        AttributeType: 'S'
      }
    ],
    KeySchema: [
      {
        AttributeName: 'DeviceID',
        KeyType: 'HASH',
      }
    ],
    ProvisionedThroughput: {
      ReadCapacityUnits: 1,
      WriteCapacityUnits: 1
    },
    TableName: event.farmName,
    StreamSpecification: {
      StreamEnabled: false
    }
  };
  var ddb = new AWS.DynamoDB();
  ddb.createTable(params, function(err, data){
    if(err) {
      console.log("Error: ", err);
    } else {
      console.log("Success => ", data);
    }
  })
};

module.exports.writeDataFromIOT = async (event, context, callback) => {
  // const DeviceName = event.device;
  // const DeviceType = event.type;
  // const DeviceSerial = event.serialNumber;
  
  // const FarmName = event.farmName;

  // Separate a topic to get farm name and device
  let splitStr = event.topic.split("/");
  var farmName = splitStr[0];
  var targetDevice = splitStr[1];

  const deviceInfo = (DeviceSerial, DeviceState, FarmName) => {
    const timestamp = new Date().getTime();
    return {
      DeviceID: DeviceSerial,
      DeviceState: DeviceState,
      Location: FarmName,
      DeviceValue: [
        {
          "Value": event.payload.Data,
          "TimeStamp": timestamp,
          "State": DeviceState
        }],
    };
  };

  // Condition check here!
  // Case 1: if data was not in table, do `put`
  // Case 2: if data was already  in the table, do `update`
  var noData = false;
  var paramsDeviceInFarm = {
    TableName: farmName,
    Key: {
      DeviceID: targetDevice
    },
    ProjectionExpression: "DeviceID, DeviceValue"
  };
  var currentData = dynamoDb.get(paramsDeviceInFarm).promise().then(
    result => {
      const response = {
        statusCode: 200,
        body: JSON.stringify(result.Item)
      };
      noData = false;
      // callback(null, response);
    }).catch((err) => {
      console.error(err);
      noData = true;
      // callback(new Error("Couldn't fetch data from given params"));
    });

  const submitDevice = device => {
    console.log("Submitting device data ... :noData = ", noData);
    if(!noData){
      console.log(targetDevice);
      console.log(farmName);
    }
    console.log(device["DeviceValue"]);
    const deviceInfo = {
      TableName: farmName,
      Item: device
    };
    const deviceUpdateInfo = {
      TableName: farmName,
      Key: {
        DeviceID: targetDevice
      },
      UpdateExpression: "SET #attrName = list_append(#attrName, :attrValue)",
      ExpressionAttributeNames: {
        "#attrName": "DeviceValue"
      },
      ExpressionAttributeValues:{
        ":attrValue": device["DeviceValue"]
      },
      ReturnValues: "ALL_NEW"
    };
    if(noData == true)
    {
      console.log("data not found");
      return dynamoDb.put(deviceInfo).promise().then(res => device);
    }
    else{
      console.log("update");
      return dynamoDb.update(deviceUpdateInfo).promise().then(res => device);
    }
      
  };

  await submitDevice(deviceInfo(targetDevice, event.DeviceState, event.DeviceLocation)).then(res => {
    callback(null, event)
  }).catch(err => {
    console.log(err);
    callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        message: "Unable to write device's data"
      })
    });
  });
};