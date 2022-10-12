'use strict';

// Set up libraries
//const uuid = require('uuid');
const AWS = require('aws-sdk');
const crypto = require('crypto');

// AWS.config.setPromisesDependency(require('bluebird'));

const dynamoDb = new AWS.DynamoDB.DocumentClient();
const FarmTable = process.env.FARM_TABLE;
const FarmUserTable = process.env.FARM_USER_TABLE;
const FarmDeviceTable = process.env.FARM_DEVICE_TABLE;

const MY_NAMESPACE = "578c1580-f296-4fef-8ecf-dc5b1bc31586";

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
  const response =  {
    statusCode: 200,
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
      body: JSON.stringify({
        message: "Successfully created "+res.FarmUser,
        userID: res.ID
      })
    })
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