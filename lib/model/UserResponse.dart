// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';

class UserResponse extends Response{
  UserInfo? data;

  UserResponse({
    String? data
  });

  UserResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    data = json['data'] != null ? UserInfo.fromJson(json['data']) : UserInfo();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data?.toJson();
    return data;
  }
}
