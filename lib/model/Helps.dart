class Helps {
  String? heId;
  String? heTitle;
  String? heDescription;
  String? heLink;

  Helps({
      String? heId, 
      String? heTitle,
      String? heDescription,
      String? heLink
  });

  Helps.fromJson(dynamic json) {
    heId = json['he_id'];
    heTitle = json['he_title'];
    heDescription = json['he_description'];
    heLink = json['he_link'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['he_id'] = heId;
    map['he_title'] = heTitle;
    map['he_description'] = heDescription;
    map['he_link'] = heLink;
    return map;
  }

}