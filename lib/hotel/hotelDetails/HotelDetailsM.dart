import 'dart:convert';

import 'package:cache_manager/cache_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/Login.dart';
import 'package:olr_rooms_web/LoginPopUp.dart';
import 'package:olr_rooms_web/amenities/Amenities.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/bookingDetails/BookingDetails.dart';
import 'package:olr_rooms_web/bookingDetails/ConfirmBooking.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/components.dart';
import 'package:olr_rooms_web/hotel/HotelImages.dart';
import 'package:olr_rooms_web/hotel/MapView.dart';
import 'package:olr_rooms_web/model/CategoryInfo.dart';
import 'package:olr_rooms_web/model/CategoryResponse.dart';
import 'package:olr_rooms_web/model/HotelDetailResponse.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/HotelOfferResponse.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/HotelSlotsResponse.dart';
import 'package:olr_rooms_web/model/HotelTimingsResponse.dart';
import 'package:olr_rooms_web/model/Nearby.dart';
import 'package:olr_rooms_web/model/NearbyResponse.dart';
import 'package:olr_rooms_web/model/OfferInfo.dart';
import 'package:olr_rooms_web/model/Reviews.dart';
import 'package:olr_rooms_web/model/ReviewsResponse.dart';
import 'package:olr_rooms_web/model/SpecialRequest.dart';
import 'package:olr_rooms_web/model/TimePeriod.dart';
import 'package:olr_rooms_web/model/Timings.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/nearby_places/NearbyPlaces.dart';
import 'package:olr_rooms_web/offers/AllOffers.dart';
import 'package:olr_rooms_web/path/path_constant.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/reviews/AllReviews.dart';
import 'package:olr_rooms_web/reviews/AllReviewsM.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:olr_rooms_web/support/RaiseTicket.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HotelDetailsM extends StatefulWidget {
  final String h_id;
  const HotelDetailsM({Key? key, required this.h_id}) : super(key: key);

  @override
  State<HotelDetailsM> createState() => _HotelDetailsMState();
}

class _HotelDetailsMState extends State<HotelDetailsM> with TickerProviderStateMixin {
  AnimationController? controller;

  HotelInfo hotelInfo = HotelInfo();
  TimePeriod timePeriod = TimePeriod();
  List<CategoryInfo> categories = [];
  List<Timings> timings = [];
  List<OfferInfo> offers = [];


  var unescape = HtmlUnescape();

  List<Widget> slideShow = [];

  bool show = false;

  int pos = 0;
  bool isReadmore = false;
  bool r_enabled = false;
  List<bool> s_enabled = [];

  int offer = -1;
  bool show_bill = false;

  int category = 0;

  List<int> slots = [];

  int slot = 3;
  int timing = 0;
  int guest = 1;
  int adult = 1;
  int child = 0;
  DateTime dt = DateTime.now();
  DateTime ds = DateTime.now();
  DateTime de = DateTime.now();


  List<Map<String, dynamic>> rooms = [];
  List<SpecialRequest> requests = [];
  
  int breakfast = 0;
  int lunch = 0;
  int dinner = 0;


  List<HotelInfo> similar = [];
  List<Nearby> places = [];
  List<Reviews> ratings = [];

  bool show_pay = true;

  double gst = 18.0;

  String h_id = "";

  bool load = false;

