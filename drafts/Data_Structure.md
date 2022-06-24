## Draft 4

This is the fourth draft of data in both sending and storing.
Constructors will be added later.

### Data Payload

```json
{
    "userId" : "",
    "role" : "",
    "approved" : "",
    "userDevice" : {
        "device1" : {
            "userSensor":"sensor data block",
            "actuator" : "actuator data block",
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

- userSensor [description](#structure-of-sensor-data-block)
- actuator [description](#actuator-data-block)

### Data Description

**userId** : _type String_, contains user ID

**role** : _type String_, contains user's role (impact with permission)

**approved** : _type bool_, contains true or false. This determines if created user is approved by admin or not.

**userDevice** : _type Map<String, dynamic>_, contains device's name as key and its sensor data block as value. This can be a list if user had more than 1 device.

**userSensor** : _type Map<dynamic, dynamic>_, contains user's sensor data block. This can be a list if user had more than 1 sensor in this device.

**actuator** : _type Map<dynamic, dynamic>_, contains user's actuator data block. This can be a list if user had more than 1 actuator to control the sensor.

**encryption** : _type String_, contains type of encryption which used for encrypt sensitive data.

### Structure of sensor data block

**sensorName** : _type dynamic_, contains the list of the sensor name. Integer is the key and sensor name as a value.

**sensorType** : _type Map<String, String>_, contains the list of sensor type. Sensor name is a key and sensor as a value.

**sensorStatus** : _type Map<String, bool>_, contains the status "on" or "off" of this sensor. This value is change by actuator. Key: sensor name, Value: bool

**sensorValue** : _type Map<dynamic, dynamic>_, contains nested map of sensor name as a key and timestamp with values of (flag, message, value) as a value

- _flag_, type String, contains values error, warning or just value
- _message_, type String, contains message from server. May be status, error, warning or others
- _value_, type dynamic, contains value of sensor. It can be int, float, or others. This is nullable if errors are found.

**sensorThresh** : _type Map<String, dynamic>_, contains dynamic value such as int, float or others. This is a ceil that if the value reach, it will warn to do something. Key: sensor name, Value: int, float or others.

**sensorTiming** : _type String_, contains value for set timing of sensor (Manual, auto or custom time). Key: sensor name, Value: String

**calibrateValue** : _type Map<String, dynamic>_, contains sensor name as a key and double as a value. This value is increase or decrease the sensor value.

```json
{
    "sensorName": {
        "index":"Name of the sensor"
        },
    "sensorType": {
        "sensorName":"Type of sensor"
        },
    "sensorStatus" : {
        "sensorName":"Is sensor on or off?"
        },
    "sensorValue" : {
        "sensorName" : {
            "time stamp" : {
            "flag" : "type of message: error(danger), warning or just value",
            "message" : "Message tells status or receive value",
            "value" : "sensor value. Is null if flag is error."
            },
        }
    },
    "sensorThresh" : {
        "sensorName":"Threshold value for working sensor, if more than exact value, do something"
        },
    "sensorTiming" : {
        "sensorName":"Set sensor timing to be manual, auto or custom time."
        },
    "calibrateValue" : {
        "sensorName":"Increase or decrease sensor value  by this value."
        },
}
```

Sensor value contains at least 10 timestamp and its value for plotting graph in timeline.

Flag tells the user if sensor is working fine or something is wrong.

### Actuator data block

**actuatorID** : _type Map<String, String>_. Array of actuator ID.

**type** : _type Map<String, String>_, contains actuator ID as key and its type as value.

**state** : _type Map<String, dynamic>_, contains actuator ID as key and its current state as value. Tells user if actuator is working fine or not.

**value** : _type Map<String, dynamic>_, contains actuator ID as key and its actuator value as value. Tells user the current value of actuator. User can change this value to set the sensor.

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

### Function

In every class object, this method is implemented.

```
Map<String, dynamic> toJson() => {'key':value};
```

Usage: for converting into Map then encode into Json

**DataPayload Functions**
```
Map<String, dynamic>? loadUserDevices();
MapEntry<String, dynamic>? displayDevice(String devicename);
DataPayload encode(DataPayload payload, String encryption);
DataPayload decode(DataPayload payload);
Map<String, dynamic> toJson()=>{};
factory DataPayload.fromJson(Map<String, dynamic> json){}
```
- **loadUserDevices** : return userDevice as Map<String, dynamic> and throw error if userDevice is null.
- **displayDevice** : return a target device as MapEntry and throw error if device is not found.
- **encode** : return encoded DataPayload with input encryption type (only at some sensitive data) and throw error if encryption is not supported.
- **decode** : return decoded DataPayload and throw error if unsupported encryption type or unable to decode.
- **toJson** : return Map of current object.
- **fromJson** : Map a json value into the model.
### Additional Function

If detects suspicious high value, discards it.