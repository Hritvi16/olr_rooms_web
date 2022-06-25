import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/CityInfo.dart';
import 'package:olr_rooms_web/model/CityResponse.dart';

class SearchCity extends StatefulWidget {
  final String city;
  const SearchCity({Key? key, required this.city}) : super(key: key);

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  List<CityInfo> cityInfo = [];

  TextEditingController search = new TextEditingController();

  @override
  void initState() {
    search.text = widget.city;
    getCitiesByName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: TextFormField(
          onChanged: (value)
          {
            if(value.length>2) {
              getCitiesByName();
            }
            else {
              cityInfo = [];

              setState(() {

              });
            }
          },
          controller: search,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400
          ),
          decoration :InputDecoration(
              contentPadding: const EdgeInsets.all(8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: "Your City of Residence",
              hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300
              ),
              prefixIcon: Icon(
                Icons.location_city,
                size: 18,
                color: MyColors.black,
              ),
          ),
        ),
        centerTitle: true,
        backgroundColor: MyColors.white,
        titleTextStyle: TextStyle(
            color: MyColors.black,
            fontSize: 20
        ),
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: MyColors.black,)
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: ListView.builder(
          itemCount: cityInfo.length,
          itemBuilder: (BuildContext context, index) {
            return getCityDesign(index);
          }
        ),
      ),
    );
  }

  getCityDesign(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context, {"c_id" : cityInfo[ind].city?.cId, "c_name" : cityInfo[ind].city?.cName});
        },
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            (cityInfo[ind].city?.cName??"")+", "+(cityInfo[ind].state?.sName??"")+", "+(cityInfo[ind].country?.coName??""),
            style: TextStyle(
              fontSize: 16
            ),
          )
        ),
      ),
    );
  }

  void getCitiesByName() async {
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByName, "search" : search.text};
    CityResponse cityResponse = await APIService().getCitiesByName(queryParameters);
    print(cityResponse.toJson());
    cityInfo = cityResponse.data ?? [];

    setState(() {

    });
  }

}
