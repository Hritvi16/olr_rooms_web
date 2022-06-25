// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Banners.dart';

class BannerInfo extends Response{
  Banners? banner;
  List<String>? hotel;

  BannerInfo({
    Banners? banner,
    List<String>? hotel
  });

  BannerInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    banner = Banners.fromJson(json['banner']);
    if (json['hotel'] != null) {
      hotel = [];
      json['hotel'].forEach((v) {
        hotel?.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['banner'] = banner?.toJson();
    map['hotel'] = [];
    if (hotel != null) {
      map['hotel'] = hotel?.map((v) => v).toList();
    }
    return map;
  }
}
