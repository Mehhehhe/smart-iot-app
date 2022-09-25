import 'dart:convert';

import 'package:http/http.dart' as http;

const _farmApi = "https://d62mrahbok.execute-api.ap-southeast-1.amazonaws.com";

Map<String, dynamic> _urlMap = {
  "farm_list": Uri.https(_farmApi, '/dev/farm/list/all'),
  "get_farm_by_id": Uri.https(_farmApi, '/dev/farm/get/'),
  "create_farm": Uri.https(_farmApi, '/dev/farm/create')
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
  var response = await http.get(Uri.parse(_urlMap["farm_list"]));
  return response.statusCode == 200
      ? jsonDecode(response.body)
      : Exception('Failed to fetch farm list');
}

/// ## `getFarmById(String idOfTargetFarm)`
///
/// Return a map of farm info with `id` if status code is 200.
/// `id` may get from `fetchFarmList`
getFarmById(String id) async {
  var response = await http.get(Uri.parse(_urlMap["get_farm_by_id"] + id));
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
