// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/AmenityInfo.dart';

class AmenityResponse extends Response{
  AmenityInfo? data;

  AmenityResponse({
    AmenityInfo? data
  });

  AmenityResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = AmenityInfo.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data?.toJson();
    return map;
  }
}
