

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/home/Home.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'SignUp.dart';
import 'colors/MyColors.dart';

class OTPScreen extends StatefulWidget {
  final String token, type, login_type, mobile;
  const OTPScreen({Key? key, required this.token, required this.type, required this.login_type, required this.mobile}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  OtpFieldController otpController = new OtpFieldController();

  late String token, type, login_type, mobile, otp;
  late SharedPreferences sharedPreferences;

  DateTime limit = DateTime.now();
  @override
  void initState() {
    token = widget.token;
    type =widget.type;
    login_type =widget.login_type;
    mobile =widget.mobile;
    otp = "";
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Container(
                  width: MySize.size100(context),
                  alignment: Alignment.center,
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? getBodyM() : getBodyW()
              ),
            );
          },

        ),
      ),
    );
  }

  getBodyW() {
    return Container(
        width: 400,
        height: MySize.sizeh80(context),
        margin: EdgeInsets.symmetric(vertical: MySize.sizeh10(context)),
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
    return SizedBox(
      height: MySize.sizeh100(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "VERIFY OTP",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          Center(
            child: OTPTextField(
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 40,
                fieldStyle: FieldStyle.box,
                otpFieldStyle: OtpFieldStyle(
                    focusBorderColor: MyColors.colorPrimary
                ),
                outlineBorderRadius: 3,
                style: TextStyle(fontSize: 17),
                onChanged: (pin) {
                  print("Changed: " + pin);
                },
                onCompleted: (pin) {
                  print(limit.difference(DateTime.now()).isNegative);
                  if(otp==pin && limit.difference(DateTime.now()).isNegative==false) {
                    print("hello");
                    if (type=="Logged In") {
                      sharedPreferences.setString("login_type", login_type);
                      sharedPreferences.setString("token", token);
                      sharedPreferences.setString("status", "logged in");
                      sharedPreferences.setBool("pop", false);

                      print("hello login");

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const Home()));
                    }
                    else {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => SignUp(mobile: mobile, code: "+91", act: token,)));
                    }
                  }
                  else {
                    SnackBar snackBar = SnackBar(
                        content: Text("Invalid OTP"),
                        duration: const Duration(seconds: 1)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }),
          ),
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              getOTP("OTP Resent");
            },
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Text(
                "Resend OTP",
                style: TextStyle(
                    color: MyColors.colorPrimary,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          // GestureDetector(
          //   onTap: () {
          //     print(otp);
          //     print(otpController.);

          //   },
          //   child: Container(
          //     height: 40,
          //     width: MediaQuery.of(context).size.width * 0.5,
          //     padding: EdgeInsets.all(8),
          //     alignment: Alignment.center,
          //     decoration: BoxDecoration(
          //         color: MyColors.colorPrimary,
          //         borderRadius: BorderRadius.circular(20)
          //     ),
          //     child: Text(
          //       "VERIFY",
          //       style: TextStyle(
          //           fontSize: 20,
          //           fontWeight: FontWeight.w500,
          //           color: MyColors.white
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getOTP("OTP Sent");
  }
  getOTP(String message) async {
    int otp = generateOTP();

    Map<String, dynamic> data = new Map();
    data['apikey'] = "62978f044f56f";
    // data['route'] = "trans_dnd";
    data['sender'] = "OLRROM";
    data['mobileno'] = mobile;
    DateTime dateTime = DateTime.now().add(Duration(minutes: 10));
    limit = dateTime;
    String formattedTime = DateFormat("h:mm a").format(dateTime);
    print(formattedTime);
    print(type);
    if (type=="Logged In") {
      data['text'] = "$otp is the OTP to verify your mobile number with OLR Rooms. OTP is valid till $formattedTime IST. Do not Share with anyone.";
    }
    else {
      data['text'] = "$otp is the OTP to register your mobile number with OLR Rooms. OTP is valid till $formattedTime IST. Do not Share with anyone.";
    }
    print(data);
    // APIService().sendSMS(data);
    String response = await APIService().sendSMS(data);
    this.otp = otp.toString();
    setState(() {

    });
    print("this.otp");
    print(this.otp);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(
        response.trim()=="1 messages scheduled for delievery" ?
    message : "There's some issue with the server.")));
    otpController.setFocus(0);
  }

  generateOTP() {
    var rnd = new math.Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    print(next.toInt());
    return next.toInt();
  }
}