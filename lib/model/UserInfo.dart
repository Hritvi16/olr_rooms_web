import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/UserDetails.dart';

class UserInfo {
  UserDetails? user;
  City? city;

  UserInfo({
    String? user,
    String? city
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserDetails.fromJson(json['user']) : UserDetails();
    city = json['city'] != null ? City.fromJson(json['city']) : City();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user?.toJson();
    data['city'] = this.city?.toJson();
    return data;
  }
}
