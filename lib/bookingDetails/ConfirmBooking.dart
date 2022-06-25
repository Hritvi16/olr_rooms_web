import 'package:cache_manager/cache_manager.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olr_rooms_web/SuccessPage.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/ConfirmBookingResponse.dart';
import 'package:olr_rooms_web/model/SpecialRequest.dart';
import 'package:olr_rooms_web/model/SpecialRequestResponse.dart';
import 'package:olr_rooms_web/model/UserInfo.dart';
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../formatter/UpperCaseTextFormatter.dart';
import '../home/Home.dart';
import '../strings/Strings.dart';
import '../toast/Toast.dart';

class ConfirmBooking extends StatefulWidget {
  final Map<String, dynamic> data;
  final DateTime ds, de;
  final int timing, guest, adult, child, total_price;
  final double taxable_price, gst_amount, gst_per;
  final List<Map<String, dynamic>> rooms;
  final List<SpecialRequest> requests;
  final String currency;
  final String deposit, deposit_type, pay_at_hotel;
  const ConfirmBooking({Key? key, required this.data, required this.ds, required this.de, required this.timing, required this.rooms, required this.guest, required this.adult, required this.child, required this.total_price, required this.taxable_price, required this.gst_amount,  required this.gst_per, required this.currency, required this.deposit, required this.deposit_type, required this.pay_at_hotel, required this.requests}) : super(key: key);

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

enum Booking {myself, other}

class _ConfirmBookingState extends State<ConfirmBooking> {
  Map<String, dynamic> data = {};

  UserInfo userInfo = new UserInfo();
  Booking booking = Booking.myself;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController gstController = new TextEditingController();
  TextEditingController legalNameController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController stateCodeController = new TextEditingController();

  TextEditingController otherController = TextEditingController();

  bool? nameValidate, mobileValidate, emailValidate, gstValidate;
  String? nameError, mobileError, emailError, gstError;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool verified_gst = false;
  String code="+91";
  // String name = "";
  // String email = "";
  // String phone = "";
  // String gst = "";

  DateTime ds = new DateTime.now();
  DateTime de = new DateTime.now();
  int timing = 0;
  int guest = 0;
  int adult = 0;
  int child = 0;
  int total_price = 0;
  int deposit = 0;
  String deposit_type = "Percentage";

  double taxable_price = 0.0;
  double gst_amount = 0.0;
  double gst_per = 0.0;

  List<Map<String, dynamic>> rooms = [];
  
  String currency = "";

  int pay_at_hotel = 0;

  List<SpecialRequest> requests = [];
  List<int> selected = [];

  bool load = false;
  bool others = false;

  bool gst = true;


  // Razorpay _razorpay = Razorpay();

  String? b_id;

  bool gesture = true;

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    start();
    data = widget.data;
    ds = widget.ds;
    de = widget.de;
    timing = widget.timing;
    guest = widget.guest;
    adult = widget.adult;
    child = widget.child;
    rooms = widget.rooms;
    taxable_price = widget.taxable_price;
    gst_amount = widget.gst_amount;
    gst_per = widget.gst_per;
    total_price = widget.total_price;
    currency = widget.currency;
    deposit = int.parse(widget.deposit);
    deposit_type = widget.deposit;
    pay_at_hotel = int.parse(widget.pay_at_hotel);
    requests = widget.requests;

    nameValidate = mobileValidate = emailValidate = gstValidate = false;
    nameError = mobileError = emailError =  gstError = "";

    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        backgroundColor: MyColors.white,
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "CONFIRMBOOKING"),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                children: [
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                    child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                        : MenuBar(sharedPreferences: sharedPreferences, name: "CONFIRMBOOKING"),
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

  getUserInfo() async {
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByID};
    UserResponse userResponse = await APIService().getUserDetails(queryParameters);
    print(userResponse.toJson());

    userInfo = userResponse.data??UserInfo();

    load = true;
    setState(() {

    });
    setData();
  }

