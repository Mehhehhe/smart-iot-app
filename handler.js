'use strict';

module.exports.getFarmExample = (event, context, callback) => {
  let example = getFarm();
  const response =  {
    statusCode: 200,
    body: JSON.stringify(example),
  };
  callback(null, response);
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