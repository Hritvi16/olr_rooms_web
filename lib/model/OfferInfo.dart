import 'package:olr_rooms_web/model/Offers.dart';

class OfferInfo {
  Offers? offer;
  String? by;
  String? type;

  OfferInfo({
    Offers? offer,
    String? by,
    String? type
  });

  OfferInfo.fromJson(Map<String, dynamic> json) {
    offer = json['offer'] != null ? Offers.fromJson(json['offer']) : Offers();
    by = json['by'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['offer'] = this.offer?.toJson();
    data['by'] = this.by;
    data['type'] = this.type;
    return data;
  }
}
