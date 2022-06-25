import 'package:olr_rooms_web/model/Hotel.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Area.dart';
import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/Country.dart';
import 'package:olr_rooms_web/model/Meal.dart';
import 'package:olr_rooms_web/model/States.dart';

class HotelInfo {
  Hotel? hotel;
  City? city;
  States? state;
  Country? country;
  Area? area;
  List<Images>? images;
  Meal? meal;

  HotelInfo({
    Hotel? hotel,
    City? city,
    States? state,
    Country? country,
    Area? area,
    List<Images>? images,
    Meal? meal
  });

  HotelInfo.fromJson(Map<String, dynamic> json) {
    hotel = json['hotel'] != null ? Hotel.fromJson(json['hotel']) : Hotel();
    city = json['city'] != null ? City.fromJson(json['city']) : City();
    state = json['state'] != null ? States.fromJson(json['state']) : States();
    country = json['country'] != null ? Country.fromJson(json['country']) : Country();
    area = json['area'] != null ? Area.fromJson(json['area']) : Area();
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images?.add(Images.fromJson(v));
      });
    }
    meal = json['meal'] != null ?  Meal.fromJson(json['meal']) : Meal();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['hotel'] = this.hotel?.toJson();
    map['city'] = this.city?.toJson();
    map['state'] = this.state?.toJson();
    map['country'] = this.country?.toJson();
    map['area'] = this.area?.toJson();
    map['images'] = [];
    if (images != null) {
      map['images'] = images?.map((v) => v.toJson()).toList();
    }
    map['meal'] = meal?.toJson();
    return map;
  }
}
