// ignore: file_names
import 'package:olr_rooms_web/model/Amenities.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Categories.dart';

class CategoryInfo extends Response{
  Categories? category;
  Images? image;
  List<Amenities>? categoryAmenities;
  String? total;

  CategoryInfo({
    Categories? category,
    Images? image,
    List<Amenities>? categoryAmenities,
    String? total
  });

  CategoryInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    category = Categories.fromJson(json['category']);
    image = Images.fromJson(json['image']);
    if (json['category_amenities'] != null) {
      categoryAmenities = [];
      json['category_amenities'].forEach((v) {
        categoryAmenities?.add(Amenities.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['category'] = category?.toJson();
    map['image'] = image?.toJson();
    map['category_amenities'] = [];
    if (categoryAmenities != null) {
      map['category_amenities'] = categoryAmenities?.map((v) => v.toJson()).toList();
    }
    map['total'] = total;
    return map;
  }
}
