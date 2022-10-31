import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

const _farmApi = "d62mrahbok.execute-api.ap-southeast-1.amazonaws.com";
const _myNamespace = '578c1580-f296-4fef-8ecf-dc5b1bc31586';

Map<String, dynamic> _urlMap = {
  "farm_list": Uri.https(_farmApi, '/dev/farm/list/all'),
  "get_farm_by_id": Uri.https(_farmApi, '/dev/farm/get/'),
  "create_farm": Uri.https(_farmApi, '/dev/farm/create'),
  "user_list": Uri.https(_farmApi, '/dev/user/list/all'),
  "get_user_by_id": '/dev/user/get/',
  "get_devices_by_farm": '/dev/device/getByFarm'
};

/// ## `fetchFarmList()`
///
/// Returns a map of farms (all) if status code is 200.
///
/// `farm` **(key)** 's value is `List<Map>` which consist of
/// - `ID` of farm := `String`
/// - `FarmName` := `String`
///
/// ```
/// {
///   "farm":[{
///     "ID":"id_of_farm_here",
///     "FarmName":"farm_name"
///     }]
/// }
/// ```
fetchFarmList() async {
  var response = await http.get(_urlMap["farm_list"]);
  print(response.body);
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception('Failed to fetch farm list');
}

fetchUserList() async {
  var response = await http.get(_urlMap["user_list"]);
  print(response.body);
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception('Failed to fetch user list');
}

/// ## `getFarmById(String idOfTargetFarm)`
///
/// Return a map of farm info with `id` if status code is 200.
/// `id` may get from `fetchFarmList`
getFarmById(String id) async {
  var response = await http.get(_urlMap["get_farm_by_id"] + id);
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception('Failed to load target id');
}

createFarm(Map farmInfo) async {
  var response = await http.post(_urlMap["create_farm"], body: farmInfo);
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception(response.body);
}

/// ## `getUserById(String id)`
///
/// Return a map of user info with `id` if status code is 200.
getUserById(String id) async {
  String targetId = "";
  Map usersList = await fetchUserList();
  var users = usersList["users"];
  for (var user in users) {
    if (user["FarmUser"] == id) {
      targetId = user["ID"];
    }
  }
  if (targetId == "") return {};

  // print(digest);
  var response =
      await http.get(Uri.https(_farmApi, _urlMap["get_user_by_id"] + targetId));
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception(response.body);
}

Future<List> getDevicesByFarmName(String farm) async {
  print("Recv: $farm");
  var postCont = await http.post(
      Uri.https(_farmApi, _urlMap["get_devices_by_farm"]),
      body: json.encode({"DeviceLocation": farm}));
  print("Post body GET: ${postCont.body}");
  return postCont.statusCode == 200
      ? jsonDecode(postCont.body)
      : Exception(postCont.body);
}
