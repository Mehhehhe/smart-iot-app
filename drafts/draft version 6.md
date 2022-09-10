### Database Structure draft version 6

- Previous version is used for Firebase services which cannot seperate data into multiple tables.
- Intended to use AWS.

| Process | Status |
| --- | :---: |
| Learning & Experimentation | ✔️ |
| Tables Creation | 💭 |
| Testing | ❌ |

```json
{
  "Instruction01": "Access 'Users' first, gets 'OwnedFarms' ",
  "Instruction02": "then use as a key to search for devices [AvailableDevices] in 'Farms' ",
  "Instruction03": "and lastly at 'Devices', concat 'Farm Name' with 'DeviceID' to get its data.",
  "Farms": [
    {
      "Name": "first farm",
      "ID": "farm01",
      "Owner": "Adam",
      "AllowedUsers": [
        "Adam",
        "John",
        "Robert"
      ],
      "AvailableDevices": [
        "farm01.DEVICE_01",
        "farm01.DEVICE_02"
      ]
    },
    {
      "Name": "second farm",
      "ID": "farm02",
      "Owner": "Adam",
      "AllowedUsers": [
        "Adam",
        "Johaness",
        "Winston"
      ],
      "AvailableDevices": [
        "farm02.DEVICE_01",
        "farm02.DEVICE_02"
      ]
    },
    {
      "Name": "third farm",
      "ID": "farm03",
      "Owner": "Bree",
      "AllowedUsers": [
        "Bree",
        "John P.",
        "Alex"
      ],
      "AvailableDevices": [
        "farm03.DEVICE_01",
        "farm03.DEVICE_02"
      ]
    }
  ],
  "Users": [
    {
      "Name": "Adam",
      "id": "Random generated",
      "OwnedFarms": [
        "farm01",
        "farm02"
      ]
    }
  ],
  "Devices": [
    {
      "id": "Farm.DeviceID",
      "Description": "Mapping farm's device. This attribute is not included in real JSON.",
      "Type": "type_1",
      "Settings": {
        "Threshold": "36.2",
        "Timing": "Automatic",
        "CalibrateValue": "+0.8"
      }
    }
  ]
}
```

![draft_ver 6](https://user-images.githubusercontent.com/66841844/189494391-c4311739-e2c6-45ce-8e5d-4a880bb95204.png)
