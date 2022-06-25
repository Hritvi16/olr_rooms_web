import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/Amenities.dart';
import 'package:olr_rooms_web/model/AmenityInfo.dart';
import 'package:olr_rooms_web/model/AmenityResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAmenities extends StatefulWidget {
  final String h_id, cat_id, desc;
  const AllAmenities({Key? key, required this.h_id, required this.cat_id, required this.desc}) : super(key: key);

  @override
  State<AllAmenities> createState() => _AllAmenitiesState();
}

class _AllAmenitiesState extends State<AllAmenities> {
  

  String h_id = "";
  String cat_id = "";
  String desc = "";

  AmenityInfo amenityInfo = AmenityInfo();

  var unescape = HtmlUnescape();
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  bool load = false;

  @override
  void initState() {
    h_id = widget.h_id;
    cat_id = widget.cat_id;
    desc = widget.desc;
    getAllAmenities();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: MyColors.generateMaterialColor(MyColors.colorPrimary),
          dividerColor: Colors.transparent
      ),
      home: load ? DefaultTabController(
        length: 3,
        child: Scaffold(
          key: scaffoldkey,
          endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "AMENITIES"),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                  children: [
                    Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                          : MenuBar(sharedPreferences: sharedPreferences, name: "AMENITIES"),
                    ),
                    TabBar(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      labelColor: MyColors.colorPrimary,
                      indicatorColor: MyColors.colorPrimary,
                      unselectedLabelColor: MyColors.black,
                      // labelStyle: TextStyle(
                      //   fontSize: MySize.font1(context)
                      // ),
                      tabs: [
                        Tab(
                          text:"HOTEL",
                        ),
                        Tab(
                          text: "ROOM",
                        ),
                        Tab(
                          text: "DESCRIPTION",
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          constraints.maxWidth < 600 ? getAmenitiesM(amenityInfo.hotel??[], constraints) : getAmenities(amenityInfo.hotel??[], constraints),
                          constraints.maxWidth < 600 ? getAmenitiesM(amenityInfo.room??[], constraints) : getAmenities(amenityInfo.room??[], constraints),
                          getDescription(constraints)
                        ],
                      ),
                    ),
                  ],
              );
            },
          ),
        ),
      )
      : Center(
        child: CircularProgressIndicator(
            color: MyColors.colorPrimary,
        ),
      ),
    );
  }

  getAmenities(List<Amenities> amenities, BoxConstraints constraints) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: MySize.sizeh05(context),
              mainAxisSpacing: MySize.sizeh05(context),
              crossAxisSpacing: MySize.size05(context),
              shrinkWrap: true,
              children: List.generate(amenities.length, (index) {
                return getAmenitiesCard(amenities[index]);
              }),
            ),
        ),
        Footer()
      ],
    );
  }

  getAmenitiesM(List<Amenities> amenities, BoxConstraints constraints) {
    return Column(
      children: [
        Container(
            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
            margin: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: MySize.sizeh1_5(context),
              mainAxisSpacing: MySize.sizeh1_5(context),
              crossAxisSpacing: MySize.size1_5(context),
              shrinkWrap: true,
              children: List.generate(amenities.length, (index) {
                return getAmenitiesCardM(amenities[index]);
              }),
            ),
        ),
        Footer()
      ],
    );
  }

  getAmenitiesCard(Amenities amenity) {
    return Row(
      children: [
        Image.network(
          Environment.imageUrl + (amenity.amImage??""),
          color: MyColors.grey30,
          height: MySize.sizeh3(context),
          errorBuilder: (BuildContext context, obj, stack){
            return Icon(
              Icons.check_circle,
              color: MyColors.grey30,
              size: MySize.sizeh5(context),
            );
        }),
        SizedBox(width: MySize.size1_5(context),),
        Text(
          amenity.amName??"",
          style: TextStyle(
            color: MyColors.grey30,
            fontSize: MySize.font7_5(context)
          ),
        )
      ],
    );
  }

  getAmenitiesCardM(Amenities amenity) {
    return Row(
      children: [
        Image.network(
          Environment.imageUrl + (amenity.amImage??""),
          color: MyColors.grey30,
          height: MySize.sizeh4(context),
          errorBuilder: (BuildContext context, obj, stack){
            return Icon(
              Icons.check_circle,
              color: MyColors.grey30,
              size: MySize.size8(context),
            );
        }),
        SizedBox(width: MySize.size2(context),),
        Text(
          amenity.amName??"",
          style: TextStyle(
            color: MyColors.grey30,
            fontSize: MySize.font10(context)
          ),
        )
      ],
    );
  }

  Future<void> getAllAmenities() async {
    sharedPreferences  = await SharedPreferences.getInstance();
    Map<String, String> data = {
      "h_id": h_id,
      "cat_id": cat_id
    };
    AmenityResponse amenityResponse = await APIService().getAmenities(data);

    print(amenityResponse.toJson());
    if(amenityResponse.status=="Success" && amenityResponse.message=="Amenities Retrieved") {

      amenityInfo = amenityResponse.data ?? AmenityInfo();
    }
    else {
      amenityInfo = AmenityInfo();
      Toast.sendToast(context, amenityResponse.message??"");
    }
    load = true;
    setState(() {

    });
  }

  getDescription(BoxConstraints constraints) {
    return Column(
      children: [
        Padding(
          padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
          child: Html(
            data: unescape.convert(utf8.decode(base64Decode(desc))),
          ),
        ),
        Footer()
      ],
    );
  }
}
