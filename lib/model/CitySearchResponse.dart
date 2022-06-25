// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/CitySearchInfo.dart';

class CitySearchResponse extends Response{
  CitySearchInfo? data;

  CitySearchResponse({
    CitySearchInfo? data
  });

  CitySearchResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = CitySearchInfo.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data?.toJson();
    return map;
  }
}
