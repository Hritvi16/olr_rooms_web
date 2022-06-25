// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/OfferInfo.dart';

class HotelOfferResponse extends Response{
  List<OfferInfo>? data;

  HotelOfferResponse({
    List<OfferInfo>? data
  });

  HotelOfferResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(OfferInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = [];
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
