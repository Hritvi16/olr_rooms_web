import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/Nearby.dart';
import 'package:olr_rooms_web/model/NearbyResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NearbyPlaces extends StatefulWidget {
  final String h_id;
  const NearbyPlaces({Key? key, required this.h_id}) : super(key: key);

  @override
  State<NearbyPlaces> createState() => _NearbyPlacesState();
}

class _NearbyPlacesState extends State<NearbyPlaces> {

  // List<Map<String, dynamic>> places = [
  //   {"place" : "Spice Petals Restro", "distance" : "2.2 Km"},
  //   {"place" : "PVR Cinemas", "distance" : "2.9 Km"},
  //   {"place" : "Engine Cafe", "distance" : "1.7 Km"},
  //   {"place" : "Central Mall", "distance" : "3.8 Km"},
  //   {"place" : "VR Mall", "distance" : "2.0 Km"},
  //   {"place" : "Surat Airport", "distance" : "5.6 Km"},
  //   {"place" : "Rebounce", "distance" : "1.1 Km"},
  //   {"place" : "Wat-a-Burger!", "distance" : "1.9 Km"},
  // ];
  List<Nearby> places = [];
  String h_id = "";
  bool load = false;

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    h_id = widget.h_id;
    getNearbyPlaces();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "NEARBY"),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Padding(
                padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                    : MenuBar(sharedPreferences: sharedPreferences, name: "NEARBY"),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                        padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                        child: constraints.maxWidth < 600 ? getPlacesM() : getPlaces()
                    ),
                    Footer()
                  ],
                ),
              ),
            ],
          );
        },
      )
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
  }

  getPlaces() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: MySize.sizeh1(context),
        mainAxisSpacing: MySize.sizeh075(context),
        crossAxisSpacing: MySize.size5(context),
        shrinkWrap: true,
        children: List.generate(places.length, (index) {
          return getPlacesCard(index);
        }),
      ),
    );
  }

  getPlacesM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: ListView.separated(
          itemCount: places.length,
          separatorBuilder: (BuildContext context, index) {
            return Column(
              children: [
                SizedBox(height: 10,),
                Divider(thickness: 1,)
              ],
            );
          },
          shrinkWrap: true,
          itemBuilder: (BuildContext context, index) {
            return getPlacesCard(index);
          }
      ),
    );
  }

  getPlacesCard(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          Essential().map(
              double.parse(places[ind].hnLat??"0"),
              double.parse(places[ind].hnLong??"0"),
              places[ind].hnPlace??""
          );
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.near_me_outlined,
                    color: MyColors.black,
                    size: 18,
                  ),
                  SizedBox(width: 13,),
                  Text(
                    places[ind].hnPlace??"",
                    style: TextStyle(
                      color: MyColors.black,
                      fontSize: 18
                    ),
                  )
                ],
              ),
              Text(
                places[ind].hnDistance??"",
                style: TextStyle(
                  color: MyColors.grey30,
                  fontSize: 18
                ),
              )
            ],
          ),
      ),
    );
  }

  getNearbyPlaces() async {
    sharedPreferences  = await SharedPreferences.getInstance();
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
      "h_id": h_id
    };
    NearbyResponse nearbyResponse = await APIService().getNearbyPlaces(queryParameters);
    print("nearbyResponse.toJson()");
    print(nearbyResponse.toJson());

    if (nearbyResponse.status == 'Success' &&
        nearbyResponse.message == 'Nearby Places Retrieved')
      places = nearbyResponse.data ?? [];
    else
      places = [];

    load = true;
    setState(() {

    });
  }
}
