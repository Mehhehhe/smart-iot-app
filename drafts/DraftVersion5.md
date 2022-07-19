```dart
Map userData = {
    "userId" : "",
    "role" : "",
    "approved" : "",
    "userDevice" : {
        "device1" : {
            "actuator" : {
                "actuatorID" : ["actuator1","actuatorN"],
                "type" : {
                    "actuator1" : "type1",
                    "actuatorN" : "typeN"
                },
                // Move state and value to server-side
            },
            "userSensor" : {
                "sensorName" : ["sensor1","sensorN"],
                "sensorType" : {
                    "sensor1" : "type1",
                    "sensorN" : "typeN"
                },
                "sensorThresh" : {
                    "sensor1" : 90.0 // Will be encrypted while creating report
                    "sensorN" : 123.4
                },
                "sensorTiming" : {
                    "sensor1" : "Auto",
                    "sensorN" : "Manual"
                },
                "calibrateValue" : {
                    "sensor1" : "+1.1",
                    "sensorN" : "-0.5"
                }
                // Move state and value to server-side
            },
        },
        "device2" : {
            "actuator" : {},
            "userSensor" : {}
        },
    },
    "encryption" : ""
};
```
