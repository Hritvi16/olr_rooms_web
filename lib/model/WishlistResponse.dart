// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/CityInfo.dart';

class WishlistResponse extends Response{
  String? data;

  WishlistResponse({
    String? data
  });

  WishlistResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    data = json['data'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data;
    return map;
  }
}
