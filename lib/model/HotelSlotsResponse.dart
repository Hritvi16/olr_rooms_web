// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/TimePeriod.dart';

class HotelSlotsResponse extends Response{
  TimePeriod? data;

  HotelSlotsResponse({
    TimePeriod? data
  });

  HotelSlotsResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = TimePeriod.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data?.toJson();
    return map;
  }
}
