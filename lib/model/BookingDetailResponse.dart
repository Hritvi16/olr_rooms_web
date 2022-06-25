// ignore: file_names
import 'package:olr_rooms_web/model/BookingInfo.dart';
import 'package:olr_rooms_web/model/Response.dart';

class BookingDetailResponse extends Response{
  BookingInfo? data;

  BookingDetailResponse({
    BookingInfo? data
  });

  BookingDetailResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    data = BookingInfo.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();

    map['data'] = data?.toJson();

    return map;
  }
}
