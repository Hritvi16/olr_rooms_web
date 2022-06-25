
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/home/HomeW.dart';
import 'package:olr_rooms_web/bookingDetails/BookedDetails.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetailsW.dart';

import '../home/Home.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    Map<String, dynamic> args = Map<String, dynamic>();
    String? name = "";

    print("routeSettings.name");
    print(routeSettings.name);
    print(routeSettings.arguments.runtimeType);
    if(routeSettings.arguments!=null) {
      args = routeSettings.arguments as Map<String, dynamic>;
    }

    if(routeSettings.name?.contains("?")??false) {
      name = routeSettings.name?.substring(routeSettings.name?.lastIndexOf("/")??0, routeSettings.name?.indexOf("?"));
      String key = routeSettings.name?.substring((routeSettings.name?.lastIndexOf("?")??0)+1, routeSettings.name?.indexOf("="))??"";
      String value = routeSettings.name?.substring((routeSettings.name?.lastIndexOf("=")??0)+1, routeSettings.name?.length)??"";
      args.addAll({
        key : value
      });
    }
    else {
      name = routeSettings.name?.substring(routeSettings.name?.lastIndexOf("/")??0, routeSettings.name?.length);
    }
    print("routeSettings.name");
    print(name);
    print(args);
    switch (name) {
      case '/home':
        return MaterialPageRoute(builder: (_) {
          return const Home();
        });

      case "/hotel":
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return HotelDetails(
              h_id : args["id"],
            );
          });
        }
        return _errorRoute("hotel");

      case "/booking":
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return BookedDetails(
              id : args["id"],
            );
          });
        }
        return _errorRoute("booking");
      default:
        return _errorRoute("Default");
    }
  }

  static Route<dynamic> _errorRoute(String route) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text(route),
        ),
      );
    });
  }
}
