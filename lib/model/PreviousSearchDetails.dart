/// ca_shId : "7"
/// shId : "12"
/// shSearch : "Jacuzzi"
/// am_image : "icons/1648288294.png"

class PreviousSearchDetails {
  String? shId;
  String? shSearch;
  String? shType;

  PreviousSearchDetails({
      String? shId,
      String? shSearch,
      String? shType,
  });

  PreviousSearchDetails.fromJson(dynamic json) {
    shId = json['sh_id'];
    shSearch = json['sh_search'];
    shType = json['sh_type'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sh_id'] = shId;
    map['sh_search'] = shSearch;
    map['sh_type'] = shType;
    return map;
  }

}