import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:olr_rooms_web/BannerHotels.dart';
import 'package:olr_rooms_web/BecomePartner.dart';
import 'package:olr_rooms_web/Bookings.dart';
import 'package:olr_rooms_web/CitySearch.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/GlobalSearch.dart';
import 'package:olr_rooms_web/MyPopTemplate.dart';
import 'package:olr_rooms_web/Notifications.dart';
import 'package:olr_rooms_web/SearchList.dart';
import 'package:olr_rooms_web/Support.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
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
import 'package:olr_rooms_web/Wishlist.dart';
import 'package:olr_rooms_web/offers/Offers.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/profile/Profile.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'HomeData.dart';
import 'Login.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetailsW.dart';

import 'hotel/hotelDetails/HotelDetails.dart';
import 'strings/Strings.dart';

class Home extends StatefulWidget {
  // final bool cache;
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            height: 100,
            decoration: BoxDecoration(
                color: MyColors.white,
                border: Border(bottom: BorderSide(color: MyColors.grey10))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo/appbar_logo.png",
                  width: 100,
                  height: 100,
                  color: MyColors.colorPrimary,
                  fit: BoxFit.fill,
                ),
                Container(
                  height: 10,
                  width: 200,
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      autofocus: true,
                      cursorColor: MyColors.colorPrimary,
                      style: TextStyle(color: MyColors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: MyColors.white),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          fillColor: MyColors.white,
                          filled: true,
                          hintText: "Search for Hotel, City or Location",
                          hintStyle: TextStyle(
                              fontSize: 20
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                          )
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    suggestionsCallback: (pattern) async {
                      search_list = await GlobalSearch().search(pattern);
                      setState((){

                      });
                      return search_list;
                    },
                    itemBuilder: (context, SearchInfo suggestion) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: Text(
                          suggestion.search?.name??"",
                          style: TextStyle(
                              fontSize: 16
                          ),
                        ),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container(
                        height: 0,
                      );
                    },
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
                ),
                InkWell(
                  onTap: () => null,
                  onHover: (value){
                    print("value");
                    print(value);
                    hoverh = value;
                    setState(() {

                    });
                  },
                  child: Text(
                    "Home",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: hoverh ? MyColors.colorPrimary : MyColors.black,
                        decoration: hoverh ? TextDecoration.underline : TextDecoration.none
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if(sharedPreferences.getString("login_type")=="customer") {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => Bookings())).then((value) {

                        checkCache();
                      });
                    }
                    else{
                      Essential().loginPopUp(context);
                    }
                  },
                  onHover: (value){
                    print("value");
                    print(value);
                    hoverb = value;
                    setState(() {

                    });
                  },
                  child: Text(
                    "Booking",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: hoverb ? MyColors.colorPrimary : MyColors.black,
                        decoration: hoverb ? TextDecoration.underline : TextDecoration.none
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Offers()));
                  },
                  onHover: (value){
                    print("value");
                    print(value);
                    hovero = value;
                    setState(() {

                    });
                  },
                  child: Text(
                    "Offer",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: hovero ? MyColors.colorPrimary : MyColors.black,
                        decoration: hovero ? TextDecoration.underline : TextDecoration.none
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if(sharedPreferences.getString("login_type")=="customer") {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => Support())).then((value) {

                        checkCache();
                      });
                    }
                    else{
                      Essential().loginPopUp(context);
                    }
                  },
                  onHover: (value){
                    print("value");
                    print(value);
                    hovers = value;
                    setState(() {

                    });
                  },
                  child: Text(
                    "Support",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: hovers ? MyColors.colorPrimary : MyColors.black,
                        decoration: hovers ? TextDecoration.underline : TextDecoration.none
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => null,
                  onHover: (value){
                    print("value");
                    print(value);
                    hoverm = value;
                    setState(() {

                    });
                  },
                  child: PopupMenuButton(
                    tooltip: "Open Menu",
                    position: PopupMenuPosition.under,
                    child: Text(
                      "More",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: hoverm ? MyColors.colorPrimary : MyColors.black,
                          decoration: hoverm ? TextDecoration.underline : TextDecoration.none
                      ),
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

                                    checkCache();
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
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //         context, MaterialPageRoute(
                    //         builder: (context) => Notifications()));
                    //   },
                    //   child: Icon(
                    //     Icons.notifications_active_outlined,
                    //     size: MySize.size4(context),
                    //   ),
                    // ),
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
                )
                // GestureDetector(
                //     onTap: () {
                //       Navigator.push(
                //           context, MaterialPageRoute(
                //           builder: (context) => Notifications()));
                //     },
                //     child: Row(
                //       children: [
                //         Text(
                //           "Logout",
                //           style: TextStyle(
                //               fontSize: 20
                //           ),
                //         ),
                //         Icon(
                //           Icons.power_settings_new,
                //           size: MySize.size4(context),
                //         ),
                //       ],
                //     )
                // ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await getDashboard();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListView(
              children: [
                getCitiesView(),
                Divider(thickness: 1,),
                getBannerView(),
                Text(
                  "4 Simple Steps",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                getStepsView(),
                Text(
                  "Our Collections",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                getHotelsView(collection, "Collection"),
                Text(
                  "Recommended For You",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                getHotelsView(recommended, "Recommended"),
                Text(
                  "BEST To Enjoy Holidays",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                getHotelsView(holiday, "Holiday"),
              ],
            ),
          ),
        )
    ) : Center(
      child: CircularProgressIndicator(),
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
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) =>
        //         SearchList(id: city[ind]?.cId ?? "", type: "city",)));
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                CitySearch(search: city[ind].cName??''))).then((value) {

          checkCache();
        });
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: ((60 * 0.3) + MediaQuery.of(context).size.width * 0.1)/5,
                // backgroundImage: AssetImage(image),
                backgroundImage: NetworkImage(
                    Environment.imageUrl + (city[ind].pcImage ?? ""))
            ),
            SizedBox(
              height: 60 * 0.06,
            ),
            Text(city[ind].cName ?? "", textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: ((60 * 0.01) + MediaQuery.of(context).size.width * 0.1)/10
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
        itemCount: city.length,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(
            width: 50,
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getPlaceDesign(index);
        },
      ),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 60,
    );
  }

  getHotelsView(List<HotelInfo> hotels, String type) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: hotels.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10);
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HotelDetails(h_id: hotel.hotel?.hId??"",))).then((value) {

          checkCache();
        });
      },
      child: Container(
        width: 150,
        // decoration: const BoxDecoration(
        //   color: Colors.white,
        // borderRadius: BorderRadius.all(Radius.circular(5)),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey,
        //     offset: Offset(0.0, 1.0), //(x,y)
        //     blurRadius: 1.0,
        //   ),
        // ],
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (hotel.hotel?.hImageCount??"0")=="0" ? Container(
                    height: 400 * 0.65,
                    width: 150,
                    decoration: BoxDecoration(
                      color: MyColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                    ),
                  )
                      : Image.network(
                    Environment.imageUrl + (hotel.images?[0].hiImage??""),
                    fit: BoxFit.fill,
                    height: 400 * 0.65,
                    width: 150,
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
              padding: EdgeInsets.symmetric(vertical: 400 * 0.02),
              alignment: AlignmentDirectional.topStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.hotel?.hName??"",
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                      fontSize: ((400 * 0.055) + (150* 0.055))/2,
                      fontFamily: 'Roboto',
                      color: new Color(0xFF212121),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 400 * 0.01,
                  ),
                  Text(
                    (hotel.area?.arName??"") + ", " + (hotel.city?.cName??""),
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                      fontSize: ((400 * 0.055) + (150* 0.055))/2,
                      fontFamily: 'Roboto',
                      color: MyColors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(
                    height: 400 * 0.02,
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
                        fontSize: ((400 * 0.055) + (150* 0.055))/2,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: APIConstant.symbol + base.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.lineThrough,
                              color: MyColors.black,
                              overflow: TextOverflow.ellipsis,
                              fontSize: ((400 * 0.05) + (150* 0.05))/2,
                            )
                        ),
                        TextSpan(text: "  " + discount.floor().toString() +
                            "% OFF",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: MyColors.orange,
                              overflow: TextOverflow.ellipsis,
                              fontSize: ((400 * 0.045) + (150* 0.045))/2,
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
    );
  }

  getStepsView() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 80,
      child: Row(
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
            width: 50,
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
            width: 50,
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
            width: 50,
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
        GestureDetector(
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
                    Environment.imageUrl + (banners[i].banner?.banImage ?? ""),
                    fit: BoxFit.fill,
                    width: 200),
                // child: Image.asset(
                //   banners[i].banImage,
                //   fit: BoxFit.fill,
                // ),
              )
          ),
        ),
      );
    }
  }

  getBannerView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
          options: CarouselOptions(
              enlargeCenterPage: true,
              height: 200,
              viewportFraction: 0.4,
              initialPage: 0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3)
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return BecomePartner();
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
