'use strict';

const AWS = require('aws-sdk');

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const FarmTable = process.env.FARM_TABLE;
const FarmUserTable = process.env.FARM_USER_TABLE;
const FarmDeviceTable = process.env.FARM_DEVICE_TABLE;

var iotdata = new AWS.IotData({endpoint: 'a3aez1ultxd7kc-ats.iot.ap-southeast-1.amazonaws.com', region: "ap-southeast-1"});
const ALLOWED_ORIGIN = [
  "https://project-three-dun.vercel.app"
];

module.exports.updateValue = (event, context, callback) => {
    var headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': true
    };
    let table = event.targetTable;
    // format : [UpdateMap01, UpdateMap02]
    // Update map
    // {"ID":"001", "UpdateItems": {"1":"0.0","2":"0.0"}}
    // 
    switch (table) {
        case 'farm':
            table = FarmTable;
            break;
        case 'user':
            table = FarmUserTable;
            break;
        case 'device':
            table = FarmDeviceTable;
            break;
        default:
            callback(null, {
                statusCode: 500,
                headers,
                body: JSON.stringify({
                    message: "Unknown table. Please provides a correct table name."
                })
            });
            break;
    }
    console.log(table);
    for(let item of event.updateList){
        console.info(["Enter first loop", item, typeof item.UpdateItems])
        for(const key of Object.keys(item.UpdateItems)){
            let params = {
                TableName: table,
                Key: {
                    ID: item["ID"]
                },
                UpdateExpression: "SET #attrName = :attrValue",
                ExpressionAttributeNames: {
                    "#attrName": key
                },
                ExpressionAttributeValues:{
                    ":attrValue": item.UpdateItems[key]
                },
                ReturnValues: "ALL_NEW"
            };
            if(typeof item.UpdateItems[key]  === Array){
                params.UpdateExpression = "SET #attrName = list_append(#attrName, :attrValue)";
            }
            console.info(["params", params]);
            dynamoDB.update(params).promise().then((res) => console.log(res)).catch((e) => callback(null, {
                statusCode: 500,
                headers,
                body: JSON.stringify({
                    message: "Unable to update."
                })
            }));
        }
    }
    callback(null, {
        statusCode: 200, 
        headers,
        body: JSON.stringify({message: "Updated successfully!"})
    });
};