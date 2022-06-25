import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:olr_rooms_web/AllCities.dart';
import 'package:olr_rooms_web/BannerHotels.dart';
import 'package:olr_rooms_web/BecomePartner.dart';
import 'package:olr_rooms_web/CitySearch.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/MyPopTemplate.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/components.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/BannerInfo.dart';
import 'package:olr_rooms_web/model/BannerResponse.dart';
import 'package:olr_rooms_web/model/City.dart';
import 'package:olr_rooms_web/model/DashboardResponse.dart';
import 'package:olr_rooms_web/model/HotelInfo.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/PopBanner.dart';
import 'package:olr_rooms_web/model/PopBannerResponse.dart';
import 'package:olr_rooms_web/model/PopularCityResponse.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../HomeData.dart';
import '../Login.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetailsW.dart';

import '../strings/Strings.dart';

class HomeW extends StatefulWidget {
  // final bool cache;
  const HomeW({Key? key}) : super(key: key);

  @override
  State<HomeW> createState() => _HomeWState();
}

class _HomeWState extends State<HomeW> {

  late SharedPreferences sharedPreferences;

  TextEditingController searchController = TextEditingController();
  List<Widget> slideShow = [];
  List<SearchInfo> search_list = [];

  bool hoverh = false;
  bool hoverb = false;
  bool hovero = false;
  bool hovers = false;
  bool hoverm = false;

  // List<String> banners = ['assets/banners/banner1.jpg', 'assets/banners/banner2.jpg', 'assets/banners/banner3.jpeg', 'assets/banners/banner4.jpg'];

