// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';

class SignUpResponse extends Response{
  String? data;

  SignUpResponse({
    String? data
  });

  SignUpResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data;
    return map;
  }
}
