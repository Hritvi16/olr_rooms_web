// ignore: file_names
import 'package:olr_rooms_web/model/Bookings.dart';
import 'package:olr_rooms_web/model/Amenities.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Categories.dart';

class BookingInfo extends Response{
  Bookings? booking;
  List<Images>? images;

  BookingInfo({
    Bookings? booking,
    List<Images>? images,
  });

  BookingInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    booking = json['booking'] != null ? Bookings.fromJson(json['booking']) : Bookings();

    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images?.add(Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map.addAll(super.toJson());
    map['booking'] = booking?.toJson();
    map['images'] = [];
    if (images != null) {
      map['images'] = images?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