  var homeinfo;
  List<City> city = [];
  PopBanner popBanner = PopBanner();
  List<BannerInfo> banners = [];
  List<HotelInfo> collection = [];
  List<HotelInfo> recommended = [];
  List<HotelInfo> holiday = [];
  List<bool> c_enabled = [];
  List<bool> r_enabled = [];
  List<bool> h_enabled = [];
  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  bool load = false;
  // bool cache = false;

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      key: scaffoldkey,
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: MenuBar(sharedPreferences: sharedPreferences, name: "HOME"),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getCitiesView(),
                              getBannerView(),
                              Text(
                                "4 Simple Steps",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: MySize.font8_5(context),
                                ),
                              ),
                              getStepsView(),
                              const SizedBox(height: 20,),
                              Text(
                                "Our Collections",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: MySize.font8_5(context),
                                ),
                              ),
                              getHotelsView(collection, "Collection"),
                              Text(
                                "Recommended For You",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: MySize.font8_5(context),
                                ),
                              ),
                              getHotelsView(recommended, "Recommended"),
                              Text(
                                "BEST To Enjoy Holidays",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: MySize.font8_5(context),
                                ),
                              ),
                              getHotelsView(holiday, "Holiday"),
                            ],
                          ),
                        ),
                      ),
                      Footer()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    ) : const Center(
      child: const CircularProgressIndicator(),
    );
  }


  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();

    homeinfo = Provider.of<HomeData>(context, listen: false);

    homeinfo.updateMobile(sharedPreferences.getString("mobile") ?? "");
    homeinfo.updateCode(sharedPreferences.getString("code") ?? "");
    homeinfo.updateName(sharedPreferences.getString("name") ?? "");

    if(!(sharedPreferences.getBool("pop")??true)) {
      await getPopBanner();
    }
    getDashboard();
    // checkCache();

    // await getUserInfo();
    // await getPopularCities();
    // await getBanners();
    // getOurCollection();

    // setState(() {
    //
    // });
  }

  showPopUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MyPopTemplate(banner: popBanner.pbImage??"");
      },
    ).then((value) {
      sharedPreferences.setBool("pop", true);
    });
  }

  getPlaceDesign(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(ind==city.length) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    AllCities())).then((value) {

              checkCache();
            });
          }
          else {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    CitySearch(search: city[ind].cName ?? ''))).then((value) {
              checkCache();
            });
          }
        },
        child: ind!=city.length ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 45,
                backgroundImage: NetworkImage(
                    Environment.imageUrl + (city[ind].pcImage ?? ""))
            ),
            const SizedBox(
              height: 10,
            ),
            Text(city[ind].cName ?? "", textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15
              ),
            )
          ],
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: MyColors.grey1,
                radius: 45,
                child: Icon(
                  Icons.location_city,
                  size: 30,
                ),
            ),
            const SizedBox(
              height: 10,
              // height: MySize.size05(context),
            ),
            Text("All Cities", textAlign: TextAlign.center,
              style: const TextStyle(
                // fontSize: MySize.font7_5(context)
                  fontSize: 15
              ),
            )
          ],
        ),
      ),
    );
  }

  getCitiesView() {
    return Container(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: city.length+1,
        separatorBuilder: (BuildContext context, index) {
          return const SizedBox(
            width: 25,
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getPlaceDesign(index);
        },
      ),
      width: MediaQuery.of(context).size.width,
      height: 120,
      // height: MySize.sizeh20(context),
    );
  }

  getHotelsView(List<HotelInfo> hotels, String type) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        margin: EdgeInsets.symmetric(vertical: MySize.sizeh2(context)),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: hotels.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: MySize.size3(context));
          },
          itemBuilder: (BuildContext context, index) {
            return getHotelDesign(hotels[index], type, index);
          },
        )
    );
  }

  getHotelDesign(HotelInfo hotel, String type, int ind) {
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
              MaterialPageRoute(builder: (context) => HotelDetails(h_id: hotel.hotel?.hId??"",))).then((value) {

            checkCache();
          });
        },
        child: Container(
          width: MySize.size22(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MySize.sizeh075(context)),
                    child: (hotel.hotel?.hImageCount??"0")=="0" ? Container(
                      height: 400 * 0.7,
                      width: MySize.size22(context),
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                      ),
                    )
                        : Image.network(
                      Environment.imageUrl + (hotel.images?[0].hiImage??""),
                      fit: BoxFit.fill,
                      height: 400 * 0.7,
                      width: MySize.size22(context),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: type=='Collection' ? c_enabled[ind] : type=='Recommended' ? r_enabled[ind] : h_enabled[ind],
                    child: IconButton(
                        onPressed: () {
                          if(sharedPreferences.getString("login_type")=="customer") {
                            if(type=='Collection')
                              c_enabled[ind] = !c_enabled[ind];
                            else if(type=='Recommended')
                              r_enabled[ind] = !r_enabled[ind];
                            else
                              h_enabled[ind] = !h_enabled[ind];

                            setState(() {

                            });

                            if(hotel.hotel?.liked!="0")
                              manageWishlist(APIConstant.del, hotel, ind);
                            else
                              manageWishlist(APIConstant.add, hotel, ind);
                          }
                          else{
                            Essential().loginPopUp(context);
                          }
                        },
                        icon: Icon(
                          hotel.hotel?.liked!="0"
                              ? Icons.star
                              : Icons.star_border,
                          color:
                          hotel.hotel?.liked!="0" ? MyColors.colorPrimary.withOpacity(0.9) : MyColors.white,
                        )
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotel?.hName??"",
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: MySize.font7_5(context),
                        fontFamily: 'Roboto',
                        color: const Color(0xFF212121),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: MySize.sizeh05(context),
                    ),
                    Text(
                      (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                        fontSize: MySize.font7_5(context),
                        fontFamily: 'Roboto',
                        color: MyColors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(
                      height: MySize.sizeh1(context),
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
                          fontSize: MySize.font7_5(context),
                        ),
                        children: <TextSpan>[
                          TextSpan(text: APIConstant.symbol + base.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                decoration: TextDecoration.lineThrough,
                                color: MyColors.black,
                                overflow: TextOverflow.ellipsis,
                                fontSize: MySize.font7(context),
                              )
                          ),
                          TextSpan(text: "  " + discount.floor().toString() +
                              "% OFF",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: MyColors.orange,
                                overflow: TextOverflow.ellipsis,
                                fontSize: MySize.font6_5(context),
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

  getStepsView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      height: MySize.sizeh25(context),
      child: Row(
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.sizeh05(context)),
              child: Image.asset(
                "assets/steps/step1.jpg",
                fit: BoxFit.fill,
                // height: size,
                // width: size,
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          SizedBox(
            width: MySize.size2(context),
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.sizeh05(context)),
              child: Image.asset(
                "assets/steps/step2.jpg",
                fit: BoxFit.fill,
                // height: size,
                // width: size,
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          SizedBox(
            width: MySize.size2(context),
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.sizeh05(context)),
              child: Image.asset(
                "assets/steps/step3.jpg",
                fit: BoxFit.fill,
                // height: size,
                // width: size,
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          SizedBox(
            width: MySize.size2(context),
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.sizeh05(context)),
              child: Image.asset(
                "assets/steps/step4.jpg",
                fit: BoxFit.fill,
                // height: size,
                // width: size,
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
        ],
      ),
    );
  }

  getUserInfo() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID
    };
    UserResponse userResponse = await APIService().getUserDetails(queryParameters);
    if((userResponse.status??"")=="Success") {
      homeinfo = Provider.of<HomeData>(context, listen: false);

      homeinfo.updateMobile(userResponse.data?.user?.cusMobile);
      homeinfo.updateCode(userResponse.data?.user?.cusCc);
      homeinfo.updateName(userResponse.data?.user?.cusName);
      setState(() {

      });
    }
    else
    {
      if((userResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, userResponse.message??"");
      }
    }
  }

  getPopBanner() async {
    PopBannerResponse popBannerResponse = await APIService().getPopBanner();

    if (popBannerResponse.status == 'Success' && popBannerResponse.message == 'Pop Banner Retrieved') {
      popBanner = popBannerResponse.data ?? PopBanner();
      setState(() {

      });
      // if((popBanner.pbImage??"").isNotEmpty)
      //   showPopUp();
    }
    else
    {
      if((popBannerResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, popBannerResponse.message??"");
      }
    }
  }

  getBanners() async {
    BannerResponse bannerResponse = await APIService().getBanners();

    if (bannerResponse.status == 'Success' &&
        bannerResponse.message == 'Banners Retrieved')
      banners = bannerResponse.data ?? [];
    else
    {
      if((bannerResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, bannerResponse.message??"");
      }
    }
    setState(() {

    });
    setBanners();
  }

  setBanners() {
    for (int i = 0; i < banners.length; i++) {
      slideShow.add(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if ((banners[i].hotel?.length??0)>0) {
                if ((banners[i].hotel?.length??0)>1) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>
                      BannerHotels(id: banners[i].banner?.banId??"")));
                }
                else {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) =>
                      HotelDetails(h_id: banners[i].hotel?[0] ?? "",))).then((value) {

                    checkCache();
                  });
                }
              }
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(MySize.sizeh075(context)),
                child: Container(
                  // padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                        ),
                      ]),
                  child: Image.network(
                      Environment.imageUrl + (banners[i].banner?.banImage ?? ""),
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

    setState((){

    });
  }

  getBannerView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context)),
      child: CarouselSlider(
          options: CarouselOptions(
              enlargeCenterPage: true,
              height: MySize.sizeh30(context),
              viewportFraction: 0.3,
              initialPage: 0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3)
          ),
          items: slideShow),
    );
  }

  Future<void> getOurCollection() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getDashboard,
      APIConstant.type: APIConstant.collection,
    };
    HotelResponse hotelResponse = await APIService().getDashboardHotels(queryParameters);
    if (hotelResponse.status == 'Success' &&
        hotelResponse.message == 'Hotels Retrieved') {
      collection = hotelResponse.data ?? [];
    }
    else
    {
      if((hotelResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, hotelResponse.message??"");
      }
    }

    c_enabled = List.filled(collection.length, false);

    setState(() {

    });
    getRecommendedHotels();
  }

  Future<void> getRecommendedHotels() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getDashboard,
      APIConstant.type: APIConstant.recommended,
    };
    HotelResponse hotelResponse = await APIService().getDashboardHotels(queryParameters);
    if (hotelResponse.status == 'Success' &&
        hotelResponse.message == 'Hotels Retrieved') {
      recommended = hotelResponse.data ?? [];
    }
    else
    {
      if((hotelResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, hotelResponse.message??"");
      }
    }

    r_enabled = List.filled(recommended.length, false);

    setState(() {

    });
    getHolidayHotels();
  }

  Future<void> getHolidayHotels() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getDashboard,
      APIConstant.type: APIConstant.holiday,
    };
    HotelResponse hotelResponse = await APIService().getDashboardHotels(queryParameters);
    if (hotelResponse.status == 'Success' &&
        hotelResponse.message == 'Hotels Retrieved') {
      holiday = hotelResponse.data ?? [];
    }
    else
    {
      if((hotelResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, hotelResponse.message??"");
      }
    }

    h_enabled = List.filled(holiday.length, false);

    load = true;
    setState(() {

    });
  }

  Future<void> getDashboard() async {
    DashboardResponse dashboardResponse = await APIService().getDashboard();

    if (dashboardResponse.status == 'Success' && dashboardResponse.message == 'Dashboard Retrieved') {

      homeinfo = Provider.of<HomeData>(context, listen: false);

      homeinfo.updateMobile(dashboardResponse.user?.user?.cusMobile);
      homeinfo.updateCode(dashboardResponse.user?.user?.cusCc);
      homeinfo.updateName(dashboardResponse.user?.user?.cusName);

      sharedPreferences.setString("name", dashboardResponse.user?.user?.cusName??"Guest");
      sharedPreferences.setString("code", dashboardResponse.user?.user?.cusCc??"");
      sharedPreferences.setString("mobile", dashboardResponse.user?.user?.cusMobile??"");

      banners = dashboardResponse.banners ?? [];
      await setBanners();
      city = dashboardResponse.popular ?? [];
      banners = dashboardResponse.banners ?? [];
      collection = dashboardResponse.collection ?? [];
      recommended = dashboardResponse.recommended ?? [];
      holiday = dashboardResponse.holiday ?? [];

      await WriteCache.setBool(key: "key_dashboard", value: true);
      await WriteCache.setJson(key: "dashboard", value: dashboardResponse.toJson());
      List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
      keys.add("key_dashboard");
      keys.add("dashboard");
      await WriteCache.setListString(key: "keys", value: keys);
    }
    else
    {
      if((dashboardResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, dashboardResponse.message??"");
      }
    }

    c_enabled = List.filled(collection.length, false);
    r_enabled = List.filled(recommended.length, false);
    h_enabled = List.filled(holiday.length, false);

    load = true;
    setState(() {

    });
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
    if (wishlistResponse.status == 'Success') {
      hotel.hotel?.liked = wishlistResponse.data;
    }
    else
    {
      if((wishlistResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, wishlistResponse.message??"");
      }
    }
    // r_enabled[ind] = !r_enabled[ind];
    DeleteCache.deleteKey("key_h"+(hotel.hotel?.hId??"-1"));
    DeleteCache.deleteKey("key_wishlist");
    load = true;
    setState(() {

    });
    getDashboard();

    Toast.sendToast(context, wishlistResponse.message??"");
  }

  void openBecomePartnerForm() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return const BecomePartner();
        }
    );
  }

  Future<void> checkCache() async {
    CacheManagerUtils.conditionalCache(
        key: "key_dashboard",
        valueType: ValueType.BoolValue,
        actionIfNull: () async {
          load = false;
          setState(() {

          });

          getDashboard();
        },
        actionIfNotNull: () async {
          DashboardResponse dashboardResponse = DashboardResponse.fromJson(await ReadCache.getJson(key: "dashboard"));

          homeinfo = Provider.of<HomeData>(context, listen: false);

          homeinfo.updateMobile(dashboardResponse.user?.user?.cusMobile);
          homeinfo.updateCode(dashboardResponse.user?.user?.cusCc);
          homeinfo.updateName(dashboardResponse.user?.user?.cusName);

          banners = dashboardResponse.banners ?? [];
          await setBanners();
          city = dashboardResponse.popular ?? [];
          banners = dashboardResponse.banners ?? [];
          collection = dashboardResponse.collection ?? [];
          recommended = dashboardResponse.recommended ?? [];
          holiday = dashboardResponse.holiday ?? [];


          c_enabled = List.filled(collection.length, false);
          r_enabled = List.filled(recommended.length, false);
          h_enabled = List.filled(holiday.length, false);

          load = true;
          setState(() {

          });
        }
    );
  }
// _showPopupMenu(BuildContext con){
//   showMenu<String>(
//     context: context,
//     position: RelativeRect.fromLTRB(100, 150, 100, 100),      //position where you want to show the menu on screen
//     items:  List.generate(search_list.length, (index) {
//       return PopupMenuItem(
//         child: Container(
//           width: MySize.size50(con),
//           child: Text(search_list[index].search?.name??"")
//         ),
//       );
//     }),
//     elevation: 8.0,
//   ).then((value) {
//
//   });
// }
}
