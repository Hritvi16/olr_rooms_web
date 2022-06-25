// ignore: file_names
import 'package:olr_rooms_web/model/PreviousSearchDetails.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';

class CitySearchInfo extends Response{
  List<PreviousSearchDetails>? previousSearch;
  List<SearchInfo>? popularAreas;

  CitySearchInfo({
    PreviousSearchDetails? search,
    SearchInfo? popularAreas
  });

  CitySearchInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    previousSearch = [];
    json['previous_search'].forEach((v) {
      previousSearch?.add(PreviousSearchDetails.fromJson(v));
    });
    popularAreas = [];
    json['popular_areas'].forEach((v) {
      popularAreas?.add(SearchInfo.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['previous_search'] = [];
    if (previousSearch != null) {
      map['previous_search'] = previousSearch?.map((v) => v.toJson()).toList();
    }
    map['popular_areas'] = [];
    if (popularAreas != null) {
      map['popular_areas'] = popularAreas?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}
