import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/Login.dart';
import 'package:olr_rooms_web/LoginPopUp.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/filters/Filters.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchList extends StatefulWidget {
  final String id, name, type;
  const SearchList({Key? key, required this.id,  required this.name, required this.type}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  List<HotelInfo> search_list = [];
  List<bool> r_enabled = [];

  String id = "";
  String name = "";
  String type = "";

  bool load = false;
  double ss = 0;
  double es = 0;

  double grs = 0;
  double gre = 0;

  double ps = 0;
  double pe = 0;

  String sort = "";
  bool payAtHotel = false;
  List<String> tappeda = [];
  List<int> tappeds = [];

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  @override
  void initState() {
    id = widget.id;
    name = widget.name;
    type = widget.type;
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HELP"),
        backgroundColor: MyColors.white,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                margin: constraints.maxWidth < 600 ? null : EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    constraints.maxWidth < 600 ? MenuBarM(
                        sharedPreferences: sharedPreferences,
                        scaffoldkey: scaffoldkey)
                        : MenuBar(
                        sharedPreferences: sharedPreferences, name: "SEARCHLIST"),
                    Expanded(
                        child: getBody(constraints.maxWidth)
                    ),
                  ],
                ),
              );
            }
        )
    ) :
    Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  getBody(double width) {
    return Padding(
      padding: width < 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context))
          : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogContext) {
                          return Filters(
                            sort: sort,
                            payAtHotel: payAtHotel,
                            ps: ps,
                            pe: pe,
                            ss: ss,
                            es: es,
                            grs: grs,
                            gre: gre,
                            tappeda: tappeda,
                            tappeds: tappeds,
                          );
                        },
                      ).then((value) {
                        if(value!=null) {
                          if ((value['filter']!=null && value['filter'].toString().isNotEmpty) || (value['sort_by']!=null && value['sort_by'].toString().isNotEmpty)) {
                            getFilteredHotels(value['filter'].toString(), value['sort_by'].toString());
                          }
                          sort = value['sort'];
                          payAtHotel = value['payAtHotel'];
                          ps = value['ps'];
                          pe = value['pe'];
                          ss = value['ss'];
                          es = value['es'];
                          grs = value['grs'];
                          gre = value['gre'];
                          tappeda = value['tappeda'];
                          tappeds = value['tappeds'];
                          setState(() {

                          });
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context), horizontal: MySize.size1(context)),
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        borderRadius: BorderRadius.circular(MySize.sizeh055(context)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            color: MyColors.black,
                          ),
                          SizedBox(
                            width: MySize.size1(context),
                          ),
                          const Text(
                            "Filters",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              itemCount: search_list.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, index) {
                return SizedBox(height: MySize.sizeh4(context));
              },
              itemBuilder: (BuildContext context, index) {
                return getHotelDesign(search_list[index], index, width);
              },
            ),
          ),
        ],
      ),
    );
  }

  getHotelDesign(HotelInfo hotelInfo, int ind, double width) {
    double base = 0;
    double discount = 0;
    base = double.parse(hotelInfo.hotel?.cpBase??"0");
    discount = double.parse(hotelInfo.hotel?.cpDiscount??"0");

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
              HotelDetails(h_id: hotelInfo.hotel?.hId ?? "",)
            )
          );
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: MySize.size15(context),
                    width: MediaQuery.of(context).size.width,
                    child: (hotelInfo.images?.length??0) > 0 ? ListView.separated(
                      itemCount: hotelInfo.images?.length??0,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, index) {
                        return SizedBox(width: MySize.size1(context));
                      },
                      itemBuilder: (BuildContext context, index) {
                        return getImage(hotelInfo.images?[index].hiImage??"");
                      },
                    ) :
                    ClipRRect(
                        borderRadius: BorderRadius.circular(MySize.size1(context)),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: width < 600 ? MySize.sizeh5(context) : MySize.sizeh10(context),
                        )
                    ),
                  ),
                  IgnorePointer(
                    ignoring: r_enabled[ind],
                    child: IconButton(
                        onPressed: () {
                          if(sharedPreferences?.getString("login_type")=="customer") {
                            r_enabled[ind] = !r_enabled[ind];
                            setState(() {

                            });

                            print(r_enabled);
                            if (hotelInfo.hotel?.liked != "0")
                              manageWishlist(APIConstant.del, hotelInfo, ind);
                            else
                              manageWishlist(APIConstant.add, hotelInfo, ind);
                          }
                          else {
                            loginPopUp();
                          }
                        },
                        icon: Icon(
                          hotelInfo.hotel?.liked!="0"
                              ? Icons.star
                              : Icons.star_border,
                          color:
                          hotelInfo.hotel?.liked!="0" ? MyColors.colorPrimary.withOpacity(0.9) : MyColors.white,
                        )
                    ),
                  )
                ],
              ),
              SizedBox(
                height: MySize.sizeh1_5(context),
              ),
              Text(
                hotelInfo.hotel?.hName??"",
                style: TextStyle(
                    fontSize: width < 600 ? MySize.font11(context) : MySize.font8(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(
                height: MySize.sizeh075(context),
              ),
              Text(
                (hotelInfo.area?.arName??"") + ", " + (hotelInfo.city?.cName??""),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width < 600 ? MySize.font10_5(context) : MySize.font7_75(context),
                  color: MyColors.grey30,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(
                height: MySize.sizeh2(context),
              ),
              RichText(
                text: TextSpan(
                  text: APIConstant.symbol + (base - (base * (discount / 100.0)))
                      .floor()
                      .toString() + "  ",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: MyColors.black,
                      overflow: TextOverflow.ellipsis,
                      fontSize: width < 600 ? MySize.font10(context) : MySize.font8(context),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: APIConstant.symbol + base.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.lineThrough,
                            color: MyColors.black,
                            overflow: TextOverflow.ellipsis,
                            fontSize: width < 600 ? MySize.font9_5(context) : MySize.font7_5(context),
                        )
                    ),
                    TextSpan(text: "  " + discount.floor().toString() +
                        "% OFF",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: MyColors.orange,
                            overflow: TextOverflow.ellipsis,
                            fontSize: width < 600 ? MySize.font9_25(context) : MySize.font7_25(context),
                        )
                    ),
                  ],
                ),
              )
            ],
          ),
      ),
    );
  }

  loginPopUp() {
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
        logout();
    });
  }

  Future<void> logout() async {
    sharedPreferences?.setString("login_type", "");
    sharedPreferences?.setString("status", "logged out");
    sharedPreferences?.setString("user_id", "");
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

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getSearchedHotels();
  }

  Future<void> getSearchedHotels() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByType,
      "id" : id,
      "name" : name,
      "type" : type
    };

    HotelResponse hotelResponse = await APIService().getSearchedHotels(data);
    print("hotelResponse.toJson()");
    print(hotelResponse.toJson());
    print(hotelResponse.status);
    print(hotelResponse.message);

    if(hotelResponse.status=="Success" && hotelResponse.message=="Hotels Retrieved") {
      search_list = hotelResponse.data??[];
    }
    else {
      search_list = [];
      Toast.sendToast(context, hotelResponse.message??"");
    }

    r_enabled = List.filled(search_list.length, false);
    load = true;
    setState(() {

    });
  }

  Future<void> getFilteredHotels(String filter, sort_by) async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByFilter,
      "id" : id,
      "type" : type,
      "filter" : filter,
      "sort_by" : sort_by,
      "name" : name
    };

    print("dataaaa");
    print(data);
    print(filter);
    print(sort_by);

    HotelResponse hotelResponse = await APIService().getFilteredHotels(data);
    print("hotelResponse.toJson()");
    print(hotelResponse.toJson());
    print(hotelResponse.message);
    print(hotelResponse.status);

    if(hotelResponse.status=="Success" && hotelResponse.message=="Hotels Retrieved") {
      search_list = hotelResponse.data??[];
    }
    else {
      search_list = [];
      Toast.sendToast(context, hotelResponse.message??"");
    }

    r_enabled = List.filled(search_list.length, false);

    setState(() {

    });
  }

  getImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MySize.sizeh1(context)),
      child: Image.network(
        Environment.imageUrl + image,
        fit: BoxFit.fill,
        width: MySize.size30(context),
      )
    );
  }

  Future<void> manageWishlist(String act, HotelInfo hotel, int ind) async {
    Map<String, String> data = {
      APIConstant.act: act,
      if(act==APIConstant.add)
        'h_id' : hotel.hotel?.hId??"-1"
      else
        'w_id' : hotel.hotel?.liked??"-1"
    };

    WishlistResponse wishlistResponse = await APIService().manageWishlist(data);
    print(wishlistResponse.toJson());
    if (wishlistResponse.status == 'Success') {
      hotel.hotel?.liked = wishlistResponse.data;
    }

    r_enabled[ind] = !r_enabled[ind];
    DeleteCache.deleteKey("key_dashboard");
    DeleteCache.deleteKey("key_wishlist");
    DeleteCache.deleteKey("key_h"+(hotel.hotel?.hId??"-1"));
    setState(() {

    });

    print(r_enabled);

    Toast.sendToast(context, wishlistResponse.message??"");
  }
}
