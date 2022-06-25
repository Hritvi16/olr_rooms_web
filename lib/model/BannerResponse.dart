// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/BannerInfo.dart';

class BannerResponse extends Response{
  List<BannerInfo>? data;

  BannerResponse({
    List<BannerInfo>? data
  });

  BannerResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(BannerInfo.fromJson(v));
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
