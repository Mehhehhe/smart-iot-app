## Draft 2

This is the second draft of data in both sending and storing.

### Data Payload

```json
{
    "userId" : "",
    "role" : "",
    "approved" : "",
    "userDevice" : {
        "device1" : {
            "userSensor":"sensor data block"[description](#structure-of-sensor-data-block),
            "actuator" : "actuator data block"[description](#actuator-data-block),
        },
        "device2" : {
            ...
        },
    },
    "widgetList":{
        "index" : "widget_name",
    },
    "encryption" : "",
}
```

### Data Description

**userId** : type String, contains user ID

**role** : type String, contains user's role (impact with permission)

**approved** : type bool, contains true or false. This determines if created user is approved by admin or not.

**userDevice** : type Map, contains device's name as key and its sensor data block as value. This can be a list if user had more than 1 device.

**userSensor** : type Map, contains user's sensor data block. This can be a list if user had more than 1 sensor in this device.

**actuator** : type Map, containes user's actuator data block. This can be a list if user had more than 1 actuator to control the sensor.

**encryption** : type String, contains type of encryption which used for encrypt sensitive data.

### Structure of sensor data block

**sensorName** : type String, contains the name of the sensor.

**sensorType** : type String, contains the type of the sensor.

**sensorStatus** : type bool, contains the status "on" or "off" of this sensor. This value is change by actuator.

**sensorValue** : type Map, contains map of timestamp as a key and (flag, message, value) as a value

**sensorThresh** : type String, contains dynamic value such as int, float or others. This is a ceil that if the value reach, it will warn to do something.

**sensorTiming** : type String, contains value for set timing of sensor (Manual, auto or custom time)

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
    "sensorThresh" : "Threshold value for working sensor, if more than exact value, do something",
    "sensorTiming" : "Set sensor timing to be manual, auto or custom time.",
    "calibrateValue" : "Increase or decrease sensor value  by this value.",
}
```

Sensor value contains at least 10 timestamp and its value for plotting graph in timeline.

Flag tells the user if sensor is working fine or something is wrong.

### Actuator data block

**actuatorID** : type Map<int, String>. Array of actuator ID.

**type** : type Map<String, String>, contains actuator ID as key and its type as value.

**state** : type Map<String, dynamic>, contains actuator ID as key and its current state as value. Tells user if actuator is working fine or not.

**value** : type Map<String, dynamic>, contains actuator ID as key and its actuator value as value. Tells user the current value of actuator. User can change this value to set the sensor.

```json
{
    "actuatorID":{
        "index":"ID",
    },
    "type" : {
        "ID": "type",
    },
    "state" : {
        "ID": "state",
    },
    "value" : {
        "ID": "value",
    }
}
```

### Additional Function

If detects suspicious high value, discards it.