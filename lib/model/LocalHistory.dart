// ignore_for_file: file_names
const String table = "localHist";

class LocalHistFields {
  static final List<String> values = [
    dateUnixAsId,
    device,
    farm,
    value,
    comment,
  ];
  static final String dateUnixAsId = "_id";
  static final String device = "device";
  static final String farm = "farm";
  static final String value = "value";
  static final String comment = "comment";
}

class LocalHist {
  final String dateUnixAsId;
  final String device;
  final String farm;
  final String value;
  final String comment;

  const LocalHist(
    this.dateUnixAsId,
    this.device,
    this.farm,
    this.value,
    this.comment,
  );

  // ignore: long-parameter-list
  LocalHist response({
    String? id,
    String? dev,
    String? f,
    String? v,
    String? com,
  }) =>
      LocalHist(
        id ?? dateUnixAsId,
        dev ?? device,
        f ?? farm,
        v ?? value,
        com ?? comment,
      );

  static LocalHist fromJson(Map<String, dynamic> json) => LocalHist(
        json[LocalHistFields.dateUnixAsId],
        json[LocalHistFields.device],
        json[LocalHistFields.farm],
        json[LocalHistFields.value],
        json[LocalHistFields.comment],
      );

  Map<String, dynamic> toJson() => {
        LocalHistFields.dateUnixAsId: dateUnixAsId,
        LocalHistFields.device: device,
        LocalHistFields.farm: farm,
        LocalHistFields.value: value,
        LocalHistFields.comment: comment,
      };
}
