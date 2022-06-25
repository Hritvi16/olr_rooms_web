import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/CityResponse.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/profile/SearchCity.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../formatter/UpperCaseTextFormatter.dart';

class Editprofile extends StatefulWidget {
  final bool gst;
  const Editprofile({Key? key, required this.gst}) : super(key: key);

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  UserInfo userInfo = new UserInfo();
  bool gst = false;
  DateTime chosenDate = DateTime.now();
  bool gender = false;
  String? gen = null;
  String cc = "";
  String? c_id;
  bool verified_gst = false;

  TextEditingController emailController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController legalNameController = new TextEditingController();
  TextEditingController gstController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController stateCodeController = new TextEditingController();

  Map<String, String> data = new Map<String, String>();

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
          SizedBox(height: 25),
          getInfoDesign(Icons.mail_outline, emailController, "Email", false),
          SizedBox(height: 20),
          getInfoDesign(Icons.call_outlined, mobileController, "Mobile", false),
          SizedBox(height: 20),
          getInfoDesign(userInfo.user?.cusGender!=null ? userInfo.user?.cusGender=='FEMALE' ? Icons.female : userInfo.user?.cusGender=='MALE' ? Icons.male : Icons.transgender : Icons.person, nameController, "Name", false),
          if(gender == true)
            getGenderDesign(),
          SizedBox(height: 20),
          getInfoDesign(Icons.location_city, cityController, "City", true),
          SizedBox(height: 20),
          getInfoDesign(Icons.cake_outlined, dobController, "Birthdate", true),
          SizedBox(height: 20),
          getGSTCheckDesign(),
          if(gst)
            getGSTDesign(),
          SizedBox(height: 30),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: (){
                  if(verifyInfo())
                    updateDetails();
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                    height: 30,
                    width: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MyColors.green500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
  getUserInfo() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByID};
    UserResponse userResponse = await APIService().getUserDetails(queryParameters);
    print(userResponse.toJson());

    userInfo = userResponse.data!;
    gst = userInfo.user?.cusGst!=null ? true : widget.gst;
    gen = userInfo.user?.cusGender;
    cc = (userInfo.user?.cusCc!=null ? userInfo.user?.cusCc : "")!;
    c_id = (userInfo.city?.cId!=null ? userInfo.city?.cId : "-1")!;
    if(userInfo.user?.cusDob!=null)
      chosenDate = DateTime.parse(userInfo.user?.cusDob ?? "");

