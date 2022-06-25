import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:olr_rooms_web/Bookings.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/GlobalSearch.dart';
import 'package:olr_rooms_web/home/HomeW.dart';
import 'package:olr_rooms_web/Notifications.dart';
import 'package:olr_rooms_web/SearchList.dart';
import 'package:olr_rooms_web/Wishlist.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetailsW.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';
import 'package:olr_rooms_web/offers/Offers.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/Home.dart';
import 'responsive.dart';
import 'menu_item.dart';

class Header extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const Header({
    Key? key, required this.sharedPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/logo/appbar_logo.png',
            width: 100,
            color: MyColors.colorPrimary,
            fit: BoxFit.fill,
          ),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: true,
              cursorColor: MyColors.colorPrimary,
              style: TextStyle(color: MyColors.black),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors.white),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  fillColor: MyColors.white,
                  filled: true,
                  hintText: "Search for Hotel, City or Location",
                  hintStyle: TextStyle(
                      fontSize: 10
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 10,
                  )
              ),
              keyboardType: TextInputType.name,
            ),
            suggestionsCallback: (pattern) async {
              return await GlobalSearch().search(pattern);
            },
            itemBuilder: (context, SearchInfo suggestion) {
              return Container(
                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: Text(
                  suggestion.search?.name??"",
                  style: TextStyle(
                      fontSize: 10
                  ),
                ),
              );
            },
            // noItemsFoundBuilder: (context) {
            //   return Container(
            //     height: 0,
            //   );
            // },
            onSuggestionSelected: (SearchInfo suggestion) {
              if((suggestion.type??"")=='hotel') {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        HotelDetails(h_id: suggestion.search?.id ?? "",)));
              }
              else {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        SearchList(id: suggestion.search?.id ?? "", name: suggestion.search?.name ?? "", type: suggestion.type??"",)));
              }
            },
          ),
          Spacer(),

          if (!isMobile(context))
            Row(
              children: [
                NavItem(
                  title: 'Home',
                  tapEvent: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Home())).then((value) {

                      // checkCache();
                    });
                  },
                ),
                NavItem(
                  title: 'Booking',
                  tapEvent: () {
                    Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) => Bookings())).then((value) {

                      // checkCache();
                    });
                  },
                ),
                NavItem(
                  title: 'Offer',
                  tapEvent: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Offers()));
                  },
                ),
                NavItem(
                  title: 'Support',
                  tapEvent: () {},
                ),
                PopupMenuButton(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    tooltip: "For more options",
                    position: PopupMenuPosition.under,
                    child: NavItem(
                      title: 'More',
                      tapEvent: null,
                    ),
                    itemBuilder: (context) {
                      return List.generate(Strings.menu.length+1, (index) {
                        return index!=5 ? PopupMenuItem(
                          child: GestureDetector(
                            onTap: () {
                              if(index==0) {
                                if(sharedPreferences.getString("login_type")=="customer") {
                                  Navigator.push(
                                      context, MaterialPageRoute(
                                      builder: (context) => Wishlist())).then((value) {

                                    // checkCache();
                                  });
                                }
                                else{
                                  Essential().loginPopUp(context);
                                }
                              }
                              else {
                                Essential().directTo(context, index);
                              }
                            },
                            child: ListTile(
                              leading: Icon(index!=6 ? Strings.menuIcons[index] : Icons.logout),
                              title: Text(index!=6 ? Strings.menu[index] : sharedPreferences.getString("login_type")=="customer" ? 'Logout' : "Login"),
                            ),
                          ),
                        )
                            : PopupMenuItem(
                          child: ExpansionTile(
                            leading: Icon(Strings.menuIcons[index]),
                            title: Text(Strings.menu[index]),
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          Policies(
                                            policy_type: "Terms & Conditions",
                                            act: APIConstant.getTC,
                                            h_id: "",
                                          )
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(Icons.description),
                                  title: Text('Terms & Conditions'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          Policies(
                                            policy_type: "Guest Policy",
                                            act: APIConstant.getGP,
                                            h_id: "",
                                          )
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(Icons.local_police_outlined),
                                  title: Text('Guest Policy'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          Policies(
                                            policy_type: "Privacy Policy",
                                            act: APIConstant.getPP,
                                            h_id: "",
                                          )
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(Icons.lock_outline),
                                  title: Text('Privacy Policy'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          Policies(
                                            policy_type: "Cancellation Policy",
                                            act: APIConstant.getCP,
                                            h_id: "",
                                          )
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(Icons.policy_outlined),
                                  title: Text('Cancellation Policy'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          Policies(
                                            policy_type: "Rules",
                                            act: APIConstant.getR,
                                            h_id: "",
                                          )
                                      )
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(Icons.rule),
                                  title: Text('Rules'),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    onSelected: (value) {
                      print(value);
                    },
                  ),

                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => Notifications()));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hello, "+(sharedPreferences.getString("name")??"Guest"),
                          overflow: TextOverflow.fade ,
                          style: TextStyle(
                              fontSize: 16
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),

          if (isMobile(context))
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              }
            )
        ],
      ),
    );
  }
}