  getBodyM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking For",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: MyColors.black,
                fontSize: 18
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: RadioListTile(
                  title: Text("Myself"),
                  value: Booking.myself,
                  groupValue: booking,
                  onChanged: (Booking? value) {
                    setState(() {
                      booking = value!;
                    });
                    // nameController.text = name;
                    // mobile.text = phone;
                    // emailController.text = email;
                    // gstController.text = gst;
                    setData();
                  },
                ),
                flex: 1,
                fit: FlexFit.tight,
              ),
              Flexible(
                child: RadioListTile(
                  title: Text("Other"),
                  value: Booking.other,
                  groupValue: booking,
                  onChanged: (Booking? value) {
                    setState(() {
                      gst = false;
                      booking = value!;
                    });
                    nameController.text = "";
                    mobile.text = "";
                    emailController.text = "";
                    gstController.text = "";
                  },
                ),
                flex: 1,
                fit: FlexFit.tight,
              )
            ],
          ),
          Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  readOnly: booking==Booking.myself,
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
                SizedBox(height: 20,),
                // Container(
                //   padding: EdgeInsets.all(5),
                //   decoration: BoxDecoration(
                //       color: MyColors.white,
                //       borderRadius: BorderRadius.all(Radius.circular(3))
                //   ),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: (){
                //             if(booking==Booking.other) {
                //               showCountryPicker(
                //                 context: context,
                //                 countryListTheme: CountryListThemeData(
                //                   flagSize: 25,
                //                   backgroundColor: Colors.white,
                //                   textStyle: TextStyle(
                //                       fontSize: 16, color: Colors.blueGrey),
                //                   //Optional. Sets the border radius for the bottomsheet.
                //                   borderRadius: BorderRadius.only(
                //                     topLeft: Radius.circular(20.0),
                //                     topRight: Radius.circular(20.0),
                //                   ),
                //                   //Optional. Styles the search field.
                //                   inputDecoration: InputDecoration(
                //                     labelText: 'Search',
                //                     hintText: 'Start typing to search',
                //                     prefixIcon: const Icon(Icons.search),
                //                     border: OutlineInputBorder(
                //                       borderSide: BorderSide(
                //                         color: const Color(0xFF8C98A8)
                //                             .withOpacity(0.2),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 onSelect: (Country country) {
                //                   // print(country.phoneCode);
                //                   // logininfo.updateCountryCode("+"+country.phoneCode);
                //                   // print(logininfo.getCountryCode());
                //                 },
                //               );
                //             }
                //           },
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //             children: [
                //               // Consumer<LoginData>(builder: (context, data,child) {
                //               Text(code),
                //               // },),
                //               Icon(Icons.keyboard_arrow_down, color: MyColors.colorPrimary,),
                //             ],
                //           ),
                //         ),
                //         flex: 2,
                //       ),
                //       Expanded(
                TextFormField(
                  controller: mobile,
                  readOnly: booking==Booking.myself,
                  maxLength: 10,
                  cursorColor: MyColors.colorPrimary,
                  style: TextStyle(color: MyColors.black),
                  decoration: InputDecoration(
                      errorText: mobileValidate! ? mobileError : null,
                      hintText: "Mobile",
                      prefix: Text(
                        code+"\t",
                        style: TextStyle(
                            color: MyColors.black
                        ),
                      )
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      sendToast("* Required");
                      return null;
                    } else if (value.length != 10) {
                      sendToast("Enter valid mobile number");
                      return null;
                    } else {
                      return null;
                    }

                  },
                ),
                //         flex: 5,
                //       ),
                //     ],
                //   ),
                // ),
                TextFormField(
                  controller: emailController,
                  readOnly: booking==Booking.myself,
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
                TextFormField(
                  onChanged: (value)
                  {
                    if(value.length==15) {
                      getGSTDetails();
                    }
                    else {
                      legalNameController.text = "";
                      addressController.text = "";
                    }
                  },
                  controller: gstController,
                  readOnly: gst,
                  inputFormatters: [
                    UpperCaseTextFormatter()
                  ],
                  // readOnly: booking==Booking.myself,
                  cursorColor: MyColors.colorPrimary,
                  style: TextStyle(color: MyColors.black),
                  decoration: InputDecoration(
                    errorText: gstValidate! ? gstError : null,
                    label: Text("GST Number"),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 15,
                  validator: (value) {
                    if(value!.isNotEmpty && value?.length!=15) {
                      return "Enter valid gst number";
                    }
                    else if(value.isNotEmpty && !verified_gst) {
                      return "Invalid GSTIN / UID";
                    }
                    else {
                      return null;
                    }
                    //  if ((value?.isNotEmpty??false) && value?.length!=15) {
                    //   return "Enter valid gst number";
                    // } else {
                    //   return null;
                    // }
                  },
                ),
                TextFormField(
                  controller: legalNameController,
                  readOnly: true,
                  enabled: false,
                  // readOnly: booking==Booking.myself,
                  cursorColor: MyColors.colorPrimary,
                  style: TextStyle(color: MyColors.black),
                  decoration: InputDecoration(
                    label: Text("Legal Name"),
                  ),
                  keyboardType: TextInputType.text,
                ),
                TextFormField(
                  controller: addressController,
                  readOnly: true,
                  enabled: false,
                  // readOnly: booking==Booking.myself,
                  cursorColor: MyColors.colorPrimary,
                  style: TextStyle(color: MyColors.black),
                  decoration: InputDecoration(
                    label: Text("Legal Address"),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          getSpecialRequestsDesign(),
          SizedBox(height: 10,),
          getTravelDetailsDesign(),
          SizedBox(height: 10,),
          GestureDetector(
            onTap: () {
              if(load)
                confirmBooking();
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                  color: MyColors.colorPrimary,
                  borderRadius: BorderRadius.circular(3)
              ),
              child: Text(
                "CONFIRM BOOKING",
                style: TextStyle(
                  color: MyColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getBodyW() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size5(context), vertical: MySize.sizeh1(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Booking For",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: MyColors.black,
                      fontSize: 18
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Myself",
                          style: TextStyle(
                              fontSize: 14
                          ),
                        ),
                        value: Booking.myself,
                        groupValue: booking,
                        onChanged: (Booking? value) {
                          setState(() {
                            booking = value!;
                          });
                          // nameController.text = name;
                          // mobile.text = phone;
                          // emailController.text = email;
                          // gstController.text = gst;
                          setData();
                        },
                      ),
                      flex: 1,
                      fit: FlexFit.tight,
                    ),
                    Flexible(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Other"),
                        value: Booking.other,
                        groupValue: booking,
                        onChanged: (Booking? value) {
                          setState(() {
                            gst = false;
                            booking = value!;
                          });
                          nameController.text = "";
                          mobile.text = "";
                          emailController.text = "";
                          gstController.text = "";
                        },
                      ),
                      flex: 1,
                      fit: FlexFit.tight,
                    )
                  ],
                ),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        readOnly: booking==Booking.myself,
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
                      SizedBox(height: 20,),
                      // Container(
                      //   padding: EdgeInsets.all(5),
                      //   decoration: BoxDecoration(
                      //       color: MyColors.white,
                      //       borderRadius: BorderRadius.all(Radius.circular(3))
                      //   ),
                      //   child: Row(
                      //     children: <Widget>[
                      //       Expanded(
                      //         child: GestureDetector(
                      //           onTap: (){
                      //             if(booking==Booking.other) {
                      //               showCountryPicker(
                      //                 context: context,
                      //                 countryListTheme: CountryListThemeData(
                      //                   flagSize: 25,
                      //                   backgroundColor: Colors.white,
                      //                   textStyle: TextStyle(
                      //                       fontSize: 16, color: Colors.blueGrey),
                      //                   //Optional. Sets the border radius for the bottomsheet.
                      //                   borderRadius: BorderRadius.only(
                      //                     topLeft: Radius.circular(20.0),
                      //                     topRight: Radius.circular(20.0),
                      //                   ),
                      //                   //Optional. Styles the search field.
                      //                   inputDecoration: InputDecoration(
                      //                     labelText: 'Search',
                      //                     hintText: 'Start typing to search',
                      //                     prefixIcon: const Icon(Icons.search),
                      //                     border: OutlineInputBorder(
                      //                       borderSide: BorderSide(
                      //                         color: const Color(0xFF8C98A8)
                      //                             .withOpacity(0.2),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 onSelect: (Country country) {
                      //                   // print(country.phoneCode);
                      //                   // logininfo.updateCountryCode("+"+country.phoneCode);
                      //                   // print(logininfo.getCountryCode());
                      //                 },
                      //               );
                      //             }
                      //           },
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //             children: [
                      //               // Consumer<LoginData>(builder: (context, data,child) {
                      //               Text(code),
                      //               // },),
                      //               Icon(Icons.keyboard_arrow_down, color: MyColors.colorPrimary,),
                      //             ],
                      //           ),
                      //         ),
                      //         flex: 2,
                      //       ),
                      //       Expanded(
                      TextFormField(
                        controller: mobile,
                        readOnly: booking==Booking.myself,
                        maxLength: 10,
                        cursorColor: MyColors.colorPrimary,
                        style: TextStyle(color: MyColors.black),
                        decoration: InputDecoration(
                            errorText: mobileValidate! ? mobileError : null,
                            hintText: "Mobile",
                            prefix: Text(
                              code+" ",
                              style: TextStyle(
                                  color: MyColors.black
                              ),
                            )
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            sendToast("* Required");
                            return null;
                          } else if (value.length != 10) {
                            sendToast("Enter valid mobile number");
                            return null;
                          } else {
                            return null;
                          }

                        },
                      ),
                      //         flex: 5,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      TextFormField(
                        controller: emailController,
                        readOnly: booking==Booking.myself,
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
                      TextFormField(
                        onChanged: (value)
                        {
                          if(value.length==15) {
                            getGSTDetails();
                          }
                          else {
                            legalNameController.text = "";
                            addressController.text = "";
                          }
                        },
                        controller: gstController,
                        readOnly: gst,
                        inputFormatters: [
                          UpperCaseTextFormatter()
                        ],
                        // readOnly: booking==Booking.myself,
                        cursorColor: MyColors.colorPrimary,
                        style: TextStyle(color: MyColors.black),
                        decoration: InputDecoration(
                          errorText: gstValidate! ? gstError : null,
                          label: Text("GST Number"),
                        ),
                        keyboardType: TextInputType.text,
                        maxLength: 15,
                        validator: (value) {
                          if(value!.isNotEmpty && value.length!=15) {
                            return "Enter valid gst number";
                          }
                          else if(value.isNotEmpty && !verified_gst) {
                            return "Invalid GSTIN / UID";
                          }
                          else {
                            return null;
                          }
                          //  if ((value?.isNotEmpty??false) && value?.length!=15) {
                          //   return "Enter valid gst number";
                          // } else {
                          //   return null;
                          // }
                        },
                      ),
                      TextFormField(
                        controller: legalNameController,
                        readOnly: true,
                        enabled: false,
                        // readOnly: booking==Booking.myself,
                        cursorColor: MyColors.colorPrimary,
                        style: TextStyle(color: MyColors.black),
                        decoration: InputDecoration(
                          label: Text("Legal Name"),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      TextFormField(
                        controller: addressController,
                        readOnly: true,
                        enabled: false,
                        // readOnly: booking==Booking.myself,
                        cursorColor: MyColors.colorPrimary,
                        style: TextStyle(color: MyColors.black),
                        decoration: InputDecoration(
                          label: Text("Legal Address"),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(load)
                        confirmBooking();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 30, bottom: 30),
                      decoration: BoxDecoration(
                          color: MyColors.colorPrimary,
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Text(
                        "CONFIRM BOOKING",
                        style: TextStyle(
                          color: MyColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 30,),
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Column(
              children: [
                getSpecialRequestsDesign(),
                getTravelDetailsDesign()
              ],
            ),
          ),
        ],
      ),
    );
  }

  setData() {
    nameController.text = userInfo.user?.cusName??"";
    code = userInfo.user?.cusCc??"";
    mobile.text = userInfo.user?.cusMobile??"";
    emailController.text = userInfo.user?.cusEmail??"";
    gstController.text = userInfo.user?.cusGst??"";
    legalNameController.text = userInfo.user?.cusGstLegalName??"";
    addressController.text = userInfo.user?.cusGstAddress??"";
    stateCodeController.text = userInfo.user?.cusStateCode??"";

    gst = gstController.text.isEmpty ? false : true;
    verified_gst = gstController.text.isEmpty ? false : true;

    print("gst");
    print(gst);

    setState(() {

    });
  }

  getSpecialRequests() async {
    SpecialRequestResponse specialRequestResponse = await APIService().getSpecialRequests();
    print("specialRequestResponse.toJson()");
    print(specialRequestResponse.toJson());

    if (specialRequestResponse.status == 'Success' &&
        specialRequestResponse.message == 'Special Requests Retrieved')
      requests = specialRequestResponse.data ?? [];
    else
      requests = [];
    load = true;
    setState(() {

    });
  }

  getSpecialRequestsDesign(){
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.grey),
        borderRadius: BorderRadius.circular(10)
      ),
      child: ExpansionTile(
        backgroundColor: MyColors.white,
        collapsedBackgroundColor: MyColors.white,
        title: Text(
          "Special Requests",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        ),
        children: [
          getRequests(),
          if(others)
            getDescriptionDesign()
        ],
      ),
    );
    // return Container(
    //   color: MyColors.white,
    //   padding: EdgeInsets.all(15),
    //   width: MediaQuery.of(context).size.width,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "Special Requests",
    //         style: TextStyle(
    //           fontWeight: FontWeight.w500,
    //           fontSize: 16
    //         ),
    //       ),
    //       getRequests(),
    //       if(others)
    //         getDescriptionDesign()
    //     ],
    //   ),
    // );
  }

  getRequests() {
    return IgnorePointer(
      ignoring: false,
      child: GridView.builder(
        itemCount: requests.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: MySize.size05(context),
            mainAxisSpacing: MySize.sizeh05(context),
          mainAxisExtent: MySize.sizeh10(context)
        ),
        itemBuilder: (BuildContext context, index) {
          return getRequestsDesign(index);
        },
      ),
    );
  }

  getRequestsDesign(int ind) {
    return CheckboxListTile(
      value: selected.contains(ind),
      onChanged: (bool? value) {
        if(value!) {
          selected.add(ind);
          if((requests[ind].srName??"")=="Others")
            others = true;
        }
        else {
          selected.remove(ind);
          if((requests[ind].srName??"")=="Others") {
            others = false;
            otherController.text = "";
          }
        }
        setState(() {

        });
      },
      title: Text(
        requests[ind].srName??"",
        style: TextStyle(
          fontSize: MySize.font7(context)
        ),
      ),
    );
  }

  getDescriptionDesign(){
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: otherController,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\;')),
        ],
        maxLines: 4,
        decoration: InputDecoration(
            labelText: "Request"
        ),
      ),
    );
  }

  getTravelDetailsDesign(){
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.black),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getDates(),
          SizedBox(
            height: 20,
          ),
          getGuests(),
        ],
      ),
    );
  }

  getDates(){
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "CHECK-IN",
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    Strings.weekday[ds.weekday-1]+", "+ds.day.toString()+" "+Strings.month[ds.month-1]+", "+
                        (timing==0 ? 12 : timing>12 ? timing - 12 : timing).toString()+ (timing>=12 && timing!=24? ":00 PM" : ":00 AM"),
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: MySize.font8(context),
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "CHECK-OUT",
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    Strings.weekday[de.weekday-1]+", "+de.day.toString()+" "+Strings.month[de.month-1]+", "+
                        (de.hour==0 ? 12 : de.hour>12 ? de.hour - 12 : de.hour).toString()+ (de.hour>=12 && de.hour!=24? ":00 PM" : ":00 AM"),
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: MySize.font8(context),
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  getGuests(){
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1,),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Rooms",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                rooms.length.toString(),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Guests",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                guest.toString(),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: 2,),
          Text(
            "("+adult.toString()+(adult>1 ? " Adults" : " Adult")+(child>0 ? ", "+child.toString()+(child>1 ? " Children" : " Child") : "")+")",
            style: TextStyle(
                color: MyColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w300
            ),
          ),
          Divider(thickness: 1,),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Taxable Price",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  currency+taxable_price.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total GST ("+gst_per.toString()+"%)",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+currency+gst_amount.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Payable",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                currency+total_price.toString(),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  confirmBooking()
  {
    if (formkey.currentState!.validate()) {
      print("Validated");
      if(validate())
        showOptions();
    }
  }

  sendToast(String message){

    SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: getDepositAmount()<=0 && pay_at_hotel == 0 ? 100 : 200,
                width: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
                  color: MyColors.white
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(getDepositAmount()>0)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if(gesture)
                                bookNow("deposit");
                            },
                            child: Container(
                              height: MySize.sizeh6(context),
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: MyColors.colorPrimary,
                                  borderRadius: BorderRadius.circular(3)
                              ),
                              child: Text(
                                "PAY  $currency"+getDepositAmount().toString()+" to confirm",
                                style: TextStyle(
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18
                                ),
                              ),
                            ),
                          ),
                        ),
                      if(getDepositAmount()<=0 && pay_at_hotel==1)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if(gesture)
                                bookNow("hotel");
                            },
                            child: Container(
                              height: MySize.sizeh6(context),
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: MyColors.colorPrimary,
                                  borderRadius: BorderRadius.circular(3)
                              ),
                              child: Text(
                                "PAY AT HOTEL",
                                style: TextStyle(
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18
                                ),
                              ),
                            ),
                          ),
                        ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(gesture)
                              bookNow("full");
                          },
                          child: Container(
                            height: MySize.sizeh6(context),
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: MyColors.colorPrimary,
                                borderRadius: BorderRadius.circular(3)
                            ),
                            child: Text(
                              "PAY NOW",
                              style: TextStyle(
                                color: MyColors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 18
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      },
    );
  }

  int getDepositAmount() {
    print("deposit_type");
    print(deposit_type);
    return deposit_type=="Percentage" ? ((deposit*total_price)/100).round() : deposit;
  }

  Future<void> bookNow(String type) async {
    gesture = false;
    setState(() {

    });
    sharedPreferences = await SharedPreferences.getInstance();
    String requests = getRequestValues();
    Map<String, dynamic> data = this.data;
    data.addAll(
        {
          "b_for" : booking==Booking.myself ? "MYSELF" : "OTHER",
          "b_name" : nameController.text,
          "b_cc" : code,
          "b_mobile" : mobile.text,
          "b_email" : emailController.text,
          "pay_type" : type,
          "b_type" : type=="deposit" || type=="hotel" ? "HOTEL" : "OLR",
          "b_deposit" : type=="deposit" ? getDepositAmount().toString() : type=="full" ? total_price : "0",
          "b_request" : requests,
          APIConstant.act : APIConstant.add
        }
    );

    if(gstController.text.isNotEmpty) {
      data.addAll(
        {
          "b_gst": gstController.text,
          "b_legal_name": legalNameController.text,
          "b_legal_address": addressController.text,
          "b_state_code": stateCodeController.text.toUpperCase(),
        }
      );
    }

    print(data);
    ConfirmBookingResponse confirmBookingResponse = await APIService().insertBooking(data);
    print("hotelOfferResponse.toJson()");
    print(confirmBookingResponse.toJson());

    Navigator.pop(context);
    if(confirmBookingResponse.status=="Success") {
      b_id = confirmBookingResponse.bId??"";
      setState(() {

      });
      var options = {
        'key': confirmBookingResponse.apiKey,
        //amount in paise
        'amount': (double.parse(data['b_deposit']) * 100).toString(), //in the smallest currency sub-unit.
        'name': 'OLR Rooms',
        'order_id': confirmBookingResponse.billNo, // Generate order_id using Orders API
        'description': 'Booking',
        'timeout': 300, // in seconds
        // 'prefill': {
        //   'contact': '9586033791',
        //   'email': 'hritvi16gajiwala@gmail.com'
        // }
      };

      print(options);
      // _razorpay.open(options);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          SuccessPage()
      )
      ).then((value) {
        DeleteCache.deleteKey("key_booking");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => Home()),
                (Route<dynamic> route) => false);
      });

    }
    else {
      Toast.sendToast(context, confirmBookingResponse.message??"");
    }
  }

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await getUserInfo();
    // await getSpecialRequests();
  }

  bool validate() {
    // if(gstController.text.isEmpty) {
    //   gstValidate = false;
    //   gstError = "Enter gst number";
    // }
    // else if(gstController.text.isNotEmpty && gstController.text.length!=15) {
    //   gstValidate = false;
    //   gstError = "Enter valid gst number";
    // }
    // else if(gstController.text.isNotEmpty && !verified_gst) {
    //   gstValidate = false;
    //   gstError = "Invalid GSTIN / UID";
    // }
    // else {
    //   gstValidate = true;
    //   gstError = null;
    // }
    if(others && otherController.text.isEmpty) {
      Toast.sendToast(context, "Please write your request.");
      return false;
    }
    return true;
  }

  String getRequestValues() {
    String req = "";
    for(int i = 0 ; i < selected.length ; i++)
    {
      print("req");
      req += ((requests[selected[i]].srName??"")=="Others" ? otherController.text : (requests[selected[i]].srName??""));

      print(req);
      if(i<selected.length-1)
        req+=";";
    }
    return req;
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

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   print("Success");
  //   print(response.paymentId);
  //   print(response.orderId);
  //   print(response.signature);
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) =>
  //       SuccessPage()
  //   )
  //   ).then((value) {
  //     DeleteCache.deleteKey("key_booking");
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //             builder: (BuildContext context) => const Dashboard(selectedIndex: 1)),
  //             (Route<dynamic> route) => false);
  //   });
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   print("Error");
  //   print(response.message);
  //   print(response.code);
  //   gesture = true;
  //   setState(() {
  //
  //   });
  //   deleteBooking();
  // }
  //
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   print("External Wallet");
  //   print(response.walletName);
  // }

  deleteBooking()
  {
    print(b_id);
    Map<String, dynamic> data = {
          "b_id" : b_id,
          APIConstant.act : APIConstant.delete
        };
    print(data);
    APIService().deleteBooking(data);


  }

  @override
  void dispose() {
    // _razorpay.clear();
    super.dispose();
  }


}
