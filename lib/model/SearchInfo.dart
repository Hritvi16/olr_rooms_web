// ignore: file_names
import 'package:olr_rooms_web/model/SearchDetails.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Categories.dart';

class SearchInfo extends Response{
  SearchDetails? search;
  String? type;

  SearchInfo({
    SearchDetails? search,
    String? type,
  });

  SearchInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    search = SearchDetails.fromJson(json['search']);
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['search'] = search?.toJson();
    map['type'] = type;
    return map;
  }

  static List<SearchInfo>? fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => SearchInfo.fromJson(item)).toList();
  }

}