    load = true;
    setState(() {

    });
    setData();
  }

  setData() {
    emailController.text = userInfo.user?.cusEmail??"";
    mobileController.text = userInfo.user?.cusMobile??"";
    nameController.text = userInfo.user?.cusName??"";
    cityController.text = userInfo.city?.cName??"";
    dobController.text = userInfo.user?.cusDob!=null ? DateFormat("dd-MM-yyyy").format(chosenDate) : "";
    gstController.text = userInfo.user?.cusGst??"";
    legalNameController.text = userInfo.user?.cusGstLegalName??"";
    addressController.text = userInfo.user?.cusGstAddress??"";
  }

  getInfoDesign(IconData icon, TextEditingController controller, String hint, bool readOnly) {
    return TextFormField(
      onTap: (){
        if(hint=="Birthdate")
          pickDate();
        if(hint=='City') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCity(city: cityController.text,))
          ).then((value) {
            if(value!=null) {
              c_id = value['c_id'];
              cityController.text = value['c_name'];
            }
          });
        }
      },
      onChanged: (value)
      {
        if(hint == "GST Number" && value.length==15) {
          getGSTDetails();
        }
        else {
          legalNameController.text = "";
          addressController.text = "";
        }
      },
      controller: controller,
      readOnly: readOnly,
      maxLength: hint == "Mobile" ? 10 : hint == "GST Number" ? 15 : null,
      inputFormatters: hint == "GST Number" ? [
        UpperCaseTextFormatter()
      ] : null,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400
      ),
      decoration :InputDecoration(
        contentPadding: const EdgeInsets.all(8.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300
        ),
        prefixIcon: hint=="Mobile" ?
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 15,),
            Icon(
              icon,
              size: 18,
              color: MyColors.black,
            ),
            SizedBox(width: 5,),
            Text(
              cc+" ",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),
            )
          ],
        )
            :
        Icon(
          hint=='Name' ?
          Icons.person :
          icon,
          size: 18,
          color: MyColors.black,
        ),
        suffixIcon: hint=='Name' && gender==false ?
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                gen=='MALE' ?
                Icon(
                  Icons.male,
                  color: MyColors.blue300,
                ) : gen=='FEMALE' ?
                Icon(
                  Icons.female,
                  color: MyColors.pink600,
                ) : gen=='OTHER' ?
                Icon(
                  Icons.transgender,
                  color: MyColors.yellow800,
                ) :
                Icon(icon),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      gender = true;
                      setState(() {

                      });
                    },
                    child: Icon(Icons.keyboard_arrow_down_sharp),
                  ),
                ),
                SizedBox(width: 10)
              ],
            ) : null
      ),
    );
  }

  getGSTCheckDesign() {
    return SwitchListTile(
      value: gst,
      onChanged: (value) {
        gst = value;

        setState(() {

        });

        gstController.text = userInfo.user?.cusGst??"";
        legalNameController.text = userInfo.user?.cusGstLegalName??"";
        addressController.text = userInfo.user?.cusGstAddress??"";
        stateCodeController.text = userInfo.user?.cusStateCode??"";
      },
      title: Text("GSTIN Details"),
    );
  }

  getGSTDesign() {
    return Column(
      children: [
        SizedBox(height: 15),
        getInfoDesign(Icons.security_update_good_rounded, gstController, "GST Number", false),
        SizedBox(height: 15),
        getInfoDesign(Icons.person_outline, legalNameController, "Legal Entity Name", true),
        SizedBox(height: 15),
        getInfoDesign(Icons.location_on_outlined, addressController, "GST Address", true),
        SizedBox(height: 15),
      ],
    );
  }

  void pickDate() {
    DateTime today = DateTime.now();
    DateTime min = DateTime(today.year-100);
    DateTime max = DateTime(today.year-18, today.month, today.day);
    chosenDate = dobController.text.isNotEmpty ? chosenDate : max;
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 310,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: const Text('OK'),
                  onPressed: () {
                    dobController.text = DateFormat("dd-MM-yyyy").format(chosenDate);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(
                height: 250,
                child: CupertinoDatePicker(
                  initialDateTime: chosenDate,
                  minimumDate: min,
                  maximumDate: max,
                  onDateTimeChanged: (val) {
                    setState(() {
                      chosenDate = val;
                    });
                  },
                  mode: CupertinoDatePickerMode.date,
                ),
              ),

              // Close the modal

            ],
          ),
        ));
  }

  getGenderDesign() {
    return Container(
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      gen = 'MALE';
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gen=="MALE" ? MyColors.blue300 : MyColors.grey10)
                      ),
                      child: Icon(
                        Icons.male,
                        color: gen=="MALE" ? MyColors.blue300 : MyColors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      gen = 'FEMALE';
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gen=="FEMALE"? MyColors.pink600 : MyColors.grey10)
                      ),
                      child: Icon(
                        Icons.female,
                        color: gen=="FEMALE" ? MyColors.pink600 : MyColors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      gen = 'OTHER';
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gen=="OTHER"? MyColors.yellow800 : MyColors.grey10)
                      ),
                      child: Icon(
                        Icons.transgender,
                        color: gen=="OTHER" ? MyColors.yellow800 : MyColors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                gender = false;
                setState(() {

                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.green500,
                ),
                child: Icon(
                  Icons.check,
                  color: MyColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getGSTDetails() async {
    Map<String, String> data = {"aspid" : "1603731118", "password" : "Snehal@143", "Action" : "TP", "Gstin" : gstController.text};

    Map<String, dynamic> res = await APIService().getGSTDetails(data);
    print(res);
    if(res.containsKey("error")) {
      verified_gst = false;
      legalNameController.text = "";
      addressController.text = "";
      Toast.sendToast(context, res['error']['message']);
    }
    else {
      verified_gst = true;
      legalNameController.text = res['tradeNam'];
      Map<String, dynamic> address = res['pradr']['addr'];
      addressController.text = address['bno']+", "+address['flno']+(address['flno'].toString().isEmpty ? "" : ", ")+address['bnm']+", "+address['st']+", "+address['loc'];
      stateCodeController.text = gstController.text.substring(0,2);
      // stateCodeController.text = gstController.text.substring(0,2)+"-"+address['stcd'];
    }

    setState(() {

    });
  }

  bool verifyInfo() {
    bool verified = true;
    data = {};
    if(emailController.text.isNotEmpty && !EmailValidator.validate(emailController.text)) {
      verified = false;
      Toast.sendToast(context, "Enter valid email address");
    }
    else {
      if(emailController.text.isNotEmpty) {
        data.addAll({"cus_email" : emailController.text});
      }
    }
    if(mobileController.text.isEmpty) {
      verified = false;
      Toast.sendToast(context, "Enter mobile no.");
    }
    else if(mobileController.text.length!= 10) {
      verified = false;
      Toast.sendToast(context, "Enter valid mobile number");
    }
    else {
      data.addAll({"cus_cc" : cc});
      data.addAll({"cus_mobile" : mobileController.text});
    }
    if(nameController.text.isEmpty) {
      verified = false;
      Toast.sendToast(context, "Enter name");
    }
    else {
      data.addAll({"cus_name" : nameController.text});
    }
    if(gen!=null) {
      data.addAll({"cus_gender" : gen??""});
    }
    if(cityController.text.isNotEmpty) {
      data.addAll({"c_id" : c_id??"-1"});
    }
    if(dobController.text.isNotEmpty) {
      data.addAll({"cus_dob" : DateFormat("yyyy-MM-dd").format(chosenDate)});
    }
    if(gst) {
      print(verified_gst);
      print(gstController.text.isNotEmpty && verified_gst);
      if(gstController.text.isEmpty) {
        verified = false;
        Toast.sendToast(context, "Enter gst number");
      }
      else if(gstController.text.isNotEmpty && gstController.text.length!=15) {
        verified = false;
        Toast.sendToast(context, "Enter valid gst number");
      }
      else if(gstController.text.isNotEmpty && !verified_gst) {
        verified = false;
        Toast.sendToast(context, "Invalid GSTIN / UID");
      }
      else {
        data.addAll({"cus_gst" : gstController.text});
        data.addAll({"cus_gst_legal_name" : legalNameController.text});
        data.addAll({"cus_gst_address" : addressController.text});
        data.addAll({"cus_state_code": stateCodeController.text.toUpperCase(),});
      }
    }

    return verified;
  }

  Future<void> updateDetails() async {
    data.addAll({"act" : "update"});
    Response response = await APIService().updateUserDetails(data);
    // Toast.sendToast(context, response.message??"");

    if(response.status=="Success" && response.message=="User Updated") {
      Navigator.pop(context,"Updated");
    }
  }

}
