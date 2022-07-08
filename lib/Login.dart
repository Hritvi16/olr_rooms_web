import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/home/Home.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/LoginResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginData.dart';
import 'OTPScreen.dart';
import 'SignUp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  SharedPreferences? sharedPreferences;

  bool? mobileValidate;
  String? mobileError;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool ignore = false;

  var logininfo;

  @override
  void initState() {
    mobileValidate = false;
    mobileError = "";
    logininfo = Provider.of<LoginData>(context,listen: false);
    // start();
    super.initState();
  }

  TextEditingController mobile = TextEditingController();

  void start(){
    logininfo.updateCountryCode("+91");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: MySize.sizeh100(context),
              width: MySize.size100(context),
              padding: EdgeInsets.symmetric(vertical: MySize.sizeh10(context)),
              color: MyColors.white,
              child: constraints.maxWidth<600 ? getBodyM() : getBodyW(),
            );
          },
        ),
      ),
    );
  }

  getBodyM() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MySize.size25(context)),
            child: Image.asset(
                "assets/logo/olr.png"
            ),
          ),
          SizedBox(
            height: MySize.sizeh35(context),
          ),
          getForm("M")
        ],
      ),
    );
  }

  getBodyW() {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MySize.size50(context)/4),
            child: Image.asset(
                "assets/logo/olr.png"
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Container(
            height: MySize.sizeh100(context),
            margin: EdgeInsets.symmetric(horizontal: MySize.size50(context)/6),
            padding: EdgeInsets.symmetric(vertical: MySize.sizeh10(context)),
            decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.grey,
                    blurRadius: 3,
                  )
                ]
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                        color: MyColors.colorPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh25(context),
                  ),
                  getForm("W")
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  getForm(String type) {
    return Form(
      key: formkey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: type=="W" ? MySize.size1(context) : MySize.size5(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const MenuBar(),

            Container(
              padding: const EdgeInsets.all(3),
              width: type=="W" ? MySize.size40(context) : MySize.size80(context),
              decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.grey1,
                    blurRadius: 10,
                  )
                ]
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: (){
                          showCountryPicker(
                            context: context,
                            countryListTheme: CountryListThemeData(
                              flagSize: 25,
                              backgroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                              //Optional. Sets the border radius for the bottomsheet.
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              //Optional. Styles the search field.
                              inputDecoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Start typing to search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color(0xFF8C98A8).withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                            onSelect: (Country country) {
                              print(country.phoneCode);
                              logininfo.updateCountryCode("+"+country.phoneCode);
                              print(logininfo.getCountryCode());
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Consumer<LoginData>(builder: (context, data,child) {
                              return Text(data.getCountryCode().toString(),);
                            },),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: MyColors.colorPrimary,
                              size: MySize.size2(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: mobile,
                      onFieldSubmitted: (value) {
                        if (mobile.text.isEmpty) {
                          sendToast("* Required");
                        } else if (mobile.text.length!= 10) {
                          sendToast("Enter valid mobile number");
                        } else {
                          ignore = true;
                          setState(() {

                          });
                          login("customer");
                        }
                      },
                      cursorColor: MyColors.colorPrimary,
                      style: TextStyle(color: MyColors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorText: mobileValidate! ? mobileError : null,
                        hintText: "Mobile",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        String message = "";
                        if (value!.isEmpty) {
                          sendToast("* Required");
                          return "";
                        } else if (value.length < 10) {
                          sendToast("Enter valid mobile number");
                          return "";
                        } else {
                          return null;
                        }


                      },
                    ),
                    flex: 5,
                  ),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IgnorePointer(
                        ignoring: ignore,
                        child: GestureDetector(
                          onTap: (){
                            // if (formkey.currentState!.validate()) {
                            //   print("Validated");
                            //   login();
                            // } else {
                            //   print("Not Validated");
                            // }
                            if (mobile.text.isEmpty) {
                              sendToast("* Required");
                            } else if (mobile.text.length!= 10) {
                              sendToast("Enter valid mobile number");
                            } else {
                              ignore = true;
                              setState(() {

                              });
                              login("customer");
                            }
                          },
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: <Color>[
                                    MyColors.colorPrimary,
                                    MyColors.colorSecondary
                                  ],
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(3))
                            ),
                            child: Icon(Icons.arrow_forward, color: MyColors.white,
                              size: 24,),
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: ()
                  async {
                    login("guest");
                    // sharedPreferences = await SharedPreferences.getInstance();
                    // sharedPreferences!.setString("token", "");
                    // sharedPreferences!.setString("status", "logged in");
                    // sharedPreferences!.setBool("pop", false);
                    //
                    // // Navigator.pop(context);
                    // Navigator.of(context, rootNavigator: true).pop();
                    //
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => const Dashboard(selectedIndex: 0)));
                  },
                  child: Text(
                    "I'll Sign Up Later",
                    style: TextStyle(
                        color: MyColors.colorPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  sendToast(String message){

    SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void login(String type) async {
    sharedPreferences = await SharedPreferences.getInstance();
    String fcm = "";
    // String? fcm = await FirebaseMessaging.instance.getToken();
    print("Login");
    Map<String, dynamic> data = new Map();
    data['mobile'] = type=="customer" ? mobile.text : "Guest";
    data['code'] = logininfo.getCountryCode();
    data['fcm'] = fcm;
    print(data);
    LoginResponse loginResponse = await APIService().login(data);
    print(data);
    print(loginResponse.toJson());
    print("loginResponse.toJson()");
    ignore = false;
    setState(() {

    });
    if(loginResponse.status=="Success") {
      print(type);
        if (type=="guest") {
          sharedPreferences!.setString("login_type", type);
          sharedPreferences!.setString("token", loginResponse.data ?? "");
          sharedPreferences!.setString("status", "logged in");
          sharedPreferences!.setBool("pop", false);

          print("hello login");

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Home()));
        }
        else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) =>
              OTPScreen(
                token: loginResponse.data ?? "",
                mobile: mobile.text,
                type: loginResponse.message ?? "",
                login_type: type,
              )));
        }
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => const Dashboard(selectedIndex: 0)));
      //   } else {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => SignUp(mobile: mobile.text, code: logininfo.getCountryCode(), act: loginResponse.data??"",)));
      //   }
    }
  }

  int validate() {
    int cnt = 0;

    if (mobile.text.isEmpty) {
      setState(() {
        mobileValidate = true;
        mobileError = "Enter Mobile";
      });
      cnt++;
    } else {
      mobileValidate = false;
      mobileError = "";
    }
    return cnt;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
