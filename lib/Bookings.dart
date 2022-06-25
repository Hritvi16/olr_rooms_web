import 'dart:convert';

import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/Invoice.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/bookingDetails/BookedDetails.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/BookingInfo.dart';
import 'package:olr_rooms_web/model/BookingResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'header/header.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  List<BookingInfo> bookings = [];
  
  bool load = false;
  String message = "";
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "BOOKING"),
      backgroundColor: MyColors.white,
      body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                  children: [
                    Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                          : MenuBar(sharedPreferences: sharedPreferences, name: "BOOKING"),
                    ),
                    Padding(
                      padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                      child: Padding(
                        padding: constraints.maxWidth < 600 ?
                        EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
                            : EdgeInsets.symmetric(horizontal: MySize.size5(context), vertical: MySize.sizeh1(context)),
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: MySize.size2(context)),
                                    width: MySize.size5(context),
                                    height: MySize.sizeh3(context),
                                    color: MyColors.green500,
                                  ),
                                  Text(
                                    "Booked",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context),
                                        color: MyColors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: MySize.size2(context)),
                                    width: MySize.size5(context),
                                    height: MySize.sizeh3(context),
                                    color: MyColors.blue,
                                  ),
                                  Text(
                                    "Checked In",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context),
                                        color: MyColors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: MySize.size2(context)),
                                    width: MySize.size5(context),
                                    height: MySize.sizeh3(context),
                                    color: MyColors.colorPrimary,
                                  ),
                                  Text(
                                    "Checked Out",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context),
                                        color: MyColors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: MySize.size2(context)),
                                    width: MySize.size5(context),
                                    height: MySize.sizeh3(context),
                                    color: MyColors.yellow800,
                                  ),
                                  Text(
                                    "Cancelled",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context),
                                        color: MyColors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: MySize.size2(context)),
                                    width: MySize.size5(context),
                                    height: MySize.sizeh3(context),
                                    color: MyColors.red,
                                  ),
                                  Text(
                                    "Expired",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context),
                                        color: MyColors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                        child: bookings.isNotEmpty ? constraints.maxWidth < 600 ? getBookingsM() : getBookingsW()
                            :
                        Center(
                          child: Text(message),
                        ),
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
      )
    );
  }

  getBookingsW() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: MySize.size3(context),
            mainAxisSpacing: MySize.sizeh4(context),
            mainAxisExtent: 220
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: bookings.length,
        itemBuilder: (BuildContext context, index){
          return getBookingDesignW(index);
        },
      ),
    );
  }

  getBookingsM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: bookings.length,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: MySize.sizeh3(context));
        },
        itemBuilder: (BuildContext context, index) {
          return getBookingDesignM(index);
          // return SizedBox(height: MySize.sizeh2(context));
        },
      ),
    );
  }

  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    checkCache();
  }
  void checkCache() {
    CacheManagerUtils.conditionalCache(
        key: "key_booking",
        valueType: ValueType.BoolValue,
        actionIfNull: () async {
          print("helllllll");
          load = false;
          setState(() {

          });
          await getMyBookings();
        },
        actionIfNotNull: () async {
          print("helliiuu");
          print(await ReadCache.getJson(key: "booking"));
          BookingResponse bookingResponse = BookingResponse.fromJson(await ReadCache.getJson(key: "booking"));

          bookings = bookingResponse.data ?? [];
          message = bookingResponse.message??"";

          load = true;
          setState(() {

          });
        }
    );
  }

  getMyBookings() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID
    };
    BookingResponse bookingResponse = await APIService().getMyBookings(queryParameters);

    if(bookingResponse.status=="Success" && bookingResponse.message=="Bookings Retrieved") {
      bookings = bookingResponse.data ?? [];
    }
    else {
      bookings = [];
    }

    message = bookingResponse.message??"";
    print(message);

    await WriteCache.setBool(key: "key_booking", value: true);
    await WriteCache.setJson(key: "booking", value: bookingResponse.toJson());
    List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
    keys.add("key_booking");
    keys.add("booking");
    await WriteCache.setListString(key: "keys", value: keys);

    load = true;

    setState(() {

    });
  }

  Widget getBookingDesignW(int index) {
    print(bookings[index].booking?.brStart??"");
    print(bookings[index].booking?.toJson());
    print(index);
    print("bookings[index].booking?.brStart");
    DateTime start = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(bookings[index].booking?.brStart??"");
    DateTime end = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(bookings[index].booking?.brEnd??"");
    String sd = DateFormat("yyyy-MM-dd").format(start);
    String st = DateFormat("hh:mm a").format(start);
    String ed = DateFormat("yyyy-MM-dd").format(end);
    String et = DateFormat("hh:mm a").format(end);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => BookedDetails(
                id: bookings[index].booking?.bId??""
              )
            )
          ).then((value) => {
            if(value!=null) {
              load = false,
              setState(() {

              }),
              getMyBookings()
            }
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Row(
            children: [
               Flexible(
                 flex: 21,
                 fit: FlexFit.tight,
                 child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal :MySize.size075(context), vertical :MySize.sizeh075(context)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "BOOKING ID: "+(bookings[index].booking?.bNo??""),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MySize.font7(context)
                                        ),
                                      ),
                                      SizedBox(
                                        height: MySize.sizeh065(context),
                                      ),
                                      Text(
                                        "BOOKING TIME: "+(bookings[index].booking?.bDate??""),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MySize.font7(context)
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Essential().call("tel://"+(bookings[index].booking?.hgHelplineCustomer??""));
                                          },
                                          child: Icon(
                                            Icons.call,
                                            size: MySize.sizeh3(context),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MySize.size1(context),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            String text = 'http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=DOWNLOAD';
                                            Essential().link(Uri.encodeFull("https://wa.me/?text="+text));
                                          },
                                          child: Icon(
                                            Icons.whatsapp,
                                            size: MySize.sizeh3(context),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: MyColors.black))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(right: BorderSide(color: MyColors.black))
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            bookings[index].images?.length==0 ? Container(
                                                height: MySize.sizeh10(context),
                                                width: MySize.size10(context),
                                                child: Icon(
                                                  Icons.image_not_supported_outlined,
                                                ),
                                              )
                                                  : Image.network(
                                                Environment.imageUrl + (bookings[index].images?[0].hiImage??""),
                                                fit: BoxFit.fill,
                                                height: 100,
                                                width: MediaQuery.of(context).size.width,
                                              ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(MySize.size1(context),MySize.sizeh05(context),MySize.size1(context),MySize.sizeh05(context)),
                                              child: Text(
                                                bookings[index].booking?.hName??"" ,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: MySize.font7_5(context)
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(MySize.size1(context),MySize.sizeh05(context),MySize.size1(context),MySize.sizeh05(context)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        Essential().map(
                                                            double.parse(bookings[index].booking?.hgLat??"0"),
                                                            double.parse(bookings[index].booking?.hgLong??"0"),
                                                            bookings[index].booking?.hName??""
                                                        );
                                                      },
                                                      child: Icon(Icons.location_on_outlined,
                                                        color: MyColors.grey60,
                                                        size: MySize.sizeh2_5(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Text("Map",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w300,
                                                        color: MyColors.grey60,
                                                        fontSize: MySize.font7_5(context)
                                                      // fontSize: MySize.font7(context)
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 7,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh01(context)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Date:   " + sd + " - " + ed,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: MySize.font7(context)
                                              ),
                                            ),
                                            Text(
                                              "Time:   " + st + " - " + et,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: MySize.font7(context)
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  text: "Total Amount:  ",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: MySize.font7(context),
                                                      color: MyColors.black
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: APIConstant.symbol+(bookings[index].booking?.billTotal??""),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    )
                                                  ]
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Paid:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font7(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: APIConstant.symbol+(bookings[index].booking?.bDeposit??""),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Due:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font7(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: APIConstant.symbol+(bookings[index].booking?.due??""),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Total Rooms:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font7(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: bookings[index].booking?.totalRooms??"",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Total Guests:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font7(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: bookings[index].booking?.brAdult??"",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "(A)",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        if((bookings[index].booking?.brChild??"")!="0")
                                                          TextSpan(
                                                            text: bookings[index].booking?.brChild??"",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        if((bookings[index].booking?.brChild??"")!="0")
                                                          TextSpan(
                                                            text: "(C)",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                      ]
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:() {
                                                      Essential().link('http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=VIEW');

                                                      // Navigator.push(
                                                      // context, MaterialPageRoute(builder: (context) => Invoice(b_id: bookings[index].booking?.bId??"", action: "VIEW",)));
                                                    },
                                                    child: Icon(
                                                      Icons.picture_as_pdf_outlined,
                                                      size: MySize.sizeh3(context),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: MySize.size075(context),),
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:() {
                                                      Essential().link('http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=DOWNLOAD');
                                                      // Navigator.push(
                                                      //     context, MaterialPageRoute(builder: (context) => Invoice(b_id: bookings[index].booking?.bId??"", action: "DOWNLOAD",)));
                                                    },
                                                    child: Icon(
                                                      Icons.file_copy,
                                                      size: MySize.sizeh3(context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
               ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  decoration: BoxDecoration(
                    color: bookings[index].booking?.bStatus=="BOOKED" ? MyColors.green500 :
                    bookings[index].booking?.bStatus=="CHECKED IN" ? MyColors.blue :
                    bookings[index].booking?.bStatus=="CHECKED OUT" ? MyColors.colorPrimary :
                    bookings[index].booking?.bStatus=="CANCELLED" ? MyColors.yellow800 : MyColors.red,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(MySize.sizeh1(context)), bottomRight: Radius.circular(MySize.sizeh1(context)))
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getBookingDesignM(int index) {
    print(bookings[index].booking?.brStart??"");
    print(bookings[index].booking?.toJson());
    print(index);
    print("bookings[index].booking?.brStart");
    DateTime start = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(bookings[index].booking?.brStart??"");
    DateTime end = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(bookings[index].booking?.brEnd??"");
    String sd = DateFormat("yyyy-MM-dd").format(start);
    String st = DateFormat("hh:mm a").format(start);
    String ed = DateFormat("yyyy-MM-dd").format(end);
    String et = DateFormat("hh:mm a").format(end);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => BookedDetails(
                id: bookings[index].booking?.bId??""
              )
            )
          ).then((value) => {
            if(value!=null) {
              load = false,
              setState(() {

              }),
              getMyBookings()
            }
          });
        },
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh1(context))),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Row(
            children: [
               Flexible(
                 flex: 21,
                 fit: FlexFit.tight,
                 child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal :MySize.size075(context), vertical :MySize.sizeh075(context)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "BOOKING ID: "+(bookings[index].booking?.bNo??""),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MySize.font7_5(context)
                                        ),
                                      ),
                                      SizedBox(
                                        height: MySize.sizeh05(context),
                                      ),
                                      Text(
                                        "BOOKING TIME: "+(bookings[index].booking?.bDate??""),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MySize.font7_5(context)
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Essential().call("tel://"+(bookings[index].booking?.hgHelplineCustomer??""));
                                          },
                                          child: Icon(
                                            Icons.call,
                                            size: MySize.sizeh3(context),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MySize.size1_5(context),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            String text = 'http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=DOWNLOAD';
                                            Essential().link(Uri.encodeFull("https://wa.me/?text="+text));
                                          },
                                          child: Icon(
                                            Icons.whatsapp,
                                            size: MySize.sizeh3(context),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: MyColors.black))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(right: BorderSide(color: MyColors.black))
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            bookings[index].images?.length==0 ? Container(
                                                height: MySize.sizeh10(context),
                                                width: MySize.size10(context),
                                                child: Icon(
                                                  Icons.image_not_supported_outlined,
                                                ),
                                              )
                                                  : Image.network(
                                                Environment.imageUrl + (bookings[index].images?[0].hiImage??""),
                                                fit: BoxFit.fill,
                                                height: 100,
                                                width: MediaQuery.of(context).size.width,
                                              ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(MySize.size1(context),MySize.sizeh05(context),MySize.size1(context),MySize.sizeh05(context)),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 3,
                                                      child: Text(
                                                        bookings[index].booking?.hName??"" ,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: MySize.font9_5(context)
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 1,
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            Essential().map(
                                                                double.parse(bookings[index].booking?.hgLat??"0"),
                                                                double.parse(bookings[index].booking?.hgLong??"0"),
                                                                bookings[index].booking?.hName??""
                                                            );
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.location_on_outlined,
                                                                color: MyColors.grey60,
                                                                size: MySize.sizeh2_5(context),
                                                              ),
                                                              Text("Map",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w300,
                                                                    color: MyColors.grey60,
                                                                    fontSize: MySize.font9_5(context)
                                                                  // fontSize: MySize.font7(context)
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      flex: 4,
                                    ),
                                    Flexible(
                                      flex: 7,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.size1(context)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Date:   " + sd + " - " + ed,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: MySize.font9(context)
                                              ),
                                            ),
                                            Text(
                                              "Time:   " + st + " - " + et,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: MySize.font9(context)
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                  text: "Total Amount:  ",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: MySize.font9(context),
                                                      color: MyColors.black
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: APIConstant.symbol+(bookings[index].booking?.billTotal??""),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    )
                                                  ]
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Paid:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font9(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: APIConstant.symbol+(bookings[index].booking?.bDeposit??""),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Due:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font9(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: APIConstant.symbol+(bookings[index].booking?.due??""),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Total Rooms:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font9(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: bookings[index].booking?.totalRooms??"",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                      text: "Total Guests:  ",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: MySize.font9(context),
                                                          color: MyColors.black
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: bookings[index].booking?.brAdult??"",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "(A)",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        if((bookings[index].booking?.brChild??"")!="0")
                                                          TextSpan(
                                                            text: bookings[index].booking?.brChild??"",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        if((bookings[index].booking?.brChild??"")!="0")
                                                          TextSpan(
                                                            text: "(C)",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                      ]
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:() {

                                                      Essential().link('http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=VIEW');

                                                      // Navigator.push(
                                                      // context, MaterialPageRoute(builder: (context) => Invoice(b_id: bookings[index].booking?.bId??"", action: "VIEW",)));
                                                    },
                                                    child: Icon(
                                                      Icons.picture_as_pdf_outlined,
                                                      size: MySize.sizeh3(context),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: MySize.size1_5(context),),
                                                MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:() {
                                                      Essential().link('http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+(bookings[index].booking?.bId??"")+'&action=DOWNLOAD');
                                                      // Navigator.push(
                                                      //     context, MaterialPageRoute(builder: (context) => Invoice(b_id: bookings[index].booking?.bId??"", action: "DOWNLOAD",)));
                                                    },
                                                    child: Icon(
                                                      Icons.file_copy,
                                                      size: MySize.sizeh3(context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
               ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  decoration: BoxDecoration(
                    color: bookings[index].booking?.bStatus=="BOOKED" ? MyColors.green500 :
                    bookings[index].booking?.bStatus=="CHECKED IN" ? MyColors.blue :
                    bookings[index].booking?.bStatus=="CHECKED OUT" ? MyColors.colorPrimary :
                    bookings[index].booking?.bStatus=="CANCELLED" ? MyColors.yellow800 : MyColors.red,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(MySize.sizeh1(context)), bottomRight: Radius.circular(MySize.sizeh1(context)))
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}