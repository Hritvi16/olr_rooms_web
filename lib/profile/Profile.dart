import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/profile/EditProfile.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserInfo userInfo = new UserInfo();
  bool gst = false;

  bool load = false;
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ?Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "PROFILE"),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Padding(
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "PROFILE"),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                            child: constraints.maxWidth < 600 ? getBodyM() : getBodyW()
                        ),
                        Footer()
                      ],
                    ),
                  ),
                ),
              ],
            );
          },

        )
    ) :
    Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  getBodyW() {
    return Container(
      width: MySize.size30(context),
      margin: EdgeInsets.symmetric(vertical: MySize.sizeh4(context)),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
      child: getBodyM()
    );
  }

  getBodyM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Editprofile(gst: gst,))).then((value) {
                    if(value=='Updated')
                      getUserInfo();
                    else
                      gst = userInfo.user?.cusGst!=null ? true : false;

                    setState(() {

                    });
                  });
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "EDIT",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: MyColors.black,
                    ),
                  ),
                )
            ),
          ),
          SizedBox(height: 30),
          getInfoDesign(Icons.mail_outline, userInfo.user?.cusEmail??"", ""),
          SizedBox(height: 30),
          getInfoDesign(Icons.call_outlined, (userInfo.user?.cusCc??"")+" "+(userInfo.user?.cusMobile??""), ""),
          SizedBox(height: 30),
          getInfoDesign(userInfo.user?.cusGender!=null ? userInfo.user?.cusGender=='FEMALE' ? Icons.female : userInfo.user?.cusGender=='MALE' ? Icons.male : Icons.transgender : Icons.person, userInfo.user?.cusName??"", userInfo.user?.cusGender ?? ""),
          SizedBox(height: 30),
          getInfoDesign(Icons.location_city, userInfo.city?.cName??"", ""),
          SizedBox(height: 30),
          getInfoDesign(Icons.cake_outlined, userInfo.user?.cusDob??"", ""),
          SizedBox(height: 30),
          getGSTCheckDesign(),
          if(gst)
            getGSTDesign()
        ],
      ),
    );
  }
  getUserInfo() async {
    print("hello");
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByID};
    UserResponse userResponse = await APIService().getUserDetails(queryParameters);
    print(userResponse.toJson());

    userInfo = userResponse.data!;
    gst = userInfo.user?.cusGst!=null ? true : false;
    load = true;
    setState(() {

    });
  }

  getInfoDesign(IconData icon, String data, String gen) {
    print(data);
    print(userInfo.user?.toJson());
    return Row(
      children: [
        Icon(
          icon,
          color: gen=='FEMALE' ? MyColors.pink600 : gen=='MALE' ? MyColors.blue300 : gen=='OTHER' ? MyColors.yellow800 : MyColors.black,
          size: 20,
        ),
        SizedBox(width: 25,),
        Expanded(
          child: Text(
            data,
            style: TextStyle(
              color: MyColors.black,
              fontWeight: FontWeight.w300
            ),
          ),
        )
      ],
    );
  }

  getGSTCheckDesign() {
    return IgnorePointer(
      ignoring: userInfo.user?.cusGst!=null ? true : false,
      child: SwitchListTile(
        value: gst,
        onChanged: (value) {
          gst = value;
          setState(() {

          });
          if(value)
            Navigator.push(context, MaterialPageRoute(builder: (context) => Editprofile(gst: gst,))).then((value) {
              if(value=='Updated')
                getUserInfo();
              else
                gst = userInfo.user?.cusGst!=null ? true : false;

              setState(() {

              });
            });

        },
        title: Text("GSTIN Details"),
      ),
    );
  }
  getGSTDesign() {
    return Column(
      children: [
        SizedBox(height: 15),
        getInfoDesign(Icons.security_update_good_rounded, userInfo.user?.cusGst??"", ""),
        SizedBox(height: 15),
        getInfoDesign(Icons.person_outline, userInfo.user?.cusGstLegalName??"", ""),
        SizedBox(height: 15),
        getInfoDesign(Icons.location_on_outlined, userInfo.user?.cusGstAddress??"", ""),
        SizedBox(height: 15),
      ],
    );
  }
}
