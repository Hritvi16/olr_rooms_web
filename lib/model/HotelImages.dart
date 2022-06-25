import 'package:olr_rooms_web/model/ImageTitle.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Images.dart';

class HotelImages extends Response{
  List<Images>? images;
  List<ImageTitle>? title;

  HotelImages({
    List<Images>? images,
    List<ImageTitle>? title
  });

  HotelImages.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images?.add(Images.fromJson(v));
      });
    }
    if (json['title'] != null) {
      title = [];
      json['title'].forEach((v) {
        title?.add(ImageTitle.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['images'] = [];
    if (images != null) {
      map['images'] = images?.map((v) => v.toJson()).toList();
    }
    map['title'] = [];
    if (title != null) {
      map['title'] = title?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
