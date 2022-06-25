// ignore: file_names
import 'package:olr_rooms_web/model/Nearby.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/Reviews.dart';
import 'package:olr_rooms_web/model/SpecialRequest.dart';

class HotelDetailResponse extends Response{
  HotelInfo? hotel;
  List<Nearby>? nearby;
  List<Reviews>? reviews;
  List<HotelInfo>? hotels;
  List<SpecialRequest>? requests;

  HotelDetailResponse({
    HotelInfo? hotel,
    List<Nearby>? nearby,
    List<Reviews>? reviews,
    List<HotelInfo>? hotels,
    List<SpecialRequest>? requests
  });

  HotelDetailResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    hotel = HotelInfo.fromJson(json['hotel']);
    if (json['nearby'] != null) {
      nearby = [];
      json['nearby'].forEach((v) {
        nearby?.add(Nearby.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = [];
      json['reviews'].forEach((v) {
        reviews?.add(Reviews.fromJson(v));
      });
    }
    if (json['hotels'] != null) {
      hotels = [];
      json['hotels'].forEach((v) {
        hotels?.add(HotelInfo.fromJson(v));
      });
    }
    if (json['requests'] != null) {
      requests = [];
      json['requests'].forEach((v) {
        requests?.add(SpecialRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['hotel'] = hotel?.toJson();
    map['nearby'] = [];
    if (nearby != null) {
      map['nearby'] = nearby?.map((v) => v.toJson()).toList();
    }
    map['reviews'] = [];
    if (reviews != null) {
      map['reviews'] = reviews?.map((v) => v.toJson()).toList();
    }
    map['hotels'] = [];
    if (hotels != null) {
      map['hotels'] = hotels?.map((v) => v.toJson()).toList();
    }
    map['requests'] = [];
    if (requests != null) {
      map['requests'] = requests?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
