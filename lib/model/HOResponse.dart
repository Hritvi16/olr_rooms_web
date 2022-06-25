// ignore: file_names
import 'package:olr_rooms_web/model/HOInfo.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/HOInfo.dart';

class HOResponse extends Response{
  List<HOInfo>? data;

  HOResponse({
    List<HOInfo>? data
  });

  HOResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(HOInfo.fromJson(v));
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
