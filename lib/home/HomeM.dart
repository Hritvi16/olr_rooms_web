import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/AllCities.dart';
import 'package:olr_rooms_web/BannerHotels.dart';
import 'package:olr_rooms_web/BecomePartner.dart';
import 'package:olr_rooms_web/CitySearch.dart';
import 'package:olr_rooms_web/LoginPopUp.dart';
import 'package:olr_rooms_web/MyPopTemplate.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
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
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../HomeData.dart';
import '../Login.dart';

class HomeM extends StatefulWidget {
  // final bool cache;
  const HomeM({Key? key}) : super(key: key);

  @override
  State<HomeM> createState() => _HomeMState();
}

class _HomeMState extends State<HomeM> {

  late SharedPreferences sharedPreferences;

  TextEditingController searchController = TextEditingController();
  List<Widget> slideShow = [];

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
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "HOME"),
        body: Column(
          children: [
            MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(top: MySize.sizeh1(context)),
                      child: ListView(
                        children: [
                          getCitiesView(),
                          getBannerView(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            child: Text(
                              "4 Simple Steps",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MySize.font13(context),
                              ),
                            ),
                          ),
                          getStepsView(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            child: Text(
                              "Our Collections",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MySize.font13(context),
                              ),
                            ),
                          ),
                          getHotelsView(collection, "Collection"),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            child: Text(
                              "Recommended For You",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MySize.font13(context),
                              ),
                            ),
                          ),
                          getHotelsView(recommended, "Recommended"),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                            child: Text(
                              "BEST To Enjoy Holidays",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MySize.font13(context),
                              ),
                            ),
                          ),
                          getHotelsView(holiday, "Holiday"),
                          Footer()
                        ],
                      ),
                    ),
            ),
          ],
        ),
    ) : const Center(
      child: const CircularProgressIndicator(),
    );
  }

  void logoutTask() {
    confirmLogout();

  }

  void confirmLogout() {
    BuildContext dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 10, top: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new Text("Are you sure you want to logout?",
                  style: const TextStyle(
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
                          logout();
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
            builder: (context) => const Login()),
            (Route<dynamic> route) => false
    );
  }

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();

    homeinfo = Provider.of<HomeData>(context, listen: false);

    homeinfo.updateMobile(sharedPreferences.getString("mobile") ?? "");
    homeinfo.updateCode(sharedPreferences.getString("code") ?? "");
    homeinfo.updateName(sharedPreferences.getString("name") ?? "");

      if(!(sharedPreferences!.getBool("pop")??true)) {
        await getPopBanner();
      }
      checkCache();

    // await getUserInfo();
    // await getPopularCities();
    // await getBanners();
    // getOurCollection();

    setState(() {

    });
  }

  showPopUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MyPopTemplate(banner: popBanner.pbImage??"");
      },
    ).then((value) {
      sharedPreferences!.setBool("pop", true);
    });
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
        child: Container(
          height: 50,
          child: ind!=city.length ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 30,
                  // backgroundImage: AssetImage(image),
                  backgroundImage: NetworkImage(
                      Environment.imageUrl + (city[ind].pcImage ?? ""))
              ),
              const SizedBox(
                height: 10,
              ),
              Text(city[ind].cName ?? "", textAlign: TextAlign.center,)
            ],
          ) :
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               CircleAvatar(
                  backgroundColor: MyColors.grey1,
                  radius: 30,
                  child: const Icon(
                      Icons.location_city
                  ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text("All Cities", textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }

  getCitiesView() {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: city.length+1,
        itemExtent: 90,
        itemBuilder: (BuildContext context, index) {
          return getPlaceDesign(index);
        },
      ),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 100,
    );
  }

  getHotelsView(List<HotelInfo> hotels, String type) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      margin: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size3(context)),
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
          width: MySize.size35(context),
          margin: EdgeInsets.only(bottom: MySize.sizeh05(context), left: MySize.size05(context), right: MySize.size05(context)),
          decoration:  BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh075(context))),
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                offset: const Offset(0.0, 1.0), //(x,y)
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
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(MySize.sizeh075(context)),
                        topRight: Radius.circular(MySize.sizeh075(context))),
                    child: (hotel.hotel?.hImageCount??"0")=="0" ? Container(
                      height: 200 * 0.5,
                      width: MySize.size35(context),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                      ),
                    )
                        : Image.network(
                      Environment.imageUrl + (hotel.images?[0].hiImage??""),
                      fit: BoxFit.fill,
                      height: 200 * 0.5,
                      width: MySize.size35(context),
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
                            loginPopUp();
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
                padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotel?.hName??"",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: MySize.font11(context),
                        fontFamily: 'Roboto',
                        color: const Color(0xFF212121),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: MySize.font11(context),
                        fontFamily: 'Roboto',
                        color: MyColors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(
                      height: 20,
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
                          fontSize: MySize.font11(context),
                        ),
                        children: <TextSpan>[
                          TextSpan(text: APIConstant.symbol + base.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.lineThrough,
                                  color: MyColors.black,
                                  overflow: TextOverflow.ellipsis,
                                fontSize: MySize.font10_75(context),
                              )
                          ),
                          TextSpan(text: "  " + discount.floor().toString() +
                              "% OFF",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.orange,
                                  overflow: TextOverflow.ellipsis,
                                fontSize: MySize.font10_25(context),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MySize.sizeh3(context), left: MySize.size3(context), right: MySize.size3(context)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MySize.sizeh1(context)),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(right: MySize.size1(context)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.sizeh055(context)),
                      child: Image.asset(
                        "assets/steps/step1.jpg",
                        fit: BoxFit.fill,
                        // height: size,
                        // width: size,
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: MySize.size1(context)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.size055(context)),
                      child: Image.asset(
                        "assets/steps/step2.jpg",
                        fit: BoxFit.fill,
                        // height: size,
                        // width: size,
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(bottom: MySize.sizeh1(context)),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding:  EdgeInsets.only(right: MySize.size1(context)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.size055(context)),
                      child: Image.asset(
                        "assets/steps/step3.jpg",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
                Flexible(
                  child: Padding(
                    padding:  EdgeInsets.only(left: MySize.size1(context)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(MySize.size055(context)),
                      child: Image.asset(
                        "assets/steps/step4.jpg",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
              ],
            ),
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

  getPopularCities() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getPopular
    };
    PopularCityResponse popularCityResponse = await APIService()
        .getPopularCities(queryParameters);

    if (popularCityResponse.status == 'Success' && popularCityResponse.message == 'Cities Retrieved')
      city = popularCityResponse.data ?? [];
    else
    {
      if((popularCityResponse.message??"")=="Invalid Token") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const Login()),
                (Route<dynamic> route) => false);
      }
      else {
        Toast.sendToast(context, popularCityResponse.message??"");
      }
    }
    setState(() {

    });
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
                      HotelDetails(h_id: banners[i].hotel![0] ?? "",))).then((value) {

                    checkCache();
                  });
                }
              }
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.vertical(top: const Radius.circular(25.0)),
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
}
