import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/Country.dart';
import 'package:olr_rooms_web/model/States.dart';

class CityInfo {
  City? city;
  States? state;
  Country? country;

  CityInfo({
    City? city,
    States? state,
    Country? country
  });

  CityInfo.fromJson(Map<String, dynamic> json) {
    city = json['city'] != null ? City.fromJson(json['city']) : City();
    state = json['state'] != null ? States.fromJson(json['state']) : States();
    country = json['country'] != null ? Country.fromJson(json['country']) : Country();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city?.toJson();
    data['state'] = this.state?.toJson();
    data['country'] = this.country?.toJson();
    return data;
  }
}
