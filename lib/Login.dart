import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/home/Home.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/LoginResponse.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginData.dart';
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/login/background.jpg"),
              fit: BoxFit.fill,
              // alignment: Alignment.topCenter
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
                key: formkey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // const MenuBar(),
                      Container(
                        padding: const EdgeInsets.all(3),
                        width: 500,
                        decoration: BoxDecoration(
                            color: MyColors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(3))
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
                                        size: 28,
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
                                color: MyColors.white,
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
              ),
          ),
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
      if (loginResponse.message=="Logged In") {
        sharedPreferences!.setString("login_type", type);
        sharedPreferences!.setString("token", loginResponse.data??"");
        sharedPreferences!.setString("status", "logged in");
        sharedPreferences!.setBool("pop", false);

        print("hello login");

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUp(mobile: mobile.text, code: logininfo.getCountryCode(), act: loginResponse.data??"",)));
      }
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
