// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/HotelImages.dart';

class HotelImagesResponse extends Response{
  HotelImages? data;

  HotelImagesResponse({
    HotelImages? data
  });

  HotelImagesResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
      data = HotelImages.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data;
    return map;
  }
}
