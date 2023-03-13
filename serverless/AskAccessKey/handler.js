'use strict';

const AWS = require('aws-sdk');

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const FarmTable = process.env.FARM_TABLE;
const FarmUserTable = process.env.FARM_USER_TABLE;
const FarmDeviceTable = process.env.FARM_DEVICE_TABLE;

module.exports.retreiveAccessKey = (event, context, callback) => {

};