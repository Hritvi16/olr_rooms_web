// ignore: file_names
import 'package:olr_rooms_web/model/BannerInfo.dart';
import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';

class DashboardResponse extends Response{
  UserInfo? user;
  List<City>? popular;
  List<BannerInfo>? banners;
  List<HotelInfo>? collection;
  List<HotelInfo>? recommended;
  List<HotelInfo>? holiday;

  DashboardResponse({
    UserInfo? user,
    List<City>? popular,
    List<BannerInfo>? banners,
    List<HotelInfo>? collection,
    List<HotelInfo>? recommended,
    List<HotelInfo>? holiday
  });

  DashboardResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    user = json['user'] != null ? UserInfo.fromJson(json['user']) : UserInfo();
    if (json['popular'] != null) {
      popular = [];
      json['popular'].forEach((v) {
        popular?.add(City.fromJson(v));
      });
    }
    if (json['banners'] != null) {
      banners = [];
      json['banners'].forEach((v) {
        banners?.add(BannerInfo.fromJson(v));
      });
    }
    if (json['collection'] != null) {
      collection = [];
      json['collection'].forEach((v) {
        collection?.add(HotelInfo.fromJson(v));
      });
    }
    if (json['recommended'] != null) {
      recommended = [];
      json['recommended'].forEach((v) {
        recommended?.add(HotelInfo.fromJson(v));
      });
    }
    if (json['holiday'] != null) {
      holiday = [];
      json['holiday'].forEach((v) {
        holiday?.add(HotelInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['user'] = this.user?.toJson();
    map['popular'] = [];
    if (popular != null) {
      map['popular'] = popular?.map((v) => v.toJson()).toList();
    }
    map['banners'] = [];
    if (banners != null) {
      map['banners'] = banners?.map((v) => v.toJson()).toList();
    }
    map['collection'] = [];
    if (collection != null) {
      map['collection'] = collection?.map((v) => v.toJson()).toList();
    }
    map['recommended'] = [];
    if (recommended != null) {
      map['recommended'] = recommended?.map((v) => v.toJson()).toList();
    }
    map['holiday'] = [];
    if (holiday != null) {
      map['holiday'] = holiday?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
