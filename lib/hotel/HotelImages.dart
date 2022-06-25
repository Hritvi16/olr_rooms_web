// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/utils.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/components.dart';
import 'package:olr_rooms_web/model/HotelImages.dart' as hi;
import 'package:olr_rooms_web/model/HotelImagesResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

const scrollDuration = Duration(milliseconds: 500);

const randomMax = 1 << 32;

class HotelImages extends StatefulWidget {
  final String h_id, cat_id, act;
  const HotelImages({Key? key, required this.h_id, required this.cat_id, required this.act}) : super(key: key);

  @override
  _HotelImagesState createState() =>
      _HotelImagesState();
}

class _HotelImagesState extends State<HotelImages> {
  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;
  int ind = 0;
  int last_ind = 0;
  int tab_ind = -1;

  /// The alignment to be used next time the user scrolls or jumps to an item.
  double alignment = 0;

  // List<String> title = ["Room", "Washroom", "Lobby", "Reception", "Facade"];
  List<String> rooms = ["assets/rooms/r1.jpg", "assets/rooms/r2.jpg", "assets/rooms/r3.jpg", "assets/rooms/r4.jpg",
    "assets/rooms/r5.jpg", "assets/rooms/r6.jpg", "assets/rooms/r7.jpg",
    "assets/rooms/r5.jpg", "assets/rooms/r6.jpg", "assets/rooms/r7.jpg",
    "assets/rooms/r5.jpg", "assets/rooms/r6.jpg", "assets/rooms/r7.jpg",
    "assets/rooms/r5.jpg", "assets/rooms/r6.jpg", "assets/rooms/r7.jpg",
  ];
  List<String> washroom = ["assets/washroom/w1.jpeg", "assets/washroom/w2.jpeg"];
  List<String> lobby = ["assets/lobby/l1.jpg", "assets/lobby/l2.jpeg"];
  List<String> reception = ["assets/reception/r1.jpeg", "assets/reception/r2.jpg"];
  List<String> facade = ["assets/facade/f1.jpg", "assets/facade/f2.jpg"];
  // List<List> images = [];
  hi.HotelImages hotelImages = hi.HotelImages();

  String h_id = "";
  String cat_id = "";
  String act = "";
  int j = 0;

