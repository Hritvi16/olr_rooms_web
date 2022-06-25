import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/Amenities.dart';
import 'package:olr_rooms_web/model/AmenitiesResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Filters extends StatefulWidget {
  final double ss, es, ps, pe, grs, gre;
  final String sort;
  final bool payAtHotel;
  final List<String> tappeda;
  final List<int> tappeds;
  const Filters({Key? key, required this.ss, required this.es, required this.ps, required this.pe, required this.grs, required this.gre, required this.sort, required this.payAtHotel, required this.tappeda, required this.tappeds}) : super(key: key);

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  late SharedPreferences sharedPreferences;
  String filterData = "";

  String btnStatus = "";
  bool isInstructionView = true;
  bool isloading = true;


  List<String> filters = ['Sort By', 'Pay At Hotel', 'Price Range', 'Hotel Star', 'Guest Ratings', 'Amenities', 'Slots'];
  double ss = 0;
  double es = 0;

  double grs = 0;
  double gre = 0;

  double ps = 0;
  double pe = 1;

  String sort = "";
  bool payAtHotel = false;
  List<String> tappeda = [];
  List<int> tappeds = [];
  List<String> tappedc = [];
  List<int> tappedms = [];
  List<int> tappedbt = [];
  List<String> tappedg = [];
  List<String> tappedp = [];


  // List<Gotras> gotraList = new List<Gotras>();
  List<Amenities> amenities = [];
  List<String> profession = [];

  int start_age = 0;
  int end_age = 150;

  @override
  void initState() {
    print("hii");
    start();
    super.initState();
  }

  Future<void> start() async {
    btnStatus = filters[0];

    sort = widget.sort;
    payAtHotel = widget.payAtHotel;
    ss = widget.ss;
    es = widget.es;
    ps = widget.ps;
    pe = widget.pe;
    grs = widget.grs;
    gre = widget.gre;
    tappeda = widget.tappeda;
    tappeds = widget.tappeds;

    await getAllAmenities();
    // fetchPrice();
    // fetchBrands();
    // fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async
      {
        Navigator.pop(context, {"filter" : getFilters(), "sort_by" : getSortBy(), "sort" : sort, "payAtHotel" : payAtHotel, "ps" : ps,
          "pe" : pe, "ss" : ss, "es" : es, "grs" : grs, "gre" : gre, "tappeda" : tappeda, "tappeds" : tappeds
        });
        return true;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: MySize.sizeh10(context), horizontal: MySize.size10(context)),
        child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(MySize.sizeh1_5(context)),
            ),
            child: Scaffold(
              backgroundColor: MyColors.white,
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(MySize.sizeh7(context)),
                  child: AppBar(
                    leading: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: MyColors.black
                        ),
                      ),
                    ),
                    backgroundColor: MyColors.white,
                    shape: RoundedRectangleBorder( // <-- SEE HERE
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(MySize.sizeh1_5(context)),
                      ),
                    ),
                    title: Text(
                      "Filters",
                      style: TextStyle(
                        color: MyColors.black
                      ),
                    ),
                  )),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MySize.size2(context), vertical: MySize.sizeh2(context)),
                                child: ListView.separated(
                                  itemCount: filters.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return getFilterTextDesign(filters[index]);
                                  },
                                  separatorBuilder: (BuildContext context, index) {
                                    return SizedBox(
                                      height: MySize.sizeh2(context),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.symmetric(horizontal: MySize.size2(context), vertical: MySize.sizeh2(context)),
                                decoration: BoxDecoration(
                                  color: MyColors.white,
                                  border: Border(left: BorderSide(color: Colors.grey))
                                ),
                                child: btnStatus == "Sort By"
                                    ? ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: Strings.sortBy.length,
                                      separatorBuilder: (BuildContext context, index) {
                                        return SizedBox(
                                          height: MySize.sizeh2(context),
                                        );
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              if(sort==Strings.sortBy[index]) {
                                                sort = "";
                                              }
                                              else {
                                                sort = Strings.sortBy[index];
                                              }
                                              setState(() {
                                              });
                                            },
                                            child: Container(
                                              height: MySize.sizeh4(context),
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                Strings.sortBy[index],
                                                style: TextStyle(
                                                    color: sort == Strings.sortBy[index]
                                                        ? MyColors.colorPrimary
                                                        : MyColors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )

                                    : btnStatus == "Pay At Hotel"
                                    ? CheckboxListTile(
                                        value: payAtHotel,
                                        title: Text("Pay At Hotel"),
                                        onChanged: (value){
                                          payAtHotel = value!;
                                          setState(() {
                                          });
                                        },
                                      )
                                    : btnStatus == "Price Range"
                                    ? Column(
                                  children: [
                                    RangeSlider(
                                      values: RangeValues(ps, pe),
                                      max: 10000,
                                      labels: RangeLabels(
                                          ps.toString(),
                                          pe.toString()
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          // _currentRangeValues = values;
                                          ps = values.start.roundToDouble();
                                          pe = values.end.roundToDouble();
                                        });
                                        print(pe);
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MySize.size1_25(context)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ps.toInt().toString(),
                                          ),
                                          Text(
                                            pe.toInt().toString(),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ) :
                                btnStatus == "Hotel Star" ?
                                Column(
                                  children: [
                                    RangeSlider(
                                      values: RangeValues(ss, es),
                                      max: 5,
                                      divisions: 10,
                                      labels: RangeLabels(
                                          ss.toString(),
                                          es.toString()
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          // _currentRangeValues = values;
                                          ss = values.start;
                                          es = values.end;
                                        });
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MySize.size1_25(context)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "0",
                                          ),
                                          Text(
                                            "5",
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ) :
                                btnStatus == "Guest Ratings" ?
                                Column(
                                  children: [
                                    RangeSlider(
                                      values: RangeValues(grs, gre),
                                      max: 5,
                                      divisions: 10,
                                      labels: RangeLabels(
                                        grs.toString(),
                                        gre.toString()
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          // _currentRangeValues = values;
                                          grs = values.start;
                                          gre = values.end;
                                        });
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MySize.size1_25(context)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "0",
                                          ),
                                          Text(
                                            "5",
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ) :
                                btnStatus == "Amenities" ?
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: amenities.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return CheckboxListTile(
                                        value: tappeda.contains(amenities[index].amId??""),
                                        title: Text(amenities[index].amName??""),
                                        onChanged: (value){
                                          if (tappeda.contains(amenities[index].amId??"")) {
                                            this.setState(() {
                                              tappeda.remove(amenities[index].amId??"");
                                            });
                                          } else {
                                            this.setState(() {
                                              tappeda.add(amenities[index].amId??"");
                                            });
                                          }
                                        },
                                      );
                                    })
                                    :
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: Strings.slots.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return CheckboxListTile(
                                        value: tappeds.contains(index),
                                        title: Text(Strings.slots[index]+" Hours"),
                                        onChanged: (value){
                                          if (tappeds.contains(index)) {
                                            this.setState(() {
                                              tappeds.remove(index);
                                            });
                                          } else {
                                            this.setState(() {
                                              tappeds.add(index);
                                            });
                                          }
                                        },
                                      );
                                    }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
              bottomNavigationBar: Container(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            tappedc.clear();
                            tappedms.clear();
                            tappedbt.clear();
                            tappedg.clear();
                            tappedp.clear();
                            tappeds.clear();
                            start_age = 0;
                            end_age = 150;
                          });
                        },
                        child: Container(
                            height: 60,
                            color: Colors.black,
                            child: Center(
                                child: Text(
                                  "Clear",
                                  style: TextStyle(color: Colors.white),
                                ))),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            sendFilter();
                          },
                          child: Container(
                            color: MyColors.colorPrimary,
                            alignment: Alignment.center,
                            height: 60,
                            child: Text(
                              "Apply Filter",
                              style: TextStyle(
                                  color: MyColors.white,
                                  fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget getFilterTextDesign(String name) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              btnStatus = name;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MySize.sizeh4(context),
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(
                color: btnStatus == name ? MyColors.colorPrimary : MyColors.black,
              ),
            )
          ),
        ),
      ),
    );
  }


  void sendFilter() {
    Navigator.pop(context, {"filter" : getFilters(), "sort_by" : getSortBy(), "sort" : sort, "payAtHotel" : payAtHotel, "ps" : ps,
      "pe" : pe, "ss" : ss, "es" : es, "grs" : grs, "gre" : gre, "tappeda" : tappeda, "tappeds" : tappeds
    });
  }

  Future<void> getAllAmenities() async {
    AmenitiesResponse amenities = await APIService().getAllAmenities();
    print(amenities.toJson());
    setState(() {
      this.amenities = amenities.data ?? [];
    });
  }

  String getFilters() {
    String payAtHotel = this.payAtHotel ? getPayAtHotel() : "";
    String priceRange = ps>0 || pe>0 ? getPriceRange() : "";
    String hotelStar = ss>0 || es>0 ? getHotelStarRange() : "";
    String guestRatings = grs>0 || gre>0 ? getGuestRatingsRange() : "";
    String amenities = tappeda.isNotEmpty ? getAmenities() : "";
    String slots = tappeds.isNotEmpty ? getSlots() : "";
    return payAtHotel+priceRange+hotelStar+guestRatings+amenities+slots;
  }

  String getSortBy() {
    String sort_by = "";
    if(sort=="Recommended")
      sort_by = " ORDER BY hg.hg_city_recommended DESC";
    else if(sort=="Price: Low to High")
      sort_by = " ORDER BY cp.cp_base";
    else if(sort=="Price: High to Low")
      sort_by = " ORDER BY cp.cp_base DESC";
    else if(sort=="Guest Ratings: Low to High")
      sort_by = " ORDER BY h.h_rating";
    else if(sort=="Guest Ratings: High to Low")
      sort_by = " ORDER BY h.h_rating DESC";
    return sort_by;
  }

  String getPayAtHotel()
  {
    return " AND hg.hg_pay_at_hotel=1";
  }

  String getPriceRange()
  {
    return " AND cp.cp_base BETWEEN "+ps.toString()+" AND "+pe.toString();
  }

  String getHotelStarRange()
  {
    return " AND h.h_star BETWEEN "+ss.toString()+" AND "+es.toString();
  }

  String getGuestRatingsRange()
  {
    // return " AND (SELECT IFNULL(SUM(((bor.br_location+bor.br_food+bor.br_cleanliness+bor.br_facilities+bor.br_staff)/5.0)), 0) as sum "
    //     "FROM `booking_review` bor left join booking bo on bor.b_id = bo.b_id where bo.h_id = h.h_id) "
    //     "BETWEEN "+grs.toString()+" AND "+gre.toString();
    return " AND h.h_rating BETWEEN "+grs.toString()+" AND "+gre.toString();
  }

  String getAmenities() {
    String c = ' AND (ha.am_id IN (';
    for (int i = 0; i < tappeda.length; i++) {

      c += "'"+tappeda[i]+"',";
    }

    c = c.substring(0, c.lastIndexOf(','))+")"+" OR ca.am_id IN (";
    for (int i = 0; i < tappeda.length; i++) {

      c += "'"+tappeda[i]+"',";
    }
    return c.substring(0, c.lastIndexOf(','))+")"+")";
  }

  String getSlots() {
    String c = "";
    for (int i = 0; i < tappeds.length; i++) {

      c += " AND tp_"+Strings.slots[tappeds[i]]+" = 1";
    }
    return c;
  }

}
