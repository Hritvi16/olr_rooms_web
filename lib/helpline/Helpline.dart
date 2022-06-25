import 'package:flutter/material.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/HelplineResponse.dart';
import 'package:olr_rooms_web/model/Helplines.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpline extends StatefulWidget {
  const Helpline({Key? key}) : super(key: key);

  @override
  State<Helpline> createState() => _HelplineState();
}

class _HelplineState extends State<Helpline> {
  bool load = false;
  List<List<Helplines>> helplines = [];
  List<String> cities = [];
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
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HELPLINE"),
        backgroundColor: MyColors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Padding(
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "HELPLINE"),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                          padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                          child: constraints.maxWidth < 600 ? getHelplineBodyM() : getHelplineBodyW()
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

  getHelplineBodyW() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: cities.length,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(
            height: MySize.sizeh3(context),
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getHelplineDesign(index);
        },
      ),
    );
  }

  getHelplineBodyM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: cities.length,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(
            height: MySize.sizeh3(context),
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getHelplineDesignM(index);
        },
      ),
    );
  }

  getHelplineDesign(int ind) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context)),
          alignment: Alignment.centerLeft,
          child: Text(
           cities[ind],
            style: TextStyle(
                fontSize: MySize.font8(context),
                fontWeight: FontWeight.w500
            ),
          ),
        ),
        GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: MySize.size1(context),
              mainAxisSpacing: MySize.sizeh2(context),
              mainAxisExtent: 100
            ),
            shrinkWrap: true,
            itemCount: helplines[ind].length,
            itemBuilder: (BuildContext context, int index) {
              return getHelplineCard(helplines[ind][index]);
              // return Text(index.toString());
            }
        ),
      ],
    );
  }

  getHelplineDesignM(int ind) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context)),
          alignment: Alignment.centerLeft,
          child: Text(
           cities[ind],
            style: TextStyle(
                fontSize: MySize.font12(context),
                fontWeight: FontWeight.w500
            ),
          ),
        ),
        ListView.separated(
            shrinkWrap: true,
            itemCount: helplines[ind].length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: MySize.sizeh1(context),
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return getHelplineCardM(helplines[ind][index]);
              // return Text(index.toString());
            }
        ),
      ],
    );
  }

  getHelplineCard(Helplines helplines) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.colorPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.sizeh075(context))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            helplines.saName??"",
            style: TextStyle(
                fontSize: MySize.font7_75(context),
                fontWeight: FontWeight.w500
            ),
          ),
          Text(
            "("+(helplines.stType??"")+")",
            style: TextStyle(
                fontSize: MySize.font7(context),
                fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (helplines.saCc??"")+" "+(helplines.saMobile??""),
                style: TextStyle(
                    fontSize: MySize.font7(context),
                    fontWeight: FontWeight.w400
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Essential().call("tel://"+(helplines.saMobile??""));
                  },
                  child: Icon(
                    Icons.call,
                    size: MySize.sizeh3(context),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  getHelplineCardM(Helplines helplines) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.colorPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MySize.sizeh075(context))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            helplines.saName??"",
            style: TextStyle(
                fontSize: MySize.font11(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          Text(
            "("+(helplines.stType??"")+")",
            style: TextStyle(
                fontSize: MySize.font10(context),
                fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (helplines.saCc??"")+" "+(helplines.saMobile??""),
                style: TextStyle(
                    fontSize: MySize.font10(context),
                    fontWeight: FontWeight.w400
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Essential().call("tel://"+(helplines.saMobile??""));
                  },
                  child: Icon(
                    Icons.call,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  void start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await getHelplines();
  }


  getHelplines() async {
    HelplineResponse helplineResponse = await APIService().getOlrHelplines();
    print(helplineResponse.toJson());
    // if (helplineResponse.status == 'Success' && helplineResponse.message == 'Helplines Retrieved')
    //   helplines = helplineResponse.data ?? [];
    // else
    //   helplines = [];


    buildHelplines((helplineResponse.data ?? []));
  }

  buildHelplines(List<Helplines> lines) {
    List<Helplines> helpline = [];
    for(int i=0; i<lines.length; i++) {
      if(i==0 ? true : (lines[i].cName??"")!=(lines[i-1].cName??"")) {
        if(helpline.isNotEmpty) {
          helplines.add(helpline);
        }

        helpline = [];
        cities.add(lines[i].cName??"");
        helpline.add(lines[i]);
      }
      else {
        helpline.add(lines[i]);
      }
    }

    helplines.add(helpline);

    load = true;
    setState(() {

    });
  }
}
