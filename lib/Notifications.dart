import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    getLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Text("Notifications"),
        ),
    );
  }

  Future<void> getLocation() async {
// From a query
//     final query = "1600 Amphiteatre Parkway, Mountain View";
//     var addresses = await Geocoder.local.findAddressesFromQuery(query);
//     var first = addresses.first;
//     print("${first.featureName} : ${first.coordinates}");
//
// // From coordinates
//     final coordinates = new Coordinates(1.10, 45.50);
//     addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     first = addresses.first;
//     print("${first.featureName} : ${first.addressLine}");
  }
}
