import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/RequestTypeResponse.dart';
import 'package:olr_rooms_web/model/RequestTypes.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

import '../api/APIConstant.dart';
import 'size/MySize.dart';

class BecomePartner extends StatefulWidget {
  const BecomePartner({Key? key}) : super(key: key);

  @override
  State<BecomePartner> createState() => _BecomePartnerState();
}

class _BecomePartnerState extends State<BecomePartner> {


  bool? emailValidate, nameValidate, mobileValidate;
  String? emailError, nameError, mobileError;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String code="+91";

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController mobile = TextEditingController();

  @override
  void initState() {
    emailValidate = nameValidate = mobileValidate = false;
    emailError = nameError = mobileError = "";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 400,
        color: MyColors.white,
        child: Scaffold(
          backgroundColor: MyColors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Become a Partner",
                        style: TextStyle(
                            fontSize: 22,
                            color: MyColors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.center,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: MyColors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Container(
            width: 500,
            height: 400,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              child: SingleChildScrollView(
                  child: Container(
                    color: MyColors.white,
                    child: Form(
                      key: formkey,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: name,
                              cursorColor: MyColors.colorPrimary,
                              style: TextStyle(color: MyColors.black),
                              decoration: InputDecoration(
                                errorText: nameValidate! ? nameError : null,
                                label: Text("Name"),
                              ),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                String message = "";
                                if (value!.isEmpty) {
                                  return "* Required";
                                } else {
                                  return null;
                                }

                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: mobile,
                              maxLength: 10,
                              cursorColor: MyColors.colorPrimary,
                              style: TextStyle(color: MyColors.black),
                              decoration: InputDecoration(
                                errorText: mobileValidate! ? mobileError : null,
                                label: Text("Mobile"),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  Toast.sendToast(context, "* Required");
                                  return null;
                                } else if (value.length != 10) {
                                  Toast.sendToast(context, "Enter valid mobile number");
                                  return null;
                                } else {
                                  return null;
                                }

                              },
                            ),
                            TextFormField(
                              controller: email,
                              cursorColor: MyColors.colorPrimary,
                              style: TextStyle(color: MyColors.black),
                              decoration: InputDecoration(
                                errorText: emailValidate! ? emailError : null,
                                label: Text("Email"),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                String message = "";
                                if (value!.isEmpty) {
                                  return "* Required";
                                } else if (!EmailValidator.validate(value)) {
                                  return "Enter valid email address";
                                } else {
                                  return null;
                                }

                              },
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            SizedBox(
                              height: 55,
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                  onPressed: () {
                                    // if (validate() == 0) {
                                    //   login();
                                    // }
                                    print("EmailValidator.validate(value)");
                                    print(EmailValidator.validate(email.text));
                                    if (formkey.currentState!.validate()) {
                                      print("Validated");
                                      becomePartner();
                                    } else {
                                      print("Not Validated");
                                    }
                                  },
                                  child: const Text("Submit")),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  becomePartner() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.add,
      "he_name": name.text,
      "he_cc":code,
      "he_mobile":mobile.text,
      "he_email":email.text
    };
    Response response = await APIService().becomePartner(data);
    print("response.toJson()");
    print(response.toJson());

    if(response.status=="Success" && response.message=="Enquiry Raised Successfully") {
      Toast.sendToast(context, response.message??"");
      Navigator.pop(context, "refresh");
    }
    else {
      Toast.sendToast(context, response.message??"");
    }
  }
}
