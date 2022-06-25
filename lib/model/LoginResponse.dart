// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';

class LoginResponse extends Response{
  String? data;

  LoginResponse({
    String? data
  });

  LoginResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data;
    return map;
  }
}
