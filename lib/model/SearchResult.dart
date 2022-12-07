class ResultItem {
  const ResultItem({required this.deviceName, required this.whichFarm});

  final String deviceName;
  final String whichFarm;

  factory ResultItem.fromJSON(dynamic json) {
    return ResultItem(
        deviceName: json["deviceName"], whichFarm: json["whichFarm"]);
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
  const SearchDevice(this.cache, this.dev);
  final SearchCache cache;
  final List dev;
  SearchResult search(String term) {
    final cachedResult = cache.get(term);
    if (cachedResult != null) return cachedResult;
    final result = dev
        .where((element) => element.contains(term))
        .map((e) => ResultItem(deviceName: e["device"], whichFarm: e["farm"]))
        .toList();
    cache.set(term, SearchResult(items: result));
    return SearchResult(items: result);
  }
}
