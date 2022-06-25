class PopBanner {
  String? pbId;
  String? pbImage;

  PopBanner({
      String? pbId, 
      String? pbImage,
  });

  PopBanner.fromJson(dynamic json) {
    pbId = json['pb_id'];
    pbImage = json['pb_image'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pb_id'] = pbId;
    map['pb_image'] = pbImage;
    return map;
  }

}