  late SharedPreferences sharedPreferences;
  bool generate = false;

  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    h_id = widget.h_id;
    start();
    // initValues();
    rooms.add({"adult" : adult, "child" : child});

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    checkCache();
  }
  void checkCache() {
    CacheManagerUtils.conditionalCache(
        key: "key_h"+h_id,
        valueType: ValueType.BoolValue,
        actionIfNull: () async {
          load = false;
          setState(() {

          });
          await getHotelDetailsM();
        },
        actionIfNotNull: () async {
          HotelDetailResponse hotelDetailResponse = HotelDetailResponse.fromJson(await ReadCache.getJson(key: "h"+h_id));
          hotelInfo = hotelDetailResponse.hotel ?? HotelInfo();
          places = hotelDetailResponse.nearby ?? [];
          ratings = hotelDetailResponse.reviews ?? [];
          similar = hotelDetailResponse.hotels ?? [];
          requests = hotelDetailResponse.requests ?? [];

          if(hotelInfo.meal!=null) {
            getInitialMeals();
          }

          setState(() {

          });

          setImage();
          getHotelSlots();
        }
    );
  }

  initValues(){
    if(dt.hour>21)
    {
      timing = 0;
    }
    else
    {
      timing = dt.hour - (dt.hour % slot) + slot;
    }
    changeCheckin();
  }

  getInitialMeals()
  {
    if(hotelInfo.meal?.hmB=='COMPLIMENTARY' && slot==24) {
      breakfast = adult;
    }
    if(hotelInfo.meal?.hmL=='COMPLIMENTARY' && slot==24) {
      lunch = adult;
    }
    if(hotelInfo.meal?.hmD=='COMPLIMENTARY' && slot==24) {
      dinner = adult;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HOTELDETAILS"),
        backgroundColor: MyColors.white,
        bottomNavigationBar: load ? Visibility(
          visible: show_pay,
          child: Container(
            padding: EdgeInsets.all(10),
            height: 110,
            decoration: BoxDecoration(
              color: MyColors.white,
              border: Border(top: BorderSide(color: MyColors.grey10))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: timing > -1 ?
                        RichText(
                          text: TextSpan(
                            text: APIConstant.symbol+getTotalPrice().toString()+"  ",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: MyColors.black,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 20
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: APIConstant.symbol+getBasePrice().toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.lineThrough,
                                      color: MyColors.grey,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14
                                  )
                              ),
                              TextSpan(text: "\nTotal amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: MyColors.grey.withOpacity(0.5),
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12
                                  )
                              ),
                            ],
                          ),
                        ) :
                        Text(
                          "Select Date & Time",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: MyColors.black,
                            fontSize: 12
                          ),
                        ),
                      ),
                      flex: 2,
                      fit: FlexFit.tight,
                    ),
                    Flexible(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(sharedPreferences?.getString("login_type")=="customer") {
                              if (timing > -1) {
                                bookNow();
                              }
                            }
                            else {
                              loginPopUp();
                            }
                          },
                          child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: timing > -1 ? MyColors.green500 : MyColors.grey10,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Book Now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: MyColors.white,
                                      fontSize: 16
                                  ),
                                ),
                              ),
                          ),
                        ),
                      ),
                      flex: 3,
                      fit: FlexFit.tight,
                    )
                  ],
                ),
                SizedBox(height: 20,),
                RichText(
                  text: TextSpan(
                    text: "By proceeding , you agree to our ",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: MyColors.black,
                        fontSize: MySize.font10(context)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Guest Policies",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: MyColors.orange
                        ),
                        recognizer: TapGestureRecognizer()..onTap = guestPolicy
                      ),
                      TextSpan(
                        text: " and "
                      ),
                      TextSpan(
                        text: "Cancellation Policies",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: MyColors.orange
                        ),
                        recognizer: TapGestureRecognizer()..onTap = cancellationPolicy
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) : Center(
            child: CircularProgressIndicator(
              color: MyColors.colorPrimary,
            )
        ),
        body: load ? Column(
          children: [
            MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey,),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: MyColors.white,
                        child: Column(
                          children: [
                            getImageView(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                                    children: [
                                      Text(
                                        hotelInfo.hotel?.hName??"",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: MySize.font14(context)
                                        ),
                                      ),
                                      IgnorePointer(
                                        ignoring: r_enabled,
                                        child: IconButton(
                                            onPressed: () {
                                              if(sharedPreferences?.getString("login_type")=="customer") {
                                                r_enabled = !r_enabled;
                                                setState(() {

                                                });

                                                if (hotelInfo.hotel?.liked != "0") {
                                                  manageWishlist(
                                                      APIConstant.del, hotelInfo, -1);
                                                } else {
                                                  manageWishlist(
                                                      APIConstant.add, hotelInfo, -1);
                                                }
                                              }
                                              else {
                                                loginPopUp();
                                              }
                                            },
                                            padding: EdgeInsets.all(0),
                                            alignment: Alignment.centerRight,
                                            icon: Icon(
                                              hotelInfo.hotel?.liked!="0"
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color:
                                              hotelInfo.hotel?.liked!="0" ? MyColors.colorPrimary : MyColors.grey30,
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                  RatingBar.builder(
                                    initialRating: double.parse(hotelInfo.hotel?.hStar??"0"),
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    itemSize: MySize.sizeh3(context),
                                    unratedColor: MyColors.grey10,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: MyColors.yellow800,
                                    ),
                                    onRatingUpdate: (double value) {
                                    },
                                  ),
                                  SizedBox(
                                    height: MySize.sizeh1(context),
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          hotelInfo.hotel?.hAddress??"",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: MyColors.grey60,
                                              fontSize: MySize.font12(context)
                                          ),
                                        ),
                                        flex: 3,
                                        fit: FlexFit.tight,
                                      ),
                                      Flexible(
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () async {
                                              Essential().map(
                                                  double.parse(
                                                      hotelInfo.hotel?.hgLat ??
                                                          "0"),
                                                  double.parse(
                                                      hotelInfo.hotel?.hgLong ??
                                                          "0"),
                                                  hotelInfo.hotel?.hName ?? ""
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Icon(Icons.location_on_outlined,
                                                  color: MyColors.grey60,),
                                                Text("Map",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      color: MyColors.grey60,
                                                      fontSize: MySize.font12(context)
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        flex: 1,
                                        fit: FlexFit.tight,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MySize.sizeh1(context),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) =>
                                                AllReviewsM(
                                                  h_id: h_id,
                                                  h_rating: hotelInfo.hotel?.hRating??"0"
                                                )));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: MySize.sizeh1_5(context), horizontal: MySize.size2(context)),
                                            decoration: BoxDecoration(
                                                color: double.parse(hotelInfo.hotel?.hRating??"0").round()<=2 ? MyColors.red : double.parse(hotelInfo.hotel?.hRating??"0").round()<=3 ? MyColors.yellow800 : MyColors.green500,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(MySize.sizeh065(context)))
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  double.parse(hotelInfo.hotel?.hRating??"0").toStringAsFixed(1),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: MyColors.white,
                                                      fontSize: MySize.font12(context)
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MySize.size1(context),
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: MyColors.white,
                                                  size: MySize.font12(context),
                                                ),
                                                Text(
                                                  " | "+(hotelInfo.hotel?.hTotalRating??""),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      color: MyColors.white,
                                                      fontSize: MySize.font12(context)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: IgnorePointer(
                                              ignoring: generate,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    generate = true;
                                                  });
                                                  // String link = await OLRLinks().createDynamicLink(true, kHotelDetailLink+widget.h_id);
                                                  // Share.share(link, subject: 'Hey, look at the hotel I have visited!').then((value) {
                                                  //   setState(() {
                                                  //     generate = false;
                                                  //   });
                                                  // });

                                                },
                                                child: Icon(
                                                  Icons.share,
                                                  color: MyColors.green500,
                                                  size: MySize.sizeh5(context),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MySize.size3(context),
                                          ),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                Essential().call("tel://"+(hotelInfo.hotel?.hgHelplineCustomer??""));
                                              },
                                              child: Icon(
                                                Icons.call,
                                                color: MyColors.green500,
                                                size: MySize.sizeh5(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      getDetailsDesign(),
                      getOffersDesign(),
                      getTravelDetailsDesign(),
                      getAmenitiesDesign(),
                      getNearbyPlacesDesign(),
                      getRoomCategoriesDesign(),
                      getRatingsDesign(),
                      if(ratings.length>0)
                        getCustomerRatingsDesign(0),
                      if(hotelInfo.meal!=null)
                        getMealsDesign(),
                      if(timing > -1)
                        getPricingDetailsDesign(),
                      getSimilarHotelsDesign(),
                      getRulesDesign(),
                      Footer()
                    ],
                  ),
              ),
            ),
          ],
        ) :
        Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,)),
      ),
    );
  }

  getDetailsDesign(){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font13_5(context),
            ),
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getDescriptionText(),
          if(isReadmore)
            getOtherDetails(),
          SizedBox(
            height: MySize.sizeh2(context),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    // toggle the bool variable true or false
                    isReadmore = !isReadmore;
                  });
                },
                child: Text(
                  (isReadmore ? 'Read Less' : 'Read More'),
                  style: TextStyle(
                      color: MyColors.colorPrimary
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

  getDescriptionText() {
    String desc = hotelInfo.hotel?.hgShortDesc??"";
    return Text(
      desc,
      style: TextStyle(
        fontSize: MySize.font12(context),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
      ),
      maxLines: 3,
      overflow: isReadmore ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  getOtherDetails() {
    return Html(
      data: unescape.convert(utf8.decode(base64Decode(hotelInfo.hotel?.hgLongDesc??""))),
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: const [
    //     Text(
    //       "Location",
    //       style: TextStyle(
    //         fontSize: 15,
    //         fontStyle: FontStyle.italic,
    //       ),
    //     ),
    //     Text(
    //       "The place is located behind Vinayak Hospital, Street No 5, CH. Rati Ram Place, Noida, Uttar Pradesh.\n\n",
    //       style: TextStyle(
    //         fontSize: 15,
    //         fontStyle: FontStyle.italic,
    //         fontWeight: FontWeight.w300,
    //       ),
    //     ),
    //     Text(
    //       "Amenities",
    //       style: TextStyle(
    //           fontSize: 15,
    //           fontStyle: FontStyle.italic
    //       ),
    //     ),
    //     Text(
    //       "The rooms have single beds with bathrooms, Tv and AC. The additional facilities provided by this place are card "
    //           "payment, daily housekeeping, 24X7 check-in, free wifi, CCTV cameras and reception.\n\n",
    //       style: TextStyle(
    //         fontSize: 15,
    //         fontStyle: FontStyle.italic,
    //         fontWeight: FontWeight.w300,
    //       ),
    //     ),
    //     Text(
    //       "What's Nearby",
    //       style: TextStyle(
    //           fontSize: 15,
    //           fontStyle: FontStyle.italic
    //       ),
    //     ),
    //     Text(
    //       "There are some food joints near to this place where one can enjoy food which is delicious and sumptuous. One "
    //           "should try these food joints for a variety of food dishes that are available over here. Expand your taste "
    //           "buds by trying out new flavours.\n\n",
    //       style: TextStyle(
    //         fontSize: 15,
    //         fontStyle: FontStyle.italic,
    //         fontWeight: FontWeight.w300,
    //       ),
    //     ),
    //   ],
    // );
  }

  getOffersDesign(){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Best offers for you",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: MySize.font13_5(context)
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        AllOffers(offer: offer, h_id: h_id))).then((value) {
                          offer = value;
                          setState(() {

                          });
                    });
                  },
                  child: Text(
                    "All offers("+offers.length.toString()+")",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: MyColors.colorPrimary,
                        fontSize: MySize.font12_25(context)
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getOffers(),
        ],
      ),
    );
  }

  getOffers(){
    return Container(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length>5 ? 5 : offers.length,
        separatorBuilder: (BuildContext context, index){
          return SizedBox(width: 10);
        },
        itemBuilder: (BuildContext context, index){
          return getOfferCard(index);
        },
      ),
    );
  }

  getOfferCard(int ind){
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          offer = ind;
          setState(() {

          });
        },
        child: Container(
          width: 250,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          offers[ind].offer?.name??"",
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13
                          ),
                        ),
                      ),
                      fit: FlexFit.tight,
                      flex: 8,
                    ),
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: offer==ind ?
                        Image.asset(
                          "assets/offers/applied.png"
                        ) :
                        Image.network(Environment.imageUrl + (offers[ind].offer?.image??"")),
                      ),
                      fit: FlexFit.tight,
                      flex: 2,
                    ),
                  ],
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Text(
                  offers[ind].offer?.short??"",
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12
                  ),
                ),
                // child: Html(
                //   data: unescape.convert(offers[ind].offer?.description??""),
                // ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 3, 15, 3),
                      margin: EdgeInsets.fromLTRB(3, 6, 3, 3),
                      alignment: Alignment.center,
                      child: Text(
                        offers[ind].offer?.code??"",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(3))
                      ),
                    ),
                  ],
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getTravelDetailsDesign(){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Time and Date of travel & guests",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font13(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getSlotsDesign(),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getDates(),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getGuests(),
        ],
      ),
    );
  }

  getSlotsDesign(){
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
          border: Border.all(color: MyColors.grey.withOpacity(0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
            child: Text(
              "Slots",
              style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font11_5(context),
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: MySize.sizeh03(context),
            mainAxisSpacing: MySize.sizeh1(context),
            crossAxisSpacing: MySize.size05(context),
            shrinkWrap: true,
            children: List.generate(slots.length, (index) {
              return getSlotDesign(index);
            }),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
            child: Text(
              "Timings",
              style: TextStyle(
                  color: MyColors.black,
                  fontSize: MySize.font11_5(context),
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: MySize.sizeh03(context),
            mainAxisSpacing: MySize.sizeh1(context),
            crossAxisSpacing: MySize.size05(context),
            shrinkWrap: true,
            children: List.generate(timings.length, (index) {
              return getTimingDesign(index);
            }),
          ),
        ],
      )
    );
  }

  getSlotDesign(int ind){
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          slot = slots[ind];
          setState(() {

          });
          await getCategories();
          changeTimings(slots[ind]);
        },
        child: slot==slots[ind] ?
        Container(
          height: 20,
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MyColors.colorPrimary,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            slots[ind].toString()+"hrs",
            style: TextStyle(
              color: MyColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12
            ),
          ),
        )
        : Container(
            height: 20,
            margin: EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Text(
            slots[ind].toString()+"hrs",
            style: TextStyle(
                color: MyColors.black,
                fontWeight: FontWeight.w500,
                fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  getTimingDesign(int ind){
    int end = int.parse((timings[ind].end??"").substring((timings[ind].end??"").indexOf(" ")+1, (timings[ind].end??"").indexOf(":")));
    if(ind==timings.length-1)
      end = 24;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          if(int.parse(timings[ind].available??"0")>0) {
            if (dt.year == ds.year && dt.month == ds.month && dt.day == ds.day) {
              // if (timings[ind].time! <= dt.hour) {
              if (end <= dt.hour) {

              }
              else {
                timing = timings[ind].time!;
              }
            }
            else {
              timing = timings[ind].time!;
            }

            setState(() {

            });
            changeCheckin();
          }
        },
        child: timing==timings[ind].time! ?
        Container(
          height: 20,
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (dt.year==ds.year && dt.month==ds.month && dt.day==ds.day) ?
            end<=dt.hour?
            // timings[ind].time!<=dt.hour ?
              MyColors.grey10 :
              int.parse(timings[ind].available??"0")<=0 ?
              MyColors.yellow800 :
                MyColors.colorPrimary : MyColors.colorPrimary,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            (timings[ind].time! == 0 ? 12 : timings[ind].time!>12 ? timings[ind].time! - 12 : timings[ind].time!).toString()+ (timings[ind].time!>=12 ? " PM" : " AM"),
            style: TextStyle(
              color: dt.year==ds.year && dt.month==ds.month && dt.day==ds.day ?
                end<=dt.hour || end==0?
                // timings[ind].time!<=dt.hour ?
                  MyColors.grey10 :
                  int.parse(timings[ind].available??"0")<=0 ?
                    MyColors.yellow800 :
                  MyColors.white :
                int.parse(timings[ind].available??"0")<=0 ?
                  MyColors.yellow800 :
                  MyColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        )
        : Container(
            height: 20,
            margin: EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: dt.year==ds.year && dt.month==ds.month && dt.day==ds.day ?
                  end<=dt.hour || end==0?
                  // timings[ind].time!<=dt.hour ?
                    MyColors.grey10 :
                    int.parse(timings[ind].available??"0")<=0 ?
                      MyColors.yellow800 :
                    MyColors.white :
                  int.parse(timings[ind].available??"0")<=0 ?
                    MyColors.yellow800 :
                    MyColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Text(
              (timings[ind].time! == 0 ? 12 : timings[ind].time!>12 ? timings[ind].time! - 12 : timings[ind].time!).toString()+ (timings[ind].time!>=12 ? " PM" : " AM"),
            style: TextStyle(
                color: MyColors.black,
                fontWeight: FontWeight.w500,
                fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  getDates(){
    print(de);
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: MySize.size3(context), vertical: MySize.sizeh3(context)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ds.day-dt.day==0 ?
                        "Today" :
                        ds.day-dt.day==1 ?
                        "Tomorrow" :
                        Strings.weekday[ds.weekday-1]+", "+ds.day.toString()+" "+Strings.month[ds.month-1],
                        style: TextStyle(
                            color: MyColors.black,
                            fontSize: MySize.font11_5(context),
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: MySize.sizeh1(context),),
                      Text(
                        "Checkin: "+ (timing > -1 ?
                        (timing==0 ? 12 : timing>12 ? timing - 12 : timing).toString()+ (timing>=12 ? ":00 PM" : ":00 AM") :
                        "Not Selected"),
                        style: TextStyle(
                            color: MyColors.black,
                            fontSize: MySize.font11_5(context),
                            fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        showDatePicker(
                            context: context,
                            initialDate: DateTime(ds.year, ds.month, ds.day),
                            firstDate: DateTime(dt.year, dt.month, dt.day),
                            lastDate: DateTime(dt.year, dt.month+6, dt.day).subtract(Duration(days: 1))
                        ).then((value) {
                          if(value!=null) {
                            ds = DateTime(value.year, value.month, value.day);
                            setState(() {});
                            changeTimings(slot);
                          }
                        });
                        // Navigator.push(
                        //     context, MaterialPageRoute(builder: (context) =>
                        //     BookingDetails(ds: ds, de: de, room: room, guest: guest, adult: adult, child: child, tab_index: 0)));
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(
                            color: MyColors.colorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: MySize.sizeh4(context),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        de.day-dt.day==0 ?
                        "Today" :
                        de.day-dt.day==1 ?
                        "Tomorrow" :
                        Strings.weekday[de.weekday-1]+", "+de.day.toString()+" "+Strings.month[de.month-1],
                        style: TextStyle(
                            color: MyColors.black,
                            fontSize: MySize.font11_5(context),
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: MySize.sizeh1(context),),
                      Text(
                        // "Checkout: "+(timing+slot==0 ? 12 : timing+slot>12 ? timing+slot - 12 : timing+slot).toString()+ (timing+slot>=12 && timing+slot!=24? ":00 PM" : ":00 AM"),
                        "Checkout: "+ (timing > -1 ?
                        (de.hour==0 ? 12 : de.hour>12 ? de.hour - 12 : de.hour).toString()+ (de.hour>=12 && de.hour!=24? ":00 PM" : ":00 AM") :
                        "Not Selected"),
                        style: TextStyle(
                            color: MyColors.black,
                            fontSize: MySize.font11_5(context),
                            fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        if(slot==24 && timing!=-1) {
                          showDatePicker(
                              context: context,
                              initialDate: DateTime(de.year, de.month, de.day),
                              firstDate: DateTime(ds.year, ds.month, ds.day + 1),
                              lastDate: DateTime(ds.year, ds.month + 2, ds.day)
                                  .subtract(Duration(days: 1)),

                          ).then((value) async {
                            if (value != null) {
                              de = DateTime(value.year, value.month, value.day, 11);
                              if(await checkAvailability()) {
                                setState(() {});
                              }
                            }
                          });
                        }
                        // Navigator.push(
                        //     context, MaterialPageRoute(builder: (context) =>
                        //     BookingDetails(ds: ds, de: de, room: room, guest: guest, adult: adult, child: child, tab_index: 1)));
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(
                            color: slot==24 && timing!=-1 ? MyColors.colorPrimary : MyColors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
    );
  }

  getGuests(){
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: MySize.size3(context), vertical: MySize.sizeh3(context)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rooms.length.toString()+" Room"+(rooms.length>1 ? "s" : ""),
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: MySize.font11_5(context),
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: MySize.sizeh2(context),),
                  Text(
                    guest.toString()+" Guest"+(guest>1 ? "s" : ""),
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: MySize.font11_5(context),
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  SizedBox(height: MySize.sizeh03(context),),
                  Text(
                    "("+adult.toString()+(adult>1 ? " Adults" : " Adult")+(child>0 ? ", "+child.toString()+(child>1 ? " Children" : " Child") : "")+")",
                    style: TextStyle(
                        color: MyColors.black,
                        fontSize: MySize.font11_5(context),
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    int available = 0;
                    for(int i=0; i<timings.length;i++)
                      {
                        if(timings[i].time==timing) {
                          available = int.parse(timings[i].available ?? "0");
                          break;
                        }
                      }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return BookingDetails(guest: guest, adult: adult, child: child,  max_adult: int.parse(categories[category].category?.catAdult??"0"),
                            max_child: int.parse(categories[category].category?.catChild??"0"), limit: int.parse(categories[category].category?.catPeople??"0"),
                            available: available, rooms: rooms
                        );
                      },
                    ).then((value) {
                      if(value!=null) {
                        guest = value['guest'];
                        adult = value['adult'];
                        child = value['child'];
                        rooms = value['rooms'];
                        setState(() {});
                        updateMeals();
                      }
                    });
                  },
                  child: Text(
                    "Edit",
                    style: TextStyle(
                        color: MyColors.colorPrimary,
                        fontSize: MySize.font11_5(context),
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              )
            ],
          ),
    );
  }

  Future<void> changeTimings(int slot) async {
    // timings = [];
    // if(slot!=24) {
    //   for (int i = 0; i < 24; i += slot) {
    //     timings.add(i);
    //   }
    // }
    // else
    // {
    //   timings.add(12);
    // }
    await manageHotelTimings();

    changeTiming();
  }

  void changeTiming() {
    bool similar = true;

    if(dt.year==ds.year && dt.month==ds.month && dt.day==ds.day) {
      ds = dt;
      similar = true;
    }
    else {
      ds = DateTime(ds.year, ds.month, ds.day);
      similar = false;
    }

    // if (slot != 24) {
    //   if (ds.hour > 21) {
    //   }
    //   else {
    //     if(!(similar && timings.last.time!<=dt.hour)) {
    //       if (!similar && ds.hour == 0) {
    //         timing = 0;
    //       }
    //       else {
    //         timing = ds.hour - (ds.hour % slot) + slot;
    //       }
    //     }
    //     else {
    //       timing = -1;
    //     }
    //   }
    // }
    // else {
    //   if (ds.hour >= 12) {
    //     if(!(similar && timings.last.time!<=dt.hour)) {
    //       if (!similar && ds.hour == 0) {
    //         timing = 12;
    //       } else {
    //         timing = ds.hour - (ds.hour % slot) + slot;
    //       }
    //     }
    //     else {
    //       timing = -1;
    //     }
    //   }
    //   else {
    //     timing = 12;
    //   }
    // }
    timing = -1;
    for(int i = 0; i<timings.length; i++) {
        if(similar) {
          if(timings[i].time!>ds.hour && int.parse(timings[i].available??"0")>0) {
            timing = timings[i].time ?? -1;
            break;
          }
        }
        else
        {
          if(int.parse(timings[i].available??"0")>0) {
            timing = timings[i].time ?? -1;
            break;
          }
        }
    }

    setState(() {

    });
    changeCheckin();
  }

  void changeCheckin() {
    if(dt.year==ds.year && dt.month==ds.month && dt.day==ds.day) {
      ds = dt;
    }
    else {
      ds = DateTime(ds.year, ds.month, ds.day);
    }
    if(slot!=24) {
      if (ds.hour > 21) {
        ds = ds.add(Duration(days: 1));
      }
      else {
        ds = DateTime(ds.year, ds.month, ds.day, timing==-1 ? 0 : timing);
      }
    }
    else
    {
      if (ds.hour > 21) {
        ds = ds.add(Duration(days: 1));
      }
      else {
        ds = DateTime(ds.year, ds.month, ds.day, timing==-1 ? 0 : timing);
      }
    }
    setState(() {
    });
    changeCheckout();
  }
  void changeCheckout() {
    de = ds;
    de = de.add(Duration(hours: slot==24 ? slot-1 : slot));
    setState(() {

    });
    load = true;
  }

  void updateMeals() {
    if(breakfast>0) {
      breakfast = adult;
    }
    if(lunch>0) {
      lunch = adult;
    }
    if(dinner>0) {
      dinner = adult;
    }
    setState(() {

    });
  }


  getAmenitiesDesign(){
    return Container(
      color: MyColors.white,padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amenities",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font13(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          getAmenities(),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    AllAmenities(h_id: h_id, cat_id: categories[category].category?.catId??"", desc: categories[category].category?.catDesc??"",)));
              },
              child: Text(
                "View all amenities",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: MyColors.colorPrimary,
                    fontSize: MySize.font11_5(context)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getAmenities() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 15/3,
      shrinkWrap: true,
      children: List.generate((categories[category].categoryAmenities?.length??0) > 5 ? 5 : categories[category].categoryAmenities?.length??0 , (index) {
        return getAmenitiesCard(index);
      }),
    );
  }

  getAmenitiesCard(int ind) {
    return Row(
      children: [
        // Icon(
        //   amenities[ind]['icon'],
        //   color: MyColors.grey30,
        //   size: 18,
        // ),
        Image.network(
          Environment.imageUrl + (categories[category].categoryAmenities?[ind].amImage??""),
          color: MyColors.grey30,
          height: 24,
          width: 24,
          errorBuilder: (BuildContext context, obj, stack){
            return Icon(
              Icons.check_circle,
              color: MyColors.grey30,
              size: 22,
            );
          }),
        SizedBox(width: MySize.size2(context),),
        Text(
          categories[category].categoryAmenities?[ind].amName??"",
          style: TextStyle(
            color: MyColors.grey30,
          ),
        )
      ],
    );
  }

  getNearbyPlacesDesign(){
    return Container(
      color: MyColors.white,padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Nearby",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font14(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh4(context),
          ),
          getPlaces(),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    NearbyPlaces(h_id: h_id,)));
              },
              child: Text(
                "View all places",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: MyColors.colorPrimary,
                    fontSize: MySize.font11_5(context)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getPlaces() {
    return ListView.separated(
      itemCount: places.length>4 ? 4 : places.length,
      separatorBuilder: (BuildContext context, index) {
        return SizedBox(height: MySize.sizeh1(context),);
      },
      shrinkWrap: true,
      itemBuilder: (BuildContext context, index) {
        return getPlacesCard(index);
      }
    );
  }

  getPlacesCard(int ind) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.near_me_outlined,
              color: MyColors.black,
              size: 18,
            ),
            SizedBox(width: 10,),
            Text(
              places[ind].hnPlace??"",
              style: TextStyle(
                color: MyColors.black,
              ),
            )
          ],
        ),
        Text(
          places[ind].hnDistance??"",
          style: TextStyle(
            color: MyColors.grey30,
          ),
        )
      ],
    );
  }

  getRoomCategoriesDesign(){
    return Container(
      color: MyColors.white,padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose your sanitised room",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font14(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getRooms(),
        ],
      ),
    );
  }

  getRooms() {
    return categories.length > 1 ?
    Container(
      height: 290,
      child: ListView.separated(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(width: MySize.sizeh1(context),);
        },
        shrinkWrap: true,
        itemBuilder: (BuildContext context, index) {
          return getRoomsCard(index);
        }
      ),
    ) :
    categories.length==0 ? getRoomCard(0) : Container();
  }

  getRoomCard(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => HotelDetailsM(h_id: "")));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 160,
          margin: EdgeInsets.only(bottom: 10, left: 1),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            // border: Border.all(color: MyColors.grey10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                    child: Image.network(
                      categories[ind].image?.hiImage??"",
                      fit: BoxFit.fill,
                      // height: 120,
                      width: 150,
                      errorBuilder: (BuildContext context, obj, stack){
                        return Icon(
                          Icons.broken_image_outlined,
                          color: MyColors.grey30,
                          size: 150,
                        );
                      }
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: MyColors.grey10)
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, size: 18, color: MyColors.grey10,),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: AlignmentDirectional.topStart,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categories[ind].category?.catName??"",
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                                color: MyColors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Image.network(
                                  Environment.imageUrl + (categories[ind].categoryAmenities?[0].amImage??""),
                                  height: 25,
                                  width: 25,
                                  errorBuilder: (BuildContext context, obj, stack){
                                    return Icon(
                                      Icons.check_circle,
                                      color: MyColors.grey30,
                                      size: 18,
                                    );
                                  }
                                ),
                                SizedBox(width: 5,),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      print(categories[ind].category?.catId??"");
                                      print(categories[ind].category?.catDesc??"");
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) =>
                                          AllAmenities(
                                            h_id: h_id, cat_id: categories[ind].category?.catId??"",
                                            desc: categories[ind].category?.catDesc??"",
                                          )));
                                    },
                                    child: Container(
                                      height: 20,
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(3)),
                                        border: Border.all(color: MyColors.grey1)
                                      ),
                                      child: Text(
                                        "+"+(int.parse(categories[ind].total??"0")-1).toString()
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
                        alignment: AlignmentDirectional.topStart,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: APIConstant.symbol+getNewRoomPrice(category).toString()+"  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: MyColors.black,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: APIConstant.symbol+int.parse(categories[category].category?.cpBase ?? "0").toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          decoration: TextDecoration.lineThrough,
                                          color: MyColors.black,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 12
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(3)),
                                    border: Border.all(color: MyColors.grey10)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      "Selected",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Icon(Icons.check_circle, color: MyColors.green500, size: 16,)
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getRoomsCard(int ind) {
    int amen = categories[ind].categoryAmenities?.length ?? 0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HotelImages(h_id: "", cat_id: categories[ind].category?.catId??"", act: APIConstant.getByCategory)));
        },
        child: Container(
          width: 175,
          height: 290,
          margin: EdgeInsets.only(bottom: 10, left: 1),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            // border: Border.all(color: MyColors.grey10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                    child: Image.network(
                      Environment.imageUrl + (categories[ind].image?.hiImage??""),
                      fit: BoxFit.fill,
                      height: 120,
                      width: 200,
                      errorBuilder: (BuildContext context, obj, stack){
                        return Icon(
                          Icons.broken_image_outlined,
                          color: MyColors.grey30,
                          size: 18,
                        );
                      }
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: MyColors.grey10)
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined, size: 18, color: MyColors.grey10,),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categories[ind].category?.catName??"",
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                        color: MyColors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if(amen > 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(amen>1)
                            Image.network(
                              Environment.imageUrl + (categories[ind].categoryAmenities?[0].amImage??""),
                              height: 25,
                              width: 25,
                              errorBuilder: (BuildContext context, obj, stack){
                                return Icon(
                                  Icons.check_circle,
                                  color: MyColors.grey30,
                                  size: 18,
                                );
                              }
                            ),
                          if(amen>2)
                            SizedBox(width: 5,),
                          if(amen>2)
                            Image.network(
                              Environment.imageUrl + (categories[ind].categoryAmenities?[1].amImage??""),
                              height: 25,
                              width: 25,
                              errorBuilder: (BuildContext context, obj, stack){
                                return Icon(
                                  Icons.check_circle,
                                  color: MyColors.grey30,
                                  size: 18
                                );
                              }
                            ),
                          if(amen>3)
                            SizedBox(width: 5,),
                          if(amen>3)
                            Image.network(
                              Environment.imageUrl + (categories[ind].categoryAmenities?[2].amImage??""),
                              height: 25,
                              width: 25,
                              errorBuilder: (BuildContext context, obj, stack){
                                return Icon(
                                  Icons.check_circle,
                                  color: MyColors.grey30,
                                  size: 18,
                                );
                              }
                            ),
                          if(amen>4)
                          SizedBox(width: 5,),
                          if(amen>4)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) =>
                                    AllAmenities(h_id: h_id, cat_id: categories[ind].category?.catId??"",
                                      desc: categories[ind].category?.catDesc??"",)));
                              },
                              child: Container(
                                height: 25,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                  border: Border.all(color: MyColors.grey1)
                                ),
                                child: Text(
                                  "+"+(int.parse(categories[ind].total??"0")-1).toString(),
                                  style: TextStyle(
                                    fontSize: 10
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: APIConstant.symbol+getNewRoomPrice(ind).toString()+"  ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: MyColors.black,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 14
                        ),
                        children: <TextSpan>[
                          TextSpan(text: APIConstant.symbol+int.parse(categories[ind].category?.cpBase ?? "0").toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.lineThrough,
                                  color: MyColors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // if(!categories[ind]['sold']) {
                            category = ind;
                            setState(() {

                            });
                            manageHotelTimings();
                          // }
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            // color: categories[ind]['sold'] ? MyColors.grey1 : MyColors.white,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            border: Border.all(color: MyColors.grey10)
                          ),
                          child: category==ind ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Selected",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 5,),
                              Icon(Icons.check_circle, color: MyColors.green500, size: 16,)
                            ],
                          ) :
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // categories[ind]['sold'] ?
                              false ?
                              Text(
                                "Sold out",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.grey30
                                ),
                              ) :
                              Text(
                                "Select",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.grey
                                ),
                              ),
                            ],
                          ),
                        ),
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

  getRatingsDesign(){
    return Container(
      color: MyColors.white,padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: ratings.length>0 ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    "Ratings & Reviews",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: MySize.font14(context)
                    ),
                  ),
                  Image.asset(
                    "assets/certificate/iso-certified.png",
                    height: 60,
                    width: 60,
                  )
                ],
              ),
              Container(
                height: MySize.sizeh10(context),
                width: MySize.size22(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MySize.sizeh055(context)),
                  border: Border.all(color: MyColors.grey10)
                ),
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                // double.parse(hotelInfo.hotel?.hRating??"0").toStringAsFixed(1),
                                double.parse(hotelInfo.hotel?.hRating??"0").toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: MySize.font15(context),
                                  color: MyColors.grey60
                                ),
                              ),
                              flex: 1,
                              fit: FlexFit.tight,
                            ),
                            Flexible(
                              child: Text(
                                (hotelInfo.hotel?.hTotalRating??"0")+" ratings",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: MySize.font11_5(context),
                                  color: MyColors.grey60
                                ),
                              ),
                              flex: 1,
                              fit: FlexFit.tight,
                            )
                          ],
                        ),
                      ),
                      flex: 5,
                      fit: FlexFit.tight,
                    ),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: double.parse(hotelInfo.hotel?.hRating??"0").round()<=2 ? MyColors.red.withOpacity(0.3) : double.parse(hotelInfo.hotel?.hRating??"0").round()<=3 ? MyColors.yellow800.withOpacity(0.3) : MyColors.green500.withOpacity(0.3),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(MySize.size055(context)), bottomRight: Radius.circular(MySize.size055(context)))
                        ),
                        child: Text(
                          ratings.length>0 ? Strings.ratings[double.parse(hotelInfo.hotel?.hRating??"0").round()==0 ? 0 : double.parse(hotelInfo.hotel?.hRating??"0").round()-1] : "0",
                          style: TextStyle(
                              color: double.parse(hotelInfo.hotel?.hRating??"0").round()<=2 ? MyColors.red : double.parse(hotelInfo.hotel?.hRating??"0").round()<=3 ? MyColors.yellow800 : MyColors.green500,
                              fontSize: MySize.font11_5(context),
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      flex: 2,
                      fit: FlexFit.tight,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: MySize.sizeh7(context),
          ),
          getRatings(),
        ],
      ) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ratings & Reviews",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16
            ),
          ),
          Container(
            height: MySize.size50(context),
            alignment: Alignment.center,
            child: Text(
              "No Ratings Given",
              style: TextStyle(
                fontSize: MySize.font16(context)
              ),
            ),
          ),
        ],
      ),
    );
  }

  getRatings() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 11/3,
      shrinkWrap: true,
      crossAxisSpacing: 35.0,
      children: [
        getRatingCard("Location", getLocationRating()),
        getRatingCard("Cleanliness", getCleanlinessRating()),
        getRatingCard("Food", getFoodRating()),
        getRatingCard("Hotel Staff", getStaffRating()),
        getRatingCard("Facilities", getFacilitiesRating())
      ]
    );
  }

  getRatingCard(String type, double rating) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  color: MyColors.grey60,
                  fontWeight: FontWeight.w300
                ),
              ),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  color: MyColors.grey60,
                  fontWeight: FontWeight.w500,
                  fontSize: 12
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: rating/5,
              semanticsLabel: 'Linear progress indicator',
              color: rating.round()<=2 ? MyColors.red : rating.round()<=3 ? MyColors.yellow800 : MyColors.green500,
              backgroundColor: rating.round()<=2 ? MyColors.red.withOpacity(0.3) : rating.round()<=3 ? MyColors.yellow800.withOpacity(0.3) : MyColors.green500.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  double getLocationRating() {
    double rating = 0.0;
    for(int i = 0; i < ratings.length; i++) {
      rating += double.parse(ratings[i].brLocation??"0");
    }
    return ratings.length>0 ? (rating/ratings.length) : 0;
  }

  double getFoodRating() {
    double rating = 0.0;
    for(int i = 0; i < ratings.length; i++) {
      rating += double.parse(ratings[i].brFood??"0");
    }
    return ratings.length>0 ? (rating/ratings.length) : 0;
  }

  double getCleanlinessRating() {
    double rating = 0.0;
    for(int i = 0; i < ratings.length; i++) {
      rating += double.parse(ratings[i].brCleanliness??"0");
    }
    return ratings.length>0 ? (rating/ratings.length) : 0;
  }

  double getStaffRating() {
    double rating = 0.0;
    for(int i = 0; i < ratings.length; i++) {
      rating += double.parse(ratings[i].brStaff??"0");
    }
    return ratings.length>0 ? (rating/ratings.length) : 0;
  }

  double getFacilitiesRating() {
    double rating = 0.0;
    for(int i = 0; i < ratings.length; i++) {
      rating += double.parse(ratings[i].brFacilities??"0");
    }
    return ratings.length>0 ? (rating/ratings.length) : 0;
  }

  // double getTotalAverageRating() {
  //   double rating = 0.0;
  //   rating += (getLocationRating() + getFoodRating() + getCleanlinessRating() + getStaffRating() + getFacilitiesRating())/5.0;
  //   return ratings.length>0 ? (rating/ratings.length) : 0;
  // }

  getCustomerRatingsDesign(int ind){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ratings[ind].cusName??"",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font13(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating: getUserRating(ind),
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                ignoreGestures: true,
                itemSize: MySize.sizeh3_5(context),
                unratedColor: MyColors.grey10,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: getUserRating(ind).roundToDouble()<=2 ? MyColors.red : getUserRating(ind).roundToDouble()<=3 ? MyColors.yellow800 : MyColors.green500,
                ),
                onRatingUpdate: (double value) {
                },
              ),
              SizedBox(width: MySize.size2(context),),
              Text(
                ratings[ind].brDate?.substring(0, 10)??"",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MySize.font11(context),
                    color: MyColors.grey30.withOpacity(0.5)
                ),
              ),
            ],
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          Text(
            ratings[ind].brReview??"",
            style: TextStyle(
                fontSize: MySize.font11_5(context),
                color: MyColors.black
            ),
          ),
          SizedBox(
            height: MySize.sizeh5(context),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    AllReviewsM(h_id: h_id, h_rating: hotelInfo.hotel?.hRating??"0",)));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: MySize.sizeh1_5(context), horizontal: MySize.sizeh1(context)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh055(context))),
                    border: Border.all(color: MyColors.blue, width: 1)
                ),
                child: Text(
                  "See all "+ratings.length.toString()+" reviews",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: MyColors.blue
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  double getUserRating(int ind) {
    double rating = 0.0;
    rating = double.parse((double.parse(ratings[ind].brLocation??"0") + double.parse(ratings[ind].brFood??"0") + double.parse(ratings[ind].brCleanliness??"0") + double.parse(ratings[ind].brStaff??"0") + double.parse(ratings[ind].brFacilities??"0")).toString());
    return (rating/5);
  }

  getMealsDesign(){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),

      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enjoy meals during your stay",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font14(context)
            ),
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(hotelInfo.meal?.hmB!='UNAVAILABLE')
                Container(
                  width: MediaQuery.of(context).size.width*0.3,
                  decoration: BoxDecoration(
                    color: MyColors.white,
                    border: Border(right: BorderSide(color: MyColors.grey1))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: MyColors.grey10)
                            ),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: MyColors.grey1.withOpacity(0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  "assets/food/breakfast.png",
                                  height: 60,
                                  width: 65,
                                ),
                              ),
                            ),
                          ),
                          if(breakfast>0)
                            Icon(
                              Icons.check_circle,
                              color: MyColors.green500,
                              size: 16,
                            )
                        ],
                      ),
                      SizedBox(
                        height: MySize.sizeh4(context),
                      ),
                      Text(
                        "Breakfast",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh2(context),
                      ),
                      Text(
                          "Continental &\nIndian menu",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: MySize.font10_5(context)
                          ),
                        ),
                      SizedBox(
                        height: MySize.sizeh5(context),
                      ),
                      Text(
                        "₹"+((hotelInfo.meal?.hmB=="COMPLIMENTARY" && slot==24 ? 0 : int.parse(hotelInfo.meal?.hmBreakfast??"0"))*adult).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh1(context),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(hotelInfo.meal?.hmB=='COMPLIMENTARY' && slot==24) {
                              breakfast = 0;
                            }
                            else {
                              if (breakfast > 0) {
                                breakfast = 0;
                              } else {
                                breakfast = adult;
                              }
                            }

                            setState(() {
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            height: 25,
                            width: 95,
                            alignment: Alignment.center,
                            decoration: breakfast <= 0 && !(hotelInfo.meal?.hmB=='COMPLIMENTARY' && slot==24)?
                            BoxDecoration(
                              color: MyColors.green500,
                              borderRadius: BorderRadius.circular(3),
                            ) :
                            BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: MyColors.grey10),
                            ),
                            child: breakfast <= 0 && !(hotelInfo.meal?.hmB=='COMPLIMENTARY' && slot==24)? Text(
                              "ADD",
                              style: TextStyle(
                                color: MyColors.white
                              ),
                            ) :
                            Text(
                              hotelInfo.meal?.hmB=="COMPLIMENTARY" && slot==24 ? hotelInfo.meal?.hmB??"" : "REMOVE",
                              style: TextStyle(
                                color: MyColors.grey30,
                                fontSize: 10
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if(hotelInfo.meal?.hmL!='UNAVAILABLE')
                Container(
                  width: MediaQuery.of(context).size.width*0.3,
                  decoration: BoxDecoration(
                      color: MyColors.white,
                      border: Border(right: BorderSide(color: MyColors.grey1))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: MyColors.grey10)
                            ),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: MyColors.grey1.withOpacity(0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  "assets/food/lunch.png",
                                  height: 60,
                                  width: 65,
                                ),
                              ),
                            ),
                          ),
                          if(breakfast>0)
                            Icon(
                              Icons.check_circle,
                              color: MyColors.green500,
                              size: 16,
                            )
                        ],
                      ),
                      SizedBox(
                        height: MySize.sizeh4(context),
                      ),
                      Text(
                        "Lunch",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh2(context),
                      ),
                      Text(
                        "Veg/Non-Veg Thali\n",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: MySize.font10_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh5(context),
                      ),
                      Text(
                        "₹"+((hotelInfo.meal?.hmL=="COMPLIMENTARY" && slot==24 ? 0 : int.parse(hotelInfo.meal?.hmLunch??"0"))*adult).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh1(context),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(hotelInfo.meal?.hmL=='COMPLIMENTARY' && slot==24) {
                              lunch = 0;
                            }
                            else {
                              if (lunch > 0) {
                                lunch = 0;
                              } else {
                                lunch = adult;
                              }
                            }

                            setState(() {
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            height: 25,
                            width: 95,
                            alignment: Alignment.center,
                            decoration: lunch <= 0 && !(hotelInfo.meal?.hmL=='COMPLIMENTARY' && slot==24) ?
                            BoxDecoration(
                              color: MyColors.green500,
                              borderRadius: BorderRadius.circular(3),
                            ) :
                            BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: MyColors.grey10),
                            ),
                            child: lunch <= 0 && !(hotelInfo.meal?.hmL=='COMPLIMENTARY' && slot==24) ? Text(
                              "ADD",
                              style: TextStyle(
                                  color: MyColors.white
                              ),
                            ) :
                            Text(
                              hotelInfo.meal?.hmL=="COMPLIMENTARY" && slot==24 ? hotelInfo.meal?.hmL??"" : "REMOVE",
                              style: TextStyle(
                                  color: MyColors.grey30,
                                  fontSize: 10
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if(hotelInfo.meal?.hmD!='UNAVAILABLE')
                Container(
                  width: MediaQuery.of(context).size.width*0.3,
                  decoration: BoxDecoration(
                      color: MyColors.white,
                      border: Border(right: BorderSide(color: MyColors.grey1))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: MyColors.grey10)
                            ),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: MyColors.grey1.withOpacity(0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  "assets/food/dinner.png",
                                  height: 60,
                                  width: 65,
                                ),
                              ),
                            ),
                          ),
                          if(breakfast>0)
                            Icon(
                              Icons.check_circle,
                              color: MyColors.green500,
                              size: 16,
                            )
                        ],
                      ),
                      SizedBox(
                        height: MySize.sizeh4(context),
                      ),
                      Text(
                        "Dinner",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh2(context),
                      ),
                      Text(
                        "Veg/Non-Veg Thali\n",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: MySize.font10_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh5(context),
                      ),
                      Text(
                        "₹"+((hotelInfo.meal?.hmD=="COMPLIMENTARY" && slot==24 ? 0 : int.parse(hotelInfo.meal?.hmDinner??"0"))*adult).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MySize.font11_5(context)
                        ),
                      ),
                      SizedBox(
                        height: MySize.sizeh1(context),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(hotelInfo.meal?.hmD=='COMPLIMENTARY' && slot==24) {
                              dinner = 0;
                            }
                            else {
                              if (dinner > 0) {
                                dinner = 0;
                              } else {
                                dinner = adult;
                              }
                            }

                            setState(() {
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            height: 25,
                            width: 95,
                            alignment: Alignment.center,
                            decoration: dinner <= 0 && !(hotelInfo.meal?.hmD=='COMPLIMENTARY' && slot==24)?
                            BoxDecoration(
                              color: MyColors.green500,
                              borderRadius: BorderRadius.circular(3),
                            ) :
                            BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: MyColors.grey10),
                            ),
                            child: dinner <= 0 && !(hotelInfo.meal?.hmD=='COMPLIMENTARY' && slot==24) ? Text(
                              "ADD",
                              style: TextStyle(
                                  color: MyColors.white
                              ),
                            ) :
                            Text(
                                hotelInfo.meal?.hmD=="COMPLIMENTARY" && slot==24 ? hotelInfo.meal?.hmD??"" : "REMOVE",
                              style: TextStyle(
                                  color: MyColors.grey30,
                                  fontSize: 10
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
  getPricingDetailsDesign(){
    return Container(
      color: MyColors.white,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pricing Details",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MySize.font14(context)
            ),
          ),
          // SizedBox(
          //   height: MySize.sizeh1(context),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/offers/offer.png",
                    color: MyColors.yellow900,
                    height: 25,
                    width: 25,
                  ),
                  SizedBox(
                    width: MySize.size1(context),
                  ),
                  Text(
                    offer>=0 ? (offers[offer].offer?.code??"").toString()+" coupon applied" : "Apply coupon",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: MySize.font12(context)
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CheckboxListTile(
                    value: offer>=0 ? true : false,
                    title: Text(
                      offer>=0 ? "- ₹"+getOfferDiscountPrice().toString() : "",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: MyColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    activeColor: MyColors.colorPrimary,
                    contentPadding: EdgeInsets.all(0),
                    onChanged: (value){
                      if(value!=null && value) {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            AllOffers(offer: offer, h_id: h_id))).then((value) {
                          offer = value;
                          setState(() {

                          });
                        });
                      }
                      else {
                        offer = -1;
                      }
                      setState(() {

                      });
                    }
                ),
              ),
            ],
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>
                    AllOffers(offer: offer, h_id: h_id))).then((value) {
                  offer = value;
                  setState(() {

                  });
                });
              },
              child: Container(
                  width: 95,
                  height: 25,
                  margin: EdgeInsets.only(left: 35, bottom: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MyColors.green500.withOpacity(0.15),
                    border: Border.all(color: MyColors.green500),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    "More offers",
                    style: TextStyle(
                        color: MyColors.green500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500
                    ),
                  )
              ),
            ),
          ),
          if(!show_bill)
            Divider(thickness: 1,),
          ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price to pay",
                  style: TextStyle(
                      color: MyColors.black,
                      fontSize: MySize.font12(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: APIConstant.symbol+(getBasePrice()+getBreakfastPrice()+getLunchPrice()+getDinnerPrice()).toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: MyColors.grey.withOpacity(0.5),
                        decoration: TextDecoration.lineThrough,
                        fontSize: MySize.font13_5(context)
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "  "+APIConstant.symbol+getTotalPrice().toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: MyColors.black,
                              decoration: TextDecoration.none,
                              overflow: TextOverflow.ellipsis,
                              fontSize: MySize.font14_5(context)
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Container(
                margin: EdgeInsets.only(left: MySize.size1(context), right: MySize.size1(context), bottom: MySize.sizeh1(context)),
                padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context), horizontal: MySize.size1(context)),
                decoration: BoxDecoration(
                    color: MyColors.grey10,
                    borderRadius: BorderRadius.circular(MySize.sizeh055(context))
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room price for "+getDuration()+" X "+rooms.length.toString()+(rooms.length==1 ? " Room" : " Rooms"),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w300
                            ),
                          ),
                          Text(
                            APIConstant.symbol+getBasePrice().toString(),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Price Drop",
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w300
                            ),
                          ),
                          Text(
                            "- "+APIConstant.symbol+getDiscountedPrice().toString(),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    if(offer>=0)
                      Container(
                        margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getOfferDiscount().toString()+getOfferDiscountType()+" Coupon Discount",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              "- "+APIConstant.symbol+getOfferDiscountPrice().toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    if(hotelInfo.meal!=null && (breakfast>0 || lunch>0 || dinner>0))
                      getMealsBilling(),
                    Divider(
                      thickness: 1,
                      color: MyColors.white,
                    ),
                    SizedBox(height: MySize.sizeh1(context),),
                    Container(
                      margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Taxable Price",
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w300
                            ),
                          ),
                          Text(
                            APIConstant.symbol+getTaxablePrice().toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total GST ("+gst.toString()+"%)",
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w300
                            ),
                          ),
                          Text(
                            "+ "+APIConstant.symbol+getGSTPrice().toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
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
                              fontSize: MySize.font11(context),
                              fontWeight: FontWeight.w300
                          ),
                        ),
                        Text(
                          APIConstant.symbol+getTotalPrice().toString(),
                          style: TextStyle(
                              fontSize: MySize.font11(context),
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: MySize.sizeh1(context),),
          VisibilityDetector(
            key: Key('my-widget-key'),
            onVisibilityChanged: (VisibilityInfo info) {
              if(info.visibleFraction*100 > 0.0 && show_pay==true) {
                show_pay = false;
              }
              else if(info.visibleFraction*100 == 0.0 && show_pay==false) {
                show_pay = true;
              }
              setState(() {

              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if(sharedPreferences?.getString("login_type")=="customer") {
                    if (timing > -1) {
                      bookNow();
                    }
                  }
                  else {
                    loginPopUp();
                  }
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MyColors.green500,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      "Book Now",
                      style: TextStyle(
                          color: MyColors.white,
                          fontSize: MySize.font13(context),
                          fontWeight: FontWeight.w500
                      ),
                    )
                ),
              ),
            ),
          ),
          SizedBox(height: MySize.sizeh3(context),),
          Align(
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                text: "By proceeding , you agree to our ",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: MyColors.black,
                    fontSize: MySize.font11(context)
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: "Guest Policies",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: MyColors.orange
                      ),
                      recognizer: TapGestureRecognizer()..onTap = guestPolicy
                  ),
                  TextSpan(
                      text: " and "
                  ),
                  TextSpan(
                      text: "Cancellation Policies",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: MyColors.orange
                      ),
                      recognizer: TapGestureRecognizer()..onTap = cancellationPolicy
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getMealsBilling()
  {
    return Column(
      children: [
        if(breakfast>0)
          Container(
            margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Breakfast",
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+getBreakfastPrice().toString(),
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        if(lunch>0)
          Container(
            margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lunch",
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+getLunchPrice().toString(),
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        if(dinner>0)
          Container(
            margin: EdgeInsets.only(bottom: MySize.sizeh2(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dinner",
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+getDinnerPrice().toString(),
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  getBasePrice()
  {
    return int.parse(categories[category].category?.cpBase ?? "0") * rooms.length * (de.day - ds.day > 0 ? de.day - ds.day : 1);
  }
  getDiscount()
  {
    return int.parse(categories[category].category?.cpDiscount ?? "0");
  }
  getDiscountedPrice(){
    int base = getBasePrice();
    int discount = getDiscount();
    return (base * (discount / 100.0)).round();
  }

  getNewPrice(){
    int base = getBasePrice();
    int disc_price = getDiscountedPrice();
    int new_price = base - disc_price;
    return new_price;
  }

  getNewRoomPrice(int ind){
    return (int.parse(categories[ind].category?.cpBase ?? "0") - (int.parse(categories[ind].category?.cpBase ?? "0")*(int.parse(categories[ind].category?.cpDiscount ?? "0")/100.0))).round();
  }

  getOfferDiscount() {
    return offer>=0 ? int.parse(offers[offer].offer?.discount??"0") : 0;
  }

  getOfferDiscountType() {
    return offer>=0 ? (offers[offer].offer?.discountType=="PERCENTAGE") ? "%" : "/-" : "/-";
  }

  getOfferDiscountPrice() {
    if(offer>=0 && (offers[offer].offer?.discountType??"")=='PERCENTAGE') {
      int disc = getOfferDiscount();
      int new_price = getNewPrice();
      return (new_price*(disc/100.0)).round();
    }
    else {
      return getOfferDiscount();
    }
  }

  getBreakfastPrice() {
    if(breakfast>0)
      if(hotelInfo.meal?.hmB=='COMPLIMENTARY' && slot==24) {
        return 0;
      } else {
        return breakfast * int.parse(hotelInfo.meal?.hmBreakfast??"0");
      }
    else {
      return 0;
    }
  }

  getLunchPrice() {
    if(lunch>0)
      if(hotelInfo.meal?.hmL=='COMPLIMENTARY' && slot==24) {
        return 0;
      } else {
        return lunch * int.parse(hotelInfo.meal?.hmLunch??"0");
      }
    else {
      return 0;
    }
  }

  getDinnerPrice() {
    if(dinner>0)
      if(hotelInfo.meal?.hmD=='COMPLIMENTARY' && slot==24) {
        return 0;
      } else {
        return dinner * int.parse(hotelInfo.meal?.hmDinner??"0");
      }
    else {
      return 0;
    }
  }

  getTaxablePrice() {
    return getTotalPrice() - getGSTPrice();
  }

  getGSTPrice() {
    return getTotalPrice()*(gst/100);
  }

  getTotalPrice() {
    return getBasePrice() - getDiscountedPrice() - getOfferDiscountPrice() + (hotelInfo.meal!=null ? getBreakfastPrice() + getLunchPrice() + getDinnerPrice() : 0);
  }

  String getDuration() {
    if(slot==24) {
      return (de.day - ds.day).toString()+" Night";
    } else {
      return slot.toString()+" Hours";
    }
  }

  getSimilarHotelsDesign() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      color: MyColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: "Similar OLR's Nearby ",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MySize.font14(context),
                  color: MyColors.black
                ),
                children: [
                  TextSpan(
                      text: "(Map View)",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: MySize.font12(context)
                      ),
                      recognizer: TapGestureRecognizer()..onTap = mapView
                  )
                ]
            ),
          ),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          similar.length>0 ? Container(
              width: MediaQuery.of(context).size.width,
              height: 210,
              padding: EdgeInsets.only(top: 15),
              margin: EdgeInsets.only(bottom: 15, right: 10),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similar.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 10);
                },
                itemBuilder: (BuildContext context, index) {
                  return getHotelDesign(similar[index], index);
                },
              )
          ) :
          Container(
            alignment: Alignment.center,
            child: Text(
              "No Nearby Hotels",
              style: TextStyle(
                  fontSize: MySize.font15(context)
              ),
            ),
          ),
        ],
      ),
    );
  }
  // getSimilarHotelsDesign() {
  //   return Container(
  //     height: MySize.size220(context),
  //     padding: EdgeInsets.fromLTRB(15, 20, 10, 20),
  //     color: MyColors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         RichText(
  //           text: TextSpan(
  //             text: "Similar OLR's nearby",
  //             style: TextStyle(
  //                 fontWeight: FontWeight.w500,
  //                 fontSize: 16
  //             ),
  //             children: [
  //               TextSpan(
  //                 text: "(Map View)",
  //                 style: TextStyle(
  //                     fontWeight: FontWeight.w400,
  //                     fontSize: MySize.font10(context)
  //                 ),
  //                 recognizer: TapGestureRecognizer..onTap
  //               )
  //             ]
  //           ),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         Container(
  //           width: MediaQuery.of(context).size.width,
  //           padding: EdgeInsets.only(top: 15),
  //           margin: EdgeInsets.only(bottom: 15, right: 10),
  //           child: similar.length>0 ? ListView.separated(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: similar.length,
  //             shrinkWrap: true,
  //             separatorBuilder: (BuildContext context, int index) {
  //               return SizedBox(width: 10);
  //             },
  //             itemBuilder: (BuildContext context, index) {
  //               return getHotelDesign(similar[index], index);
  //             },
  //           ) : Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               "No Nearby Hotels",
  //               style: TextStyle(
  //                   fontSize: MySize.font16(context)
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  getHotelDesign(HotelInfo hotel, int ind) {
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
              MaterialPageRoute(builder: (context) => HotelDetailsM(h_id: hotel.hotel?.hId??"",)));
        },
        child: Container(
          width: 180,
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
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    child: (hotel.hotel?.hImageCount??"0")=="0" ? Container(
                      height: 100,
                      width: 200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                      ),
                    )
                    : Image.network(
                      Environment.imageUrl + (hotel.images?[0].hiImage??""),
                      fit: BoxFit.fill,
                      height: 100,
                      width: 200,
                    ),
                  ),
                  IgnorePointer(
                    ignoring: s_enabled[ind],
                    child: IconButton(
                        onPressed: () {
                          if(sharedPreferences?.getString("login_type")=="customer") {
                            s_enabled[ind] = !s_enabled[ind];
                            setState(() {

                            });

                            if (hotel.hotel?.liked != "0")
                              manageWishlist(APIConstant.del, hotel, ind);
                            else
                              manageWishlist(APIConstant.add, hotel, ind);
                          }
                          else {
                            loginPopUp();
                          }
                        },
                        icon: Icon(
                          hotel.hotel?.liked!="0"
                              ? Icons.star
                              : Icons.star_border,
                          color:
                          hotel.hotel?.liked!="0" ? MyColors.colorPrimary : MyColors.white,
                        )
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotel?.hName??"",
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                        color: new Color(0xFF212121),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: 12.0,
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
                            fontSize: 12
                        ),
                        children: <TextSpan>[
                          TextSpan(text: APIConstant.symbol + base.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.lineThrough,
                                  color: MyColors.black,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 10
                              )
                          ),
                          TextSpan(text: "  " + discount.floor().toString() +
                              "% OFF",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.orange,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 8
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
      ),
    );
  }

  getRulesDesign() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), ),
      width: MediaQuery.of(context).size.width,
      color: MyColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getIMP()
        ],
      ),
    );
  }

  getRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• This is rule one.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule two.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule three.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule four.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule five.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule six.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule seven.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule eight.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule nine.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• This is rule ten.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
      ],
    );
  }

  getCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cancellation Policy",
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "• Cancellation policy line one.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• Cancellation policy line two.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• Cancellation policy line three.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• Cancellation policy line four.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "• Cancellation policy line five.",
          style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14
          ),
        ),
      ],
    );
  }

  getIMP() {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text(
    //       "Important to note",
    //       style: TextStyle(
    //           fontWeight: FontWeight.w400,
    //           fontSize: MySize.font18(context)
    //       ),
    //     ),
    //     SizedBox(
    //       height: MySize.size10(context),
    //     ),
    //     Html(
    //       data: unescape.convert(utf8.decode(base64Decode(hotelInfo.hotel?.hgPolicy??""))),
    //     ),
    //   ],
    // );
    return ListTile(
      tileColor: MyColors.white,
      leading: Text(
        "Hotel Rules & Policies",
        style: TextStyle(
            fontSize: MySize.font14(context),
            fontWeight: FontWeight.w400
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: MySize.sizeh5(context),
        color: MyColors.colorPrimary,
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                Policies(
                  policy_type: "Hotel Policy",
                  act: APIConstant.getHP,
                  h_id: hotelInfo.hotel?.hId??"",
                )
            )
        );
      },
    );
  }

  void bookNow() {
    getMealsBilling();
    Map<String, dynamic> data = {
      "h_id" : h_id,
      if(categories[category].category?.catId!=null)
        "cat_id" : categories[category].category?.catId??"",
      "b_breakfast" : breakfast.toString(),
      "b_lunch" : lunch.toString(),
      "b_dinner" : dinner.toString(),
      "b_bprice" : getBreakfastPrice().toString(),
      "b_lprice" : getLunchPrice().toString(),
      "b_dprice" : getDinnerPrice().toString(),
      "br_adult" : adult.toString(),
      "br_child" : child.toString(),
      "br_guest" : guest.toString(),
      "br_rprice" : getNewRoomPrice(category),
      "br_time_period" : slot,
      "br_start" : DateFormat("yyyy-MM-dd").format(ds)+" "+timing.toString()+":00:00",
      "br_end" : DateFormat("yyyy-MM-dd HH:mm:ss").format(de),
      "br_rooms" : rooms,
      "bill_amount" : getNewPrice().toString(),
      "bill_discount" : getOfferDiscount().toString(),
      if(offer>=0 && offers[offer].offer?.discountType!=null)
        "bill_discount_type" : offers[offer].offer?.discountType??"",
      "bill_discount_amount" : getOfferDiscountPrice().toString(),
      "bill_total" : getTotalPrice().toString(),
      if(offer>=0 && offers[offer].type=='olr')
        "oo_id" : offers[offer].offer?.id,
      if(offer>=0 && offers[offer].type=='hotel')
        "oh_id" : offers[offer].offer?.id,
      if(offer>=0 && offers[offer].type=='city')
        "oc_id" : offers[offer].offer?.id,
      if(offer>=0 && offers[offer].type=='olr')
        "offer_type" : "OLR",
      if(offer>=0 && offers[offer].type=='hotel')
        "offer_type" : "HOTEL",
      if(offer>=0 && offers[offer].type=='city')
        "offer_type" : "OLR",
    };
    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>
        ConfirmBooking(
          data: data,
          ds: ds,
          timing: timing,
          de: de,
          guest: guest,
          adult: adult,
          child: child,
          rooms: rooms,
          currency: APIConstant.symbol,
          taxable_price: getTaxablePrice(),
          gst_amount: getGSTPrice(),
          gst_per: gst,
          total_price: getTotalPrice(),
          deposit: hotelInfo.hotel?.hgDeposit??"0",
          deposit_type: hotelInfo.hotel?.hgDepositType??"Percentage",
          pay_at_hotel: hotelInfo.hotel?.hgPayAtHotel??"0",
          requests: requests,
        )));
  }

  Future<void> getHotelDetailsM() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
      "h_id": h_id
    };
    HotelDetailResponse hotelDetailResponse = await APIService().getHotelDetails(queryParameters);

    if(hotelDetailResponse.status=="Success" && hotelDetailResponse.message=="Hotel Details Retrieved") {
      hotelInfo = hotelDetailResponse.hotel ?? HotelInfo();
      places = hotelDetailResponse.nearby ?? [];
      ratings = hotelDetailResponse.reviews ?? [];
      similar = hotelDetailResponse.hotels ?? [];
      requests = hotelDetailResponse.requests ?? [];

      if(hotelInfo.meal!=null) {
        getInitialMeals();
      }
      await WriteCache.setBool(key: "key_h"+h_id, value: true);
      await WriteCache.setJson(key: "h"+h_id, value: hotelDetailResponse.toJson());
      List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
      keys.add("key_h"+h_id);
      keys.add("h"+h_id);
      await WriteCache.setListString(key: "keys", value: keys);
      setState(() {

      });
      setImage();
      getHotelSlots();
    }
    else {
      places = [];
      ratings = [];
      similar = [];
      requests = [];
      Toast.sendToast(context, hotelDetailResponse.message??"");
    }
  }
  setImage() {
    int len = hotelInfo.images?.length??0;
    for (int i = 0; i < len; i++) {
      slideShow.add(
        MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HotelImages(
                  h_id: h_id,
                  cat_id: "",
                  act: APIConstant.getByHotel,
                )));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    // padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                          ),
                        ]),
                    child: Image.network(
                        Environment.imageUrl + (hotelInfo.images?[i].hiImage ?? ""),
                        fit: BoxFit.fill,
                        width: 1000),
                    // child: Image.asset(
                    //   banners[i].banImage,
                    //   fit: BoxFit.fill,
                    // ),
                  )
              ),
            ),
          ),
      );
    }
  }

  getImageView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      child: CarouselSlider(
          options: CarouselOptions(
              enlargeCenterPage: true,
              height: 200,
              initialPage: 0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3)
          ),
          items: slideShow),
    );
  }


  // void setImagecontroller() {
  //   controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 5),
  //   )
  //     ..addListener(() {
  //       if (controller!.value >= 0.99) {
  //         show = true;
  //         controller!.stop();
  //       }
  //       else if (controller!.value >= 0.8) {
  //         pos = 4;
  //       }
  //       else if (controller!.value >= 0.6) {
  //         pos = 3;
  //       }
  //       else if (controller!.value >= 0.4) {
  //         pos = 2;
  //       }
  //       else if (controller!.value >= 0.2) {
  //         pos = 1;
  //       }
  //       setState(() {
  //
  //       });
  //     });
  //   controller!.repeat(reverse: true);
  // }

  getNearbyPlaces() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
      "h_id": h_id
    };
    NearbyResponse nearbyResponse = await APIService().getNearbyPlaces(queryParameters);

    if (nearbyResponse.status == 'Success' &&
        nearbyResponse.message == 'Nearby Places Retrieved')
      places = nearbyResponse.data ?? [];
    else
      places = [];
    setState(() {

    });
  }

  getAllRatings() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getAll,
      "h_id": h_id
    };
    ReviewsResponse reviewsResponse = await APIService().getRatings(queryParameters);

    if (reviewsResponse.status == 'Success' &&
        reviewsResponse.message == 'Ratings Retrieved')
      ratings = reviewsResponse.data ?? [];
    else
      ratings = [];
    setState(() {

    });
  }

  Future<void> manageWishlist(String act, HotelInfo hotel, ind) async {
    hotel.hotel?.hId;
    Map<String, String> data = {
      APIConstant.act: act,
      if(act==APIConstant.add)
        'h_id' : hotel.hotel?.hId??"-1"
      else
        'w_id' : hotel.hotel?.liked??"-1"
    };

    WishlistResponse wishlistResponse = await APIService().manageWishlist(data);
    if (wishlistResponse.status == 'Success') {
      hotel.hotel?.liked = wishlistResponse.data;
    }

    if(ind==-1)
      r_enabled = !r_enabled;
    else
      s_enabled[ind] = !s_enabled[ind];

    // DeleteCache.deleteKey("key_h"+h_id);
    DeleteCache.deleteKey("key_dashboard");
    DeleteCache.deleteKey("key_wishlist");

    setState(() {

    });
    getHotelDetailsM();
    Toast.sendToast(context, wishlistResponse.message??"");
  }

  Future<void> getHotelSlots() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
      "h_id": h_id
    };
    HotelSlotsResponse hotelSlotsResponse = await APIService().getHotelSlots(queryParameters);

    if(hotelSlotsResponse.status=="Success" && hotelSlotsResponse.message=="Hotel Slots Retrieved") {
      timePeriod = hotelSlotsResponse.data ?? TimePeriod();


      if(timePeriod.tp3=="1") {
        slots.add(3);
      }
      if(timePeriod.tp6=="1") {
        slots.add(6);
      }
      if(timePeriod.tp12=="1") {
        slots.add(12);
      }
      if(timePeriod.tp24=="1") {
        slots.add(24);
      }


      slot = slots[0];
      // initValues();

      setState(() {

      });
      getCategories();

    }
    else {
      Toast.sendToast(context, hotelSlotsResponse.message??"");
    }
  }

  Future<void> getCategories() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByTime,
      "h_id": h_id,
      "slot": slot.toString()
    };
    CategoryResponse categoryResponse = await APIService().getCategories(data);
    print(data);
    print("categoryResponse.toJson()");
    print(categoryResponse.toJson());

    if(categoryResponse.status=="Success" && categoryResponse.message=="Categories Retrieved") {
      categories = categoryResponse.data ?? [];
    }
    else {
      categories = [];
      Toast.sendToast(context, categoryResponse.message??"");
    }

    setState(() {

    });

    manageHotelTimings();
  }

  Future<void> manageHotelTimings() async {
    print(categories);
    Map<String, String> data = {
      APIConstant.act: APIConstant.getBySlot,
      "cat_id": categories[category].category?.catId??"",
      "slot": slot.toString(),
      "date": ds.year.toString()+"-"+ds.month.toString()+"-"+ds.day.toString(),
    };
    HotelTimingsResponse hotelTimingsResponse = await APIService().getHotelTimings(data);

    if(hotelTimingsResponse.status=="Success" && hotelTimingsResponse.message=="Hotel Timings Retrieved") {
      timings = hotelTimingsResponse.data ?? [];
    }
    else {
      timings = [];
      Toast.sendToast(context, hotelTimingsResponse.message??"");
    }

    setState(() {

    });
    getHotelOffers();
    changeTiming();
  }

  Future<bool> checkAvailability() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByDate,
      "cat_id": categories[category].category?.catId??"",
      "slot": slot.toString(),
      "start": ds.year.toString()+"-"+ds.month.toString()+"-"+ds.day.toString(),
      "end": de.year.toString()+"-"+de.month.toString()+"-"+de.day.toString(),
    };
    HotelTimingsResponse hotelTimingsResponse = await APIService().checkAvailability(data);

    if(hotelTimingsResponse.status=="Success" && hotelTimingsResponse.message=="Checked Availability") {
      timings = hotelTimingsResponse.data ?? [];
    }
    else {
      timings = [];
    }
    return true;
  }

  Future<void> getHotelOffers() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByHotel,
      "h_id": h_id,
    };
    HotelOfferResponse hotelOfferResponse = await APIService().getHotelOffers(data);

    if(hotelOfferResponse.status=="Success" && hotelOfferResponse.message=="Offers Retrieved") {
      offers = hotelOfferResponse.data ?? [];
    }
    else {
      offers = [];
      Toast.sendToast(context, hotelOfferResponse.message??"");
    }
    offer = offers.length>0 ? 0 : -1;

    setState(() {

    });
  }

  Future<void> getNearbyHotels() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getNearby,
      "h_id" : hotelInfo.hotel?.hId??"",
      "ar_id" : hotelInfo.hotel?.arId??""
    };
    HotelResponse hotelResponse = await APIService().getNearbyHotels(queryParameters);
    if (hotelResponse.status == 'Success' &&
        hotelResponse.message == 'Hotels Retrieved') {
      similar = hotelResponse.data ?? [];
    }
    else
      similar = [];

    s_enabled = List.filled(similar.length, false);

    setState(() {

    });
  }

  void guestPolicy() {
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

  void cancellationPolicy() {
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

  mapView() async {
    // final availableMaps = await MapLauncher.installedMaps;
    //
    // await availableMaps.first.showMarker(
    //   coords: Coords(double.parse(hotelInfo.hotel?.hgLat??"0"),double.parse(hotelInfo.hotel?.hgLong??"0")),
    //   title: hotelInfo.hotel?.hName??"",
    // );
    Set<Marker> markers = Set(); //markers for google map

    for(int i = 0; i<similar.length; i++)
    {
      LatLng showLocation = LatLng(double.parse(similar[i].hotel?.hgLat??"0.0"), double.parse(similar[i].hotel?.hgLat??"0.0"));

      markers.add(Marker( //add marker on google map
        markerId: MarkerId(showLocation.toString()),
        position: showLocation, //position of marker
        infoWindow: InfoWindow( //popup info
          title: similar[i].hotel?.hgLat??"NG",
          // snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    }

    // markers.add(Marker( //add marker on google map
    //   markerId: MarkerId(showLocation.toString()),
    //   position: showLocation, //position of marker
    //   infoWindow: InfoWindow( //popup info
    //     title: 'My Custom Title ',
    //     snippet: 'My Custom Subtitle',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    // ));

    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>
        MapView(
          markers: markers,
        )
      )
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
      if(value=="login")
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
}

getContainer(Color colors){
  return Container(
    height: 100,
    width: 100,
    color: colors,
  );
}
