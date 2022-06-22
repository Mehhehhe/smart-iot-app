## Draft 1

This is the first draft of data in both sending and storing.

### Data Payload

```json
{
    "userId" : "",
    "role" : "",
    "userDevice" : {
        "device1" : {
            "userSensor":"sensor data block" // See [description](#data-description)
        },
        "device2" : {
            ...
        },
    },
    "encryption" : "",
}
```

### Data Description

**userId** : type String, contains user ID

**role** : type String, contains user's role (impact with permission)

**userDevice** : type Map<String, dynamic>, contains device's name as key and its sensor data block as value.

**userSensor** : type Map<String, dynamic>, contains user's sensor data block

**encryption** : type String, contains type of encryption which used for encrypt sensitive data.

### Structure of sensor data block

```json
{
    "sensorName": "Name of the sensor",
    "sensorType": "Type of sensor",
    "sensorStatus" : "Is sensor on or off?",
    "sensorValue" : {
        "time stamp" : {
            "flag" : "type of message: error(danger), warning or just value",
            "message" : "Message tells status or receive value",
            "value" : "sensor value. Is null if flag is error."
        },
    },
}
```

Sensor value contains at least 10 timestamp and its value for plotting graph in timeline.

Flag tells the user if sensor is working fine or something is wrong.

