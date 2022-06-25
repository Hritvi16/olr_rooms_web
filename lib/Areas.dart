import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/SearchList.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/Area.dart';
import 'package:olr_rooms_web/model/AreaResponse.dart';
import 'package:olr_rooms_web/model/CityInfo.dart';
import 'package:olr_rooms_web/model/CityResponse.dart';

class Areas extends StatefulWidget {
  final String city;
  const Areas({Key? key, required this.city}) : super(key: key);

  @override
  State<Areas> createState() => _AreasState();
}

class _AreasState extends State<Areas> {
  List<Area> areas = [];
  String city = "";

  TextEditingController search = new TextEditingController();

  @override
  void initState() {
    city = widget.city;
    search.text = widget.city;
    getAreasByCity();
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
            // if(value.length>2) {
            //   // getAreasByName();
            // }
            // else {
            //   areas = [];
            //
            //   setState(() {
            //
            //   });
            // }
          },
          controller: search,
          readOnly: true,
          enabled: false,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400
          ),
          decoration :InputDecoration(
              contentPadding: const EdgeInsets.all(8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: "Search Area",
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
      body: RefreshIndicator(
        onRefresh: () async {
          await getAreasByCity();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: ListView.builder(
            itemCount: areas.length,
            itemBuilder: (BuildContext context, index) {
              return getAreaDesign(index);
            }
          ),
        ),
      ),
    );
  }

  getAreaDesign(int ind) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  SearchList(id: areas[ind].arId??"", name: areas[ind].arName??"", type: "area",)));
        },
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            (areas[ind].arName??""),
            style: TextStyle(
              fontSize: 16
            ),
          )
        ),
      ),
    );
  }

  // void getAreasByName() async {
  //   Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByCity, "search" : search.text};
  //   AreaResponse areaResponse = await APIService().getAreasByName(queryParameters);
  //   print(areaResponse.toJson());
  //   areas = areaResponse.data ?? [];
  //
  //   setState(() {
  //
  //   });
  // }


  Future<void> getAreasByCity() async {
    Map<String,String> queryParameters = {APIConstant.act : APIConstant.getByCity, "c_name" : city};
    AreaResponse areaResponse = await APIService().getAreasByCity(queryParameters);
    print(areaResponse.toJson());
    areas = areaResponse.data ?? [];

    setState(() {

    });
  }

}
