import 'package:amplify_flutter/amplify_flutter.dart';

import '../services/lambdaCaller.dart';

class ResultItem {
  const ResultItem(
      {required this.deviceName,
      required this.whichFarm,
      required this.details});

  final String deviceName;
  final String whichFarm;
  final dynamic details;

  factory ResultItem.fromJSON(dynamic json) {
    return ResultItem(
        deviceName: json["deviceName"],
        whichFarm: json["whichFarm"],
        details: json["details"]);
  }

  toMap() {
    return {"deviceName": deviceName, "whichFarm": whichFarm};
  }
}

class SearchResult {
  const SearchResult({required this.items});

  final List<ResultItem> items;

  factory SearchResult.fromJSON(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => ResultItem.fromJSON(e as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
  }
}

class SearchError {
  final String message;
  const SearchError({required this.message});

  factory SearchError.fromJSON(dynamic json) {
    return SearchError(message: json['message'] as String);
  }
}

class SearchCache {
  final _cache = <String, SearchResult>{};
  SearchResult? get(String term) => _cache[term];
  void set(String term, SearchResult result) => _cache[term] = result;
  bool contains(String term) => _cache.containsKey(term);
  void remove(String term) => _cache.remove(term);
}

class SearchDevice {
  SearchDevice(this.cache, this.dev);
  final SearchCache cache;
  List dev;

  addDeviceList(List newDeviceList) {
    if (newDeviceList.every((element) => dev.contains(element))) {
      print("Added $newDeviceList");
      dev.addAll(newDeviceList);
    }
  }

  SearchResult search(String term) {
    final cachedResult = cache.get(term);
    if (cachedResult != null) return cachedResult;
    print("Search on devices list : => $dev");
    final result = dev
        .where((element) => element["SerialNumber"].toString().contains(term))
        .map((e) => ResultItem(
            deviceName: e["SerialNumber"],
            whichFarm: e["Location"],
            details: e))
        .toList();
    cache.set(term, SearchResult(items: result));
    return SearchResult(items: result);
  }
}
