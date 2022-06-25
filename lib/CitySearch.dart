import 'package:flutter/material.dart';
import 'package:olr_rooms_web/SearchList.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/CitySearchResponse.dart';
import 'package:olr_rooms_web/model/PreviousSearchDetails.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitySearch extends StatefulWidget {
  final String search;
  const CitySearch({Key? key, required this.search}) : super(key: key);

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  List<PreviousSearchDetails> previous = [];
  List<SearchInfo> popular = [];

  bool load = false;
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  String search = "";

  @override
  void initState() {
    search = widget.search;
    citySearch();
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
              return Column(
                  children: [
                    Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: constraints.maxWidth < 600 ? MenuBarM(
                          sharedPreferences: sharedPreferences,
                          scaffoldkey: scaffoldkey)
                          : MenuBar(
                          sharedPreferences: sharedPreferences, name: "SEARCHLIST"),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                          padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                          child: getBody(constraints.maxWidth)
                          ),
                          Footer()
                        ],
                      ),
                    ),
                  ],
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
    return SingleChildScrollView(
      child: Padding(
        padding: width < 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context))
            : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
        child: Column(
          children: [
            if(previous.length>0)
              getPreviousSearch(width),
            SizedBox(
              height: MySize.sizeh5(context),
            ),
            if(popular.length>0)
              getPopularSearch(width)
          ],
        ),
      ),
    );
  }

  Future<void> citySearch() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {

    });
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByCity,
      "search": search,
      "login_type": sharedPreferences?.getString("login_type")??"guest",
    };
    CitySearchResponse citySearchResponse = await APIService().citySearch(data);
    print("citySearchResponse.toJson()");
    print(data);
    print(citySearchResponse.toJson());

    popular.add(
      SearchInfo.fromJson(
        {
          "search" : {
            "id" : "-1",
            "name" : "View all in "+search
          },
          "type" : "allcity"
        }
      )
    );
    // popular.add(SearchInfo(search: SearchDetails(id: "-1", name: "View all in "+(search??"")), type: "allcity"));
    print(popular[0].search?.toJson());
    if(citySearchResponse.status=="Success" && citySearchResponse.message=="Searched Successful") {
      previous.addAll(citySearchResponse.data?.previousSearch ?? []);
      popular.addAll(citySearchResponse.data?.popularAreas ?? []);
    }
    else {
      previous = [];
      popular.addAll([]);
      Toast.sendToast(context, citySearchResponse.message??"");
    }

    print("hello");
    print(popular[0].toJson());
    load = true;
    setState(() {

    });
  }

  getPreviousSearch(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
          child: Text(
            "Continue your search",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: width < 600 ? MySize.font12_5(context) : MySize.font9(context)
            ),
          ),
        ),
        GridView.builder(
          itemCount: previous.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: MySize.size2(context),
              mainAxisSpacing: MySize.sizeh2(context),
              mainAxisExtent: 40
          ),
          itemBuilder: (BuildContext context, index) {
            return getPreviousSearchDesign(previous[index], width);
          },
        ),
      ],
    );
  }

  getPreviousSearchDesign(PreviousSearchDetails previousSearchDetails, double width) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  CitySearch(search: previousSearchDetails.shSearch??'')));
        },
        child: ListTile(
          mouseCursor: SystemMouseCursors.click,
          leading: Icon(
            Icons.more_time_outlined
          ),
          title: Text(
            previousSearchDetails.shSearch??"",
            style: TextStyle(
              fontSize: width < 600 ? MySize.font11_5(context) : MySize.font8(context)
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,

          ),
        ),
    );
  }

  getPopularSearch(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
          child: Text(
            "Locations in "+search,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: width < 600 ? MySize.font12_5(context) : MySize.font9(context)
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
          child: GridView.builder(
            itemCount: popular.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: MySize.size2(context),
                mainAxisSpacing: MySize.sizeh2(context),
                mainAxisExtent: 40
            ),
            itemBuilder: (BuildContext context, index) {
              return getPopularSearchDesign(popular[index], index, width);
            },
          ),
        )
      ],
    );
  }


  getPopularSearchDesign(SearchInfo searchInfo, int ind, double width) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(searchInfo.type=='hotel') {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    HotelDetails(h_id: searchInfo.search?.id ?? "",)));
          }
          else {
            String name = (searchInfo.search?.id ?? "")=="-1" ? search : searchInfo.search?.name ?? "";
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    SearchList(id: searchInfo.search?.id ?? "", name: name, type: searchInfo.type??"",)));
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: MyColors.grey),
              borderRadius: BorderRadius.circular(MySize.sizeh075(context))
          ),
          child: Text(
            searchInfo.search?.name??"",
            style: TextStyle(
                fontSize: width < 600 ? MySize.font11_5(context) : MySize.font8(context)
            ),
          ),
        ),
      ),
    );
  }

  getSearchDesign(SearchInfo searchInfo) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(searchInfo.type=='hotel') {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    HotelDetails(h_id: searchInfo.search?.id ?? "",)));
          }
          else {
            String name = (searchInfo.search?.id ?? "")=="-1" ? search : searchInfo.search?.name ?? "";
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    SearchList(id: searchInfo.search?.id ?? "", name: name, type: searchInfo.type??"",)));
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            searchInfo.search?.name??"",
            style: TextStyle(
                fontSize: 22
            ),
          ),
        ),
      ),
    );
  }
}
