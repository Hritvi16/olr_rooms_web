// ignore: file_names
import 'package:olr_rooms_web/model/Response.dart';

class PolicyResponse extends Response{
  String? data;

  PolicyResponse({
    String? data
  });

  PolicyResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['data'] = data;
    return map;
  }
}
