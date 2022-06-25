import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  bool load = false;
  List<HotelInfo> wishlist = [];
  List<bool> r_enabled = [];

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ?Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "WISHLIST"),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                children: [
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                    child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                        : MenuBar(sharedPreferences: sharedPreferences, name: "WISHLIST"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: wishlist.isNotEmpty ? constraints.maxWidth < 600 ? getWishlistDesignM() : getWishlistDesignW()
                          :
                      Center(
                        child: Text("No Saved Properties"),
                      ),
                    ),
                  )
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

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    checkCache();
  }

  Future<void> checkCache() async {
    CacheManagerUtils.conditionalCache(
        key: "key_wishlist",
        valueType: ValueType.BoolValue,
        actionIfNull: () async {
          load = false;
          setState(() {

          });
          getWishlist();
        },
        actionIfNotNull: () async {
          print("hdhdh");
          HotelResponse hotelResponse = HotelResponse.fromJson(await ReadCache.getJson(key: "wishlist"));
          wishlist = hotelResponse.data ?? [];

          r_enabled = List.filled(wishlist.length, false);

          load = true;
          setState(() {

          });
        }
    );
  }

  getWishlistDesignW(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: MySize.sizeh2(context),
            mainAxisSpacing: MySize.sizeh2(context),
            mainAxisExtent: 150
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: wishlist.length,
        itemBuilder: (BuildContext context, index){
          return getHotelDesignW(wishlist[index], index);
        },
      ),
    );
  }


  getWishlistDesignM(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: wishlist.length,
        separatorBuilder: (BuildContext context, index){
          return SizedBox(height: MySize.sizeh2(context));
        },
        itemBuilder: (BuildContext context, index){
          return getHotelDesignM(wishlist[index], index);
        },
      ),
    );
  }


  getHotelDesignW(HotelInfo hotel, int ind) {
    double base = 0;
    double discount = 0;
    base = double.parse(hotel.hotel?.cpBase??"0");
    discount = double.parse(hotel.hotel?.cpDiscount??"0");
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HotelDetails(h_id: hotel.hotel?.hId??"",)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(MySize.sizeh1(context)),
                      bottomLeft: Radius.circular(MySize.sizeh1(context))),
                  child: (hotel.hotel?.hImageCount??"0")=="0" ? const Icon(
                      Icons.image_not_supported_outlined,
                    )
                      : Image.network(
                    Environment.imageUrl + (hotel.images?[0].hiImage??""),
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context), horizontal: MySize.size1(context)),
                      alignment: AlignmentDirectional.topStart,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 5,
                                fit: FlexFit.tight,
                                child: Text(
                                  hotel.hotel?.hName??"",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF212121),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: IgnorePointer(
                                  ignoring: r_enabled[ind],
                                  child: GestureDetector(
                                    onTap: () {
                                      r_enabled[ind] = !r_enabled[ind];
                                      setState(() {

                                      });

                                      print(r_enabled);
                                      if(hotel.hotel?.liked!="0")
                                        manageWishlist(APIConstant.del, hotel, ind);
                                      else
                                        manageWishlist(APIConstant.add, hotel, ind);
                                    },
                                    child: Container(
                                        alignment: Alignment.topCenter,
                                        child: Icon(
                                          hotel.hotel?.liked!="0"
                                              ? Icons.star
                                              : Icons.star_border,
                                          color:
                                          hotel.hotel?.liked!="0" ? Colors.red : Colors.white,
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MySize.sizeh1(context),
                          ),
                          Text(
                            (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              color: MyColors.grey,
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
                                  fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: APIConstant.symbol + base.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.lineThrough,
                                        color: MyColors.black,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16,
                                    )
                                ),
                                TextSpan(text: "  " + discount.floor().toString() +
                                    "% OFF",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: MyColors.orange,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 14,
                                    )
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  getHotelDesignM(HotelInfo hotel, int ind) {
    double base = 0;
    double discount = 0;
    base = double.parse(hotel.hotel?.cpBase??"0");
    discount = double.parse(hotel.hotel?.cpDiscount??"0");
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HotelDetails(h_id: hotel.hotel?.hId??"",)));
      },
      child: Container(
        height: 150,
        margin: EdgeInsets.only(bottom: 2, left: 2, right: 2),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
                child: (hotel.hotel?.hImageCount??"0")=="0" ? Container(
                  width: 300,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                  ),
                )
                    : Image.network(
                  Environment.imageUrl + (hotel.images?[0].hiImage??""),
                  fit: BoxFit.fill,
                  height: MediaQuery.of(context).size.height,
                  width: 300,
                ),
              ),
            ),
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: AlignmentDirectional.topStart,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 5,
                              fit: FlexFit.tight,
                              child: Text(
                                hotel.hotel?.hName??"",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  color: Color(0xFF212121),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: IgnorePointer(
                                ignoring: r_enabled[ind],
                                child: GestureDetector(
                                  onTap: () {
                                    r_enabled[ind] = !r_enabled[ind];
                                    setState(() {

                                    });

                                    print(r_enabled);
                                    if(hotel.hotel?.liked!="0")
                                      manageWishlist(APIConstant.del, hotel, ind);
                                    else
                                      manageWishlist(APIConstant.add, hotel, ind);
                                  },
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        hotel.hotel?.liked!="0"
                                            ? Icons.star
                                            : Icons.star_border,
                                        color:
                                        hotel.hotel?.liked!="0" ? Colors.red : Colors.white,
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            color: MyColors.grey,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(
                          height: 10,
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
                                fontSize: 20,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: APIConstant.symbol + base.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      decoration: TextDecoration.lineThrough,
                                      color: MyColors.black,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 18,
                                  )
                              ),
                              TextSpan(text: "  " + discount.floor().toString() +
                                  "% OFF",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.orange,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 16,
                                  )
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getWishlist() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getAll
    };
    HotelResponse hotelResponse = await APIService().getWishlistHotels(queryParameters);
    print(hotelResponse.toJson());
    if (hotelResponse.status == 'Success' && hotelResponse.message == 'Wishlist Retrieved') {
      wishlist = hotelResponse.data ?? [];
    }
    else
      wishlist = [];

    r_enabled = List.filled(wishlist.length, false);

    await WriteCache.setBool(key: "key_wishlist", value: true);
    await WriteCache.setJson(key: "wishlist", value: hotelResponse.toJson());
    List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
    keys.add("key_wishlist");
    keys.add("wishlist");
    await WriteCache.setListString(key: "keys", value: keys);

    load = true;
    setState(() {

    });
  }

  Future<void> manageWishlist(String act, HotelInfo hotel, int ind) async {
    hotel.hotel?.hId;
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
    DeleteCache.deleteKey("key_h"+(hotel.hotel?.hId??"-1"));
    DeleteCache.deleteKey("key_dashboard");
    load = true;
    setState(() {

    });

    print(r_enabled);

    Toast.sendToast(context, wishlistResponse.message??"");
    getWishlist();
  }
}
