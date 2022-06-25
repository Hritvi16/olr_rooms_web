import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/filters/Filters.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetailsW.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

class BannerHotels extends StatefulWidget {
  final String id;
  const BannerHotels({Key? key, required this.id}) : super(key: key);

  @override
  State<BannerHotels> createState() => _BannerHotelsState();
}

class _BannerHotelsState extends State<BannerHotels> {
  List<HotelInfo> banner_hotels = [];
  List<bool> r_enabled = [];

  String id = "";

  bool load = false;
  
  @override
  void initState() {
    id = widget.id;
    print(id);
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: ListView.separated(
              itemCount: banner_hotels.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (BuildContext context, index) {
                return SizedBox(height: 5);
              },
              itemBuilder: (BuildContext context, index) {
                return getHotelDesign(banner_hotels[index], index);
              },
            ),
          ),
      ),
    );
  }

  getHotelDesign(HotelInfo hotelInfo, int ind) {
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
        child: Container(
          height: MySize.sizeh80(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: MySize.size90(context),
                    width: MediaQuery.of(context).size.width,
                    child: (hotelInfo.images?.length??0) > 0 ? ListView.separated(
                      itemCount: hotelInfo.images?.length??0,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (BuildContext context, index) {
                        return SizedBox(width: 5);
                      },
                      itemBuilder: (BuildContext context, index) {
                        return getImage(hotelInfo.images?[index].hiImage??"");
                      },
                    ) :
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: MySize.size50(context),
                        )
                    ),
                  ),
                  IgnorePointer(
                    ignoring: r_enabled[ind],
                    child: IconButton(
                        onPressed: () {
                          r_enabled[ind] = !r_enabled[ind];
                          setState(() {

                          });

                          print(r_enabled);
                          if(hotelInfo.hotel?.liked!="0")
                            manageWishlist(APIConstant.del, hotelInfo, ind);
                          else
                            manageWishlist(APIConstant.add, hotelInfo, ind);
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
                height: MySize.size10(context),
              ),
              Text(
                hotelInfo.hotel?.hName??"",
                style: TextStyle(
                    fontSize: MySize.font18(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(
                height: MySize.size2(context),
              ),
              Text(
                (hotelInfo.area?.arName??"") + ", " + (hotelInfo.city?.cName??""),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MySize.font14(context),
                  color: MyColors.grey30,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: MySize.size10(context),
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
                      fontSize: MySize.font18(context)
                  ),
                  children: <TextSpan>[
                    TextSpan(text: APIConstant.symbol + base.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            decoration: TextDecoration.lineThrough,
                            color: MyColors.black,
                            overflow: TextOverflow.ellipsis,
                            fontSize: MySize.font12(context)
                        )
                    ),
                    TextSpan(text: "  " + discount.floor().toString() +
                        "% OFF",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: MyColors.orange,
                            overflow: TextOverflow.ellipsis,
                            fontSize: MySize.font14(context)
                        )
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void start() {
    getBannerHotels();
  }

  Future<void> getBannerHotels() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByBanner,
      "id" : id,
    };
    print(data);
    HotelResponse hotelResponse = await APIService().getBannerHotels(data);
    print("hotelResponse.toJson()");
    print(hotelResponse.toJson());
    print(hotelResponse.status);
    print(hotelResponse.message);

    if(hotelResponse.status=="Success" && hotelResponse.message=="Hotels Retrieved") {
      banner_hotels = hotelResponse.data??[];
    }
    else {
      banner_hotels = [];
      Toast.sendToast(context, hotelResponse.message??"");
    }

    r_enabled = List.filled(banner_hotels.length, false);

    setState(() {

    });
  }

  getImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.network(
        Environment.imageUrl + image,
        fit: BoxFit.fill,
        width: MySize.size70(context),
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
