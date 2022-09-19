// import 'dart:io';

// import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';

// import 'package:smart_iot_app/models/RequestModel.dart';
// import 'package:smart_iot_app/models/ResponseModel.dart';

// class PostRequest {
//   PostRequest();

//   // ignore: prefer_function_declarations_over_variables
//   final Handler<AwsApiGatewayEvent> postApiGateway = (context, event) async {
//     final requestBody = event.body;
//     final requestModel = postRequestModelFromJson(requestBody);

//     final responseBody =
//         ResponseModel(message: '[AWS Lambda] Greeting! ${requestModel.name}');

//     final response = AwsApiGatewayResponse(
//         body: responseModelToJson(responseBody),
//         isBase64Encoded: false,
//         statusCode: HttpStatus.ok,
//         headers: {
//           "Content-Type": "application/json",
//         });
//     return response;
//   };
// }
