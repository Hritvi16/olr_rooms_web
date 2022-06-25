// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/OfferInfo.dart';

class OfferDetailResponse extends Response{
  OfferInfo? data;

  OfferDetailResponse({
    OfferInfo? data
  });

  OfferDetailResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = OfferInfo.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data?.toJson();
    return map;
  }
}
