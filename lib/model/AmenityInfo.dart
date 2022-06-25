// ignore: file_names
import 'package:olr_rooms_web/model/Amenities.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Categories.dart';

class AmenityInfo extends Response{
  List<Amenities>? hotel;
  List<Amenities>? room;

  AmenityInfo({
    List<Amenities>? hotel,
    List<Amenities>? room,
  });

  AmenityInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['hotel'] != null) {
      hotel = [];
      json['hotel'].forEach((v) {
        hotel?.add(Amenities.fromJson(v));
      });
    }
    if (json['room'] != null) {
      room = [];
      json['room'].forEach((v) {
        room?.add(Amenities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['hotel'] = [];
    if (hotel != null) {
      map['hotel'] = hotel?.map((v) => v.toJson()).toList();
    }
    map['room'] = [];
    if (room != null) {
      map['room'] = room?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
