import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/SignUpResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/Home.dart';

class SignUp extends StatefulWidget {
  final String mobile, code, act;
  const SignUp({Key? key, required this.mobile, required this.code, required this.act}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  SharedPreferences? sharedPreferences;

  bool? emailValidate, nameValidate;
  String? emailError, nameError;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool ignore = false;

  @override
  void initState() {
    emailValidate = nameValidate = false;
    emailError = nameError = "";
    super.initState();
  }

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();

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
            height: MySize.sizeh25(context),
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
                    "Create An Account",
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
              height: 20,
            ),
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
            const SizedBox(
              height: 40,
            ),
            IgnorePointer(
              ignoring: ignore,
              child: SizedBox(
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

                        ignore = true;
                        setState(() {

                        });
                        signUp();
                      } else {
                        print("Not Validated");
                      }
                    },
                    child: const Text("Sign Up")),
              ),
            ),
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

  void signUp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print("Login");
    Map<String, dynamic> data = new Map();
    data['cus_name'] = name.text;
    data['cus_email'] = email.text;
    data['cus_cc'] = widget.code;
    data['cus_mobile'] = widget.mobile;
    data['cus_type'] = "OLR";
    data.addAll({APIConstant.act : widget.act});
    SignUpResponse signUpResponse = await APIService().signUp(data);
    print(signUpResponse.toJson());

    ignore = false;
    setState(() {

    });
    Toast.sendToast(context, signUpResponse.message??"");

    if(signUpResponse.status=="Success" && signUpResponse.message=="User Added") {
      sharedPreferences!.setString("token", signUpResponse.data??"");
      sharedPreferences!.setString("status", "logged in");
      sharedPreferences!.setString("login_type", "customer");
      sharedPreferences!.setString("mobile", widget.mobile);
      sharedPreferences!.setString("code", widget.code);
      sharedPreferences!.setString("email", email.text);
      sharedPreferences!.setString("name", name.text);
      sharedPreferences!.setBool("pop", false);

      Map<String, dynamic> data = new Map();
      data[APIConstant.act] = APIConstant.SENDSA;
      data[APIConstant.type] = "1";
      data['id'] = widget.mobile;

      print(data);

      APIService().sendNSE(data);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  int validate() {
    int cnt = 0;

    if (email.text.isEmpty) {
      setState(() {
        emailValidate = true;
        emailError = "Enter email";
      });
      cnt++;
    } else {
      emailValidate = false;
      emailError = "";
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
