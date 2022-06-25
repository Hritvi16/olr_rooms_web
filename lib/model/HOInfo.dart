import 'package:olr_rooms_web/model/HO.dart';
import 'package:olr_rooms_web/model/Images.dart';
import 'package:olr_rooms_web/model/Area.dart';
import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/Country.dart';
import 'package:olr_rooms_web/model/Meal.dart';
import 'package:olr_rooms_web/model/States.dart';

class HOInfo {
  HO? ho;
  City? city;
  States? state;
  Country? country;
  Area? area;

  HOInfo({
    HO? ho,
    City? city,
    States? state,
    Country? country,
    Area? area,
  });

  HOInfo.fromJson(Map<String, dynamic> json) {
    ho = json['head_office'] != null ? HO.fromJson(json['head_office']) : HO();
    city = json['city'] != null ? City.fromJson(json['city']) : City();
    state = json['state'] != null ? States.fromJson(json['state']) : States();
    country = json['country'] != null ? Country.fromJson(json['country']) : Country();
    area = json['area'] != null ? Area.fromJson(json['area']) : Area();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['head_office'] = this.ho?.toJson();
    map['city'] = this.city?.toJson();
    map['state'] = this.state?.toJson();
    map['country'] = this.country?.toJson();
    map['area'] = this.area?.toJson();
    return map;
  }
}
