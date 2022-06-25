// ignore: file_names
import 'package:olr_rooms_web/model/PopBanner.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Banners.dart';

class PopBannerResponse extends Response{
  PopBanner? data;

  PopBannerResponse({
    PopBanner? data
  });

  PopBannerResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    data = json['data']!=null ? PopBanner.fromJson(json['data']) : PopBanner();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data?.toJson();
    return map;
  }
}
