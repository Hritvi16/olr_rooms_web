import 'package:flutter/material.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/CityInfo.dart';
import 'package:olr_rooms_web/model/CityResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllCities extends StatefulWidget {
  const AllCities({Key? key}) : super(key: key);

  @override
  State<AllCities> createState() => _AllCitiesState();
}

class _AllCitiesState extends State<AllCities> {
  bool load = false;
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  List<CityInfo> cityInfo = [];
  List<CityInfo> city = [];
  String chosen = "ALL";
  int hovert = -1;
  int hover = -1;

  @override
  void initState() {
    start();
    super.initState();
  }

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getAllCities();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "SUPPORT"),
        backgroundColor: MyColors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                    child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                        : MenuBar(sharedPreferences: sharedPreferences, name: "SUPPORT"),
                  ),
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: constraints.maxWidth < 600 ?
                      EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)) :
                      EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size4(context)),
                      child: getInitials(),
                    ),
                  ),
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: constraints.maxWidth < 600 ?
                      EdgeInsets.symmetric(horizontal: MySize.size3(context)) :
                      EdgeInsets.symmetric(vertical: 20, horizontal: MySize.size4(context)),
                      child: getCitiesCount(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                          child: constraints.maxWidth < 600 ? getCitiesM() : getCitiesW()
                        ),
                        Footer()
                      ],
                    ),
                  ),
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

  getInitials() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      color: MyColors.grey1,
      padding: EdgeInsets.only(left: 60, right: 60, top: 10),
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: Strings.alphabets.length,
        separatorBuilder: (BuildContext context, index){
          return SizedBox(width: 25,);
        },
        itemBuilder: (BuildContext context, index){
          return getAlphaDesign(index);
        },
      ),
    );
  }

  getAlphaDesign(int ind) {
    return SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap: () {
                  chosen = Strings.alphabets[ind];
                  sortCities(Strings.alphabets[ind]);
                },
                onHover: (value) {
                  print(value);
                  if(value) {
                    hovert = ind;
                  }
                  else {
                    hovert = -1;
                  }
                  setState(() {

                  });
                },
                mouseCursor: SystemMouseCursors.click,
                hoverColor: Colors.transparent,
                child: Text(
                  Strings.alphabets[ind],
                  style: TextStyle(
                      color: hovert==ind ? MyColors.colorPrimary : MyColors.black
                  ),
                ),
              ),
              if(chosen==Strings.alphabets[ind])
                Container(
                  height: 4,
                  width: 20,
                  decoration: BoxDecoration(
                      color: MyColors.colorPrimary
                  ),
                )
            ],
          ),
    );
  }

  getCitiesCount() {
    return Text(
      (chosen=='ALL' ? "All Cities (" : "Cities from $chosen (")+city.length.toString()+")",
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w500
      ),
    );
  }

  getCitiesW() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: MySize.sizeh2(context),
            mainAxisSpacing: MySize.sizeh2(context),
            mainAxisExtent: 20
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: city.length,
        itemBuilder: (BuildContext context, index){
          return getCityDesign(index);
        },
      ),
    );
  }

  getCitiesM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size7(context)),
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: city.length,
        separatorBuilder: (BuildContext context, index){
          return SizedBox(height: 20,);
        },
        itemBuilder: (BuildContext context, index){
          return getCityDesign(index);
        },
      ),
    );
  }

  getCityDesign(int ind) {
    return  InkWell(
      onTap: () {

      },
      onHover: (value) {
        print(value);
        if(value) {
          hover = ind;
        }
        else {
          hover = -1;
        }
        setState(() {

        });
      },
      mouseCursor: SystemMouseCursors.click,
      hoverColor: Colors.transparent,
      child: Text(
        city[ind].city?.cName??"",
        style: TextStyle(
            color: hover==ind ? MyColors.colorPrimary : MyColors.black
        ),
      ),
    );
  }


  void getAllCities() async {
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getAll};
    CityResponse cityResponse = await APIService().getAllCities(queryParameters);
    print(cityResponse.toJson());

    cityInfo = cityResponse.data ?? [];
    city = cityResponse.data ?? [];
    load = true;

    setState(() {

    });
  }

  void sortCities(String alphabet) {
    city = [];
    cityInfo.forEach((CityInfo cityInfo) {
      if((cityInfo.city?.cName??"").startsWith(alphabet)) {
        city.add(cityInfo);
      }
    });
    setState(() {

    });
  }
}