  bool load = false;
  late SharedPreferences sharedPreferences;
  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    h_id = widget.h_id;
    cat_id = widget.cat_id;
    act = widget.act;
    getHotelImages();
    // images = [rooms, washroom, lobby, reception, facade];
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      backgroundColor: MyColors.white,
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HOTELIMAGES"),
      body: OrientationBuilder(
          builder: (context, orientation) => Column(
              children: <Widget>[
                Padding(
                  padding: orientation == Orientation.portrait ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 32),
                  child: orientation == Orientation.portrait ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "HOTELIMAGES"),
                ),
                Container(
                  padding: orientation == Orientation.portrait ? null : const EdgeInsets.symmetric(horizontal: 32),
                  margin: orientation==Orientation.portrait ?
                  EdgeInsets.symmetric(horizontal: MySize.size5(context), vertical: MySize.sizeh3(context))
                      : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotelImages.title?.length??0,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: MySize.size2(context));
                    },
                    itemBuilder: (BuildContext context, index) {
                      return getTabs(index);
                    },
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: orientation==Orientation.portrait ? MySize.sizeh4(context) : MySize.sizeh3(context),
                ),
                // ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: orientation == Orientation.portrait ? null : const EdgeInsets.symmetric(horizontal: 32),
                          padding: orientation==Orientation.portrait ?
                          EdgeInsets.symmetric(horizontal: MySize.size4(context), vertical: MySize.sizeh1(context))
                              : EdgeInsets.symmetric(horizontal: MySize.size7(context)),
                          child: imageList(orientation),
                        ),
                        Footer()
                      ],
                    ),
                  ),
                ),
                // positionsView,
              ],
            ),
        ),
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
  }

  Widget imageList(Orientation orientation) => NotificationListener<UserScrollNotification>(
    onNotification: (notification) {
      final ScrollDirection direction = notification.direction;
      setState(() {
        if (direction == ScrollDirection.reverse) {
          print('reversed');
          // print(itemPositionsListener.itemPositions.value.length);
          // print(itemPositionsListener.itemPositions.value.last.index);
          // if(itemPositionsListener.itemPositions.value.length<=2)
            ind = itemPositionsListener.itemPositions.value.last.index;
          // else
          //   ind = itemPositionsListener.itemPositions.value.elementAt(1).index;
        } else if (direction == ScrollDirection.forward) {
          print('forward');
          print(itemPositionsListener.itemPositions.value.length);
          print(itemPositionsListener.itemPositions.value);
          // print(itemPositionsListener.itemPositions.value.first.index);
          // if(itemPositionsListener.itemPositions.value.length<=2)
            ind = itemPositionsListener.itemPositions.value.last.index;
          // else
            // ind = itemPositionsListener.itemPositions.value.elementAt(1).index;
        }
      });
      return true;
    },
    child: Container(
      height: orientation == Orientation.portrait ? null : MySize.sizeh65(context),
      margin: EdgeInsets.only(bottom: MySize.sizeh7(context)),
      child: ScrollablePositionedList.builder(
        itemCount: hotelImages.title?.length??0,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return generateImageList(index, orientation);
        },
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        reverse: reversed,
        scrollDirection: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
      ),
    ),
  );

  void scrollTo(int index) => itemScrollController.scrollTo(
      index: index,
      duration: scrollDuration,
      curve: Curves.easeInOutCubic,
      alignment: alignment);

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: alignment);

  Widget generateImageList(int index, Orientation orientation) {
    List<Widget> img = [

    ];
    int j = 0;

    for(int i = 0 ; i<=index-1; i++){
      j+=int.parse((hotelImages.title?[i].total??"0"));
    }
    print("j");
    print("index");
    print(index);
    print(j);

    for(int i = 0 ; i<int.parse((hotelImages.title?[index].total??"0")); i++){
      if(i==0) {
        img.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                    text: (hotelImages.title?[index].itType??"")+"  ",
                    style: TextStyle(
                        fontSize: orientation==Orientation.portrait ? MySize.font9(context) : MySize.font8(context),
                        color: MyColors.black,
                        fontWeight: FontWeight.w500
                    ),
                    children: [
                      TextSpan(
                        text: "("+(hotelImages.title?[index].total??"0")+")",
                        style: TextStyle(
                            color: MyColors.grey60,
                            fontWeight: FontWeight.w300
                        ),
                      )
                    ]
                ),
              ),
              SizedBox(height: MySize.sizeh2(context), width: MySize.size2(context),),
              getImageView(hotelImages.images?[j+i].hiImage??"", orientation)
            ],
          )
        );

        img.add(SizedBox(height: MySize.sizeh2(context), width: MySize.size2(context),),);
      }
      else {
        img.add(getImageView(hotelImages.images?[j + i].hiImage ?? "", orientation));
        img.add(SizedBox(height: MySize.sizeh2(context), width: MySize.size2(context),),);
      }
    }

    return orientation == Orientation.portrait ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: img,
    ) : Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: img,
    );
  }

  Widget getTabs(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          ind = index;

          setState(() {

          });
          scrollTo(index);
        },
        child: Container(
          alignment: Alignment.center,
          width: 90,
          decoration: ind==index ? BoxDecoration(
            color: MyColors.colorPrimary,
            borderRadius: BorderRadius.all(Radius.circular(20))
          ) : null,
          child: Text(
            hotelImages.title?[index].itType??"",
            style: TextStyle(
              color: ind==index ? MyColors.white : MyColors.grey,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageView(String path, Orientation orientation) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh055(context))),
      child: Image.network(
        Environment.imageUrl + path,
        fit: BoxFit.fill,
        height: orientation==Orientation.portrait ? MySize.sizeh25(context) : MySize.sizeh55(context),
        width: MediaQuery.of(context).size.width/(orientation==Orientation.portrait ? 1 : 2),
      ),
    );
  }

  Future<void> getHotelImages() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> queryParameters = {
      "act" : act,
      "h_id": h_id,
      "cat_id": cat_id
    };
    HotelImagesResponse hotelImagesResponse = await APIService().getHotelImages(queryParameters);

    if (hotelImagesResponse.status == 'Success' && hotelImagesResponse.message == 'Hotel Images Retrieved')
      hotelImages = hotelImagesResponse.data ?? hi.HotelImages();
    else
      hotelImages = hi.HotelImages();

    print(hotelImagesResponse.toJson());
    load = true;
    setState(() {

    });
  }

}