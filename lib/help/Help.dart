import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/MyPopTemplate1.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/HelpResponse.dart';
import 'package:olr_rooms_web/model/Helps.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  bool load = false;
  List<Helps> helps = [];
  String previous = "";

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HELP"),
        backgroundColor: MyColors.white,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                  children: [
                    Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                          : MenuBar(sharedPreferences: sharedPreferences, name: "HELP"),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                            child: constraints.maxWidth < 600 ? getHelpBodyM() : getHelpBodyW()
                          ),
                          Footer()
                        ],
                      ),
                    ),
                  ],
              );
            }
        )
    ) :
    Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  getHelpBodyW() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: MySize.size1(context),
              mainAxisSpacing: MySize.sizeh1(context),
              mainAxisExtent: 80
          ),
          shrinkWrap: true,
          itemCount: helps.length,
          itemBuilder: (BuildContext context, int index) {
            return getHelpDesign(index);
            // return Text(index.toString());
          }
      ),
    );
  }

  getHelpBodyM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: helps.length,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(
            height: MySize.sizeh2(context),
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getHelpDesignM(index);
        },
      ),
    );
  }

  getHelpDesign(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Essential().link(helps[ind].heLink??"");
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
          decoration: BoxDecoration(
              color: MyColors.colorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MySize.sizeh055(context))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    helps[ind].heTitle??"",
                    style: TextStyle(
                        fontSize: MySize.font8(context),
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showPopUp(helps[ind].heDescription??"");
                      },
                      child: Text(
                        "View Description",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            fontWeight: FontWeight.w400,
                            color: MyColors.colorPrimary
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getHelpDesignM(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Essential().link(helps[ind].heLink??"");
        },
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: MySize.size2(context), vertical: MySize.sizeh1_5(context)),
          decoration: BoxDecoration(
              color: MyColors.colorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MySize.sizeh055(context))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    helps[ind].heTitle??"",
                    style: TextStyle(
                        fontSize: MySize.font11(context),
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showPopUp(helps[ind].heDescription??"");
                      },
                      child: Text(
                        "View Description",
                        style: TextStyle(
                            fontSize: MySize.font10_25(context),
                            fontWeight: FontWeight.w400,
                            color: MyColors.colorPrimary
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getHelps();
  }


  getHelps() async {
    HelpResponse helpResponse = await APIService().getOlrHelps();
    print(helpResponse.toJson());
    if (helpResponse.status == 'Success' && helpResponse.message == 'Helps Retrieved')
      helps = helpResponse.data ?? [];
    else
      helps = [];

    load = true;
    setState(() {

    });
  }

  showPopUp(String desc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MyPopTemplate1(desc: desc);
      },
    );
  }
}
