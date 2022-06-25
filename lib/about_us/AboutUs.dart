import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/Login.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/HOInfo.dart';
import 'package:olr_rooms_web/model/HOResponse.dart';
import 'package:olr_rooms_web/model/PolicyResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  final String policy_type, act, h_id;
  const AboutUs({Key? key, required this.policy_type, required this.act, required this.h_id}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool load = false;
  var unescape = HtmlUnescape();
  String policy_type = "";
  String act = "";
  String policy = "";
  String h_id = "";

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  List<HOInfo> ho = [];

  @override
  void initState() {
    policy_type = widget.policy_type;
    act = widget.act;
    h_id = widget.h_id;
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        backgroundColor: MyColors.white,
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: policy_type,),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                children: [
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero :  EdgeInsets.symmetric(horizontal: 32),
                    child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: policy_type),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: constraints.maxWidth < 600 ? EdgeInsets.zero :  EdgeInsets.symmetric(horizontal: 32),
                              child: Container(
                                padding: constraints.maxWidth< 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
                                    : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size5(context)),
                                child: Html(
                                  data: unescape.convert(policy),
                                ),
                              ),
                            ),
                            Padding(
                              padding: constraints.maxWidth< 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
                                  : EdgeInsets.symmetric(vertical: MySize.sizeh4(context), horizontal: MySize.size7(context)),
                              child: constraints.maxWidth< 600 ? getBodyM() : getBodyW()
                            ),
                            Footer()
                          ],
                        ),
                    ),
                  )
                ],
            );
          },
        )
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
  }

  void start() async {
    await getPolicy();
  }

  getBodyW() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 200
      ),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: ho.length,
      itemBuilder: (BuildContext context, index){
        return getHODesign(ho[index]);
      },
    );
  }
  
  getBodyM() {
    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: ho.length,
      separatorBuilder: (BuildContext context, index){
        return SizedBox(
          height: 10,
        );
      },
      itemBuilder: (BuildContext context, index){
        return getHODesignM(ho[index]);
      },
    );
  }

  getHODesign(HOInfo hoInfo) {
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
            hoInfo.ho?.hoName??"",
            style: TextStyle(
                fontSize: MySize.font8(context),
                fontWeight: FontWeight.w500
            ),
          ),
          getDetailDesign(Icons.location_on_outlined, hoInfo.ho?.hoAddress??"", "address", double.parse(hoInfo.ho?.hoLat??"0"), double.parse(hoInfo.ho?.hoLong??"0")),
          getDetailDesign(Icons.my_location_sharp, hoInfo.ho?.hoLandmark??"", "landmark", 0, 0),
          getDetailDesign(Icons.call_outlined, hoInfo.ho?.hoNumber??"", "call", 0, 0),
          getDetailDesign(Icons.email_outlined, hoInfo.ho?.hoEmail??"", "email", 0, 0),
        ],
      ),
    );
  }

  getHODesignM(HOInfo hoInfo) {
    return Container(
      height: 150,
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
            hoInfo.ho?.hoName??"",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
            ),
          ),
          getDetailDesignM(Icons.location_on_outlined, hoInfo.ho?.hoAddress??"", "address", double.parse(hoInfo.ho?.hoLat??"0"), double.parse(hoInfo.ho?.hoLong??"0")),
          getDetailDesignM(Icons.my_location_sharp, hoInfo.ho?.hoLandmark??"", "landmark", 0, 0),
          getDetailDesignM(Icons.call_outlined, hoInfo.ho?.hoNumber??"", "call", 0, 0),
          getDetailDesignM(Icons.email_outlined, hoInfo.ho?.hoEmail??"", "email", 0, 0),
        ],
      ),
    );
  }

  getDetailDesign(IconData icon, String detail, String type, double lat, double long) {
    return
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if(type=="call") {
              Essential().call(detail);
            }
            else if(type=="email") {
              Essential().email(detail);
            }
            else if(type=="address") {
              Essential().map(lat, long, detail);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: MySize.sizeh2_5(context),
              ),
              SizedBox(
                width: MySize.size1(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: MySize.font7_25(context),
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  getDetailDesignM(IconData icon, String detail, String type, double lat, double long) {
    return
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if(type=="call") {
              Essential().call(detail);
            }
            else if(type=="email") {
              Essential().email(detail);
            }
            else if(type=="address") {
              Essential().map(lat, long, detail);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 16,
              ),
              SizedBox(
                width: MySize.size1(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  getPolicy() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> queryParameters = {
      APIConstant.act: act,
      "h_id" : h_id
    };
    PolicyResponse policyResponse = await APIService().getPolicy(queryParameters);
    print(policyResponse.toJson());
    if (policyResponse.status == 'Success' && policyResponse.message == 'Policy Retrieved') {
      policy = policyResponse.data ?? "";
    }
    else
      policy = "";

    policy = utf8.decode(base64Decode(policy));

    getHeadOffices();
  }

  getHeadOffices() async {
    HOResponse hoResponse = await APIService().getHeadOffices();

    if (hoResponse.status == 'Success' && hoResponse.message == 'Head Offices Retrieved')
      ho = hoResponse.data ?? [];
    else
    {
      if((hoResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, hoResponse.message??"");
      }
    }
    
    load = true;
    setState(() {

    });
  }
}
