// ignore: file_names
import 'package:olr_rooms_web/model/BookingInfo.dart';
import 'package:olr_rooms_web/model/Response.dart';

class BookingResponse extends Response{
  List<BookingInfo>? data;

  BookingResponse({
    List<BookingInfo>? data
  });

  BookingResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(BookingInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = [];
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
