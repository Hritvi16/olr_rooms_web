import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:olr_rooms_web/BecomePartner.dart';
import 'package:olr_rooms_web/Bookings.dart';
import 'package:olr_rooms_web/Login.dart';
import 'package:olr_rooms_web/LoginPopUp.dart';
import 'package:olr_rooms_web/Support.dart';
import 'package:olr_rooms_web/Wishlist.dart';
import 'package:olr_rooms_web/about_us/AboutUs.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/help/Help.dart';
import 'package:olr_rooms_web/helpline/Helpline.dart';
import 'package:olr_rooms_web/offers/Offers.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/profile/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'home/Home.dart';

class Essential {

  loginPopUp(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const LoginPopUp(
          msg: "For accessing this feature you need to login.",
          key1: 'Cancel',
          key2: 'Login',
        );
      },
    ).then((value) {
      if(value=="Login")
        logout(context);
    });
  }

  void logoutTask(BuildContext context) {
    confirmLogout(context);

  }

  void confirmLogout(BuildContext context) {
    BuildContext dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 10, top: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Text("Are you sure you want to logout?",
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
                new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    new TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text("No",
                          style: TextStyle(
                              color: MyColors.colorPrimary
                          ),
                        )
                    ),
                    new TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          logout(context);
                        },
                        child: Text("Yes",
                          style: TextStyle(
                              color: MyColors.colorPrimary
                          ),
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("login_type", "");
    sharedPreferences.setString("status", "logged out");
    sharedPreferences.setString("user_id", "");
    List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
    for(int i = 0; i<keys.length; i++) {
      DeleteCache.deleteKey(keys[i]);
    }
    await WriteCache.setListString(key: "keys", value: []);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Login()),
            (Route<dynamic> route) => false
    );
  }

  directTo(BuildContext context, int index) async {
    if(index==0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Home()
          )
      );
    }
    if(index==1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Offers()
          )
      );
    }
    else if(index==2) {
      openBecomePartnerForm(context);
    }
    if(index==3) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              AboutUs(
                policy_type: "About Us",
                act: APIConstant.getAU,
                h_id: "",
              )
          )
      );
    }
    if(index==4) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Helpline()
          )
      );
    }
    else if(index==5) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Help()
          )
      );
    }
    else if(index==6) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Profile()
          )
      );
    }
    else if(index==7) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Wishlist()
          )
      );
    }
    else if(index==8) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Bookings()
          )
      );
    }
    else if(index==9) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Support()
          )
      );
    }
    else if(index==10) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if(sharedPreferences.getString("login_type")=="customer") {

        logoutTask(context);
      }
      else{
        logout(context);
      }
    }
    else if(index==11) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Policies(
                policy_type: "Terms & Conditions",
                act: APIConstant.getTC,
                h_id: "",
              )
          )
      );
    }
    else if(index==12) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Policies(
                policy_type: "Guest Policy",
                act: APIConstant.getGP,
                h_id: "",
              )
          )
      );
    }
    else if(index==13) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Policies(
                policy_type: "Privacy Policy",
                act: APIConstant.getPP,
                h_id: "",
              )
          )
      );
    }
    else if(index==14) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Policies(
                policy_type: "Cancellation Policy",
                act: APIConstant.getCP,
                h_id: "",
              )
          )
      );
    }
    else if(index==15) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              Policies(
                policy_type: "Rules",
                act: APIConstant.getR,
                h_id: "",
              )
          )
      );
    }
  }
  void openBecomePartnerForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BecomePartner();
      },
    );
    // showModalBottomSheet(
    //     context: context,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    //     ),
    //     builder: (BuildContext context) {
    //       return BecomePartner();
    //     }
    // );
  }

  call(String number) {
    launchUrlString("tel://"+(number));
  }

  link(String link) {
    launchUrlString(link);
  }

  map(double lat, double long, String place) {
    MapsLauncher.launchCoordinates(
        lat,
        long,
        place
    );
  }

  email(String email) {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Example Subject & Symbols are allowed!'
      }),
    );

    launchUrl(emailLaunchUri);
  }
}