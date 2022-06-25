import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/LoginPopUp.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/bookingDetails/CancellationReason.dart';
import 'package:olr_rooms_web/bookingDetails/Ratings.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/BookingDetailResponse.dart';
import 'package:olr_rooms_web/model/BookingInfo.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:olr_rooms_web/support/RaiseTicket.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BookedDetails extends StatefulWidget {
  final String id;
  const BookedDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<BookedDetails> createState() => _BookedDetailsState();
}

class _BookedDetailsState extends State<BookedDetails> {
  String id = "";
  bool load = false;
  
  BookingInfo booking = BookingInfo();
  List<String> requests = [];

  double gst = 18.0;

  TextEditingController name = TextEditingController();

  bool generate = false;

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    id = widget.id;
    start();

    super.initState();
  }
  Future<void> start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getBookingDetails();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      backgroundColor: MyColors.white,
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "BOOKEDDETAILS"),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
              children: [
                Padding(
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "BOOKEDDETAILS"),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                            child: constraints.maxWidth < 600 ? getBookedDetailsDesignM() : getBookedDetailsDesignW()
                          ),
                          Footer()
                        ],
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
      ),
    );
  }

  getBookedDetailsDesignW() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size5(context), vertical: MySize.sizeh1(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, "+(booking.booking?.bName??"")+"\nYour booking is confirmed",
            style: TextStyle(
                fontSize: MySize.font8(context),
                color: MyColors.black
            ),
          ),
          getPaymentDetails(),
          getBookingDetail(),
          if((booking.booking?.bRequest??"").isNotEmpty)
            getSpecialRequests(),
          if(booking.booking?.bStatus=='BOOKED')
            getMore(),
          if(booking.booking?.bStatus=='CANCELLED')
            getCancellationDetails(),
          if(booking.booking?.bStatus=='CHECKED OUT')
            booking.booking?.brDate==null ?
            Container(
              color: MyColors.white,
              child: ListTile(
                leading: Icon(
                  Icons.arrow_forward_ios,
                  size: MySize.sizeh3(context),
                  color: MyColors.colorPrimary,
                ),
                title: Text(
                  "Ratings & Review",
                  style: TextStyle(
                      fontSize: MySize.font8(context),
                      fontWeight: FontWeight.w400
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return Ratings(
                        id: booking.booking?.bId??"",
                        h_id: booking.booking?.hId??"",
                      );
                    },
                  ).then((value) {
                    if(value!=null) {
                      load = false;
                      setState((){

                      });
                      getBookingDetails();
                    }
                  });
                },
              ),
            ) :
            getRatings(),
        ],
      ),
    );
  }

  getBookedDetailsDesignM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, "+(booking.booking?.bName??"")+"\nYour booking is confirmed",
            style: TextStyle(
                fontSize: MySize.font12(context),
                color: MyColors.black
            ),
          ),
          getPaymentDetailsM(),
          getBookingDetailM(),
          if((booking.booking?.bRequest??"").isNotEmpty)
            getSpecialRequestsM(),
          if(booking.booking?.bStatus=='BOOKED')
            getMoreM(),
          if(booking.booking?.bStatus=='CANCELLED')
            getCancellationDetailsM(),
          if(booking.booking?.bStatus=='CHECKED OUT')
            booking.booking?.brDate==null ?
            Container(
              color: MyColors.white,
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: Icon(
                  Icons.arrow_forward_ios,
                  size: MySize.sizeh2_5(context),
                  color: MyColors.colorPrimary,
                ),
                title: Text(
                  "Ratings & Review",
                  style: TextStyle(
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w400
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return Ratings(
                        id: booking.booking?.bId??"",
                        h_id: booking.booking?.hId??"",
                      );
                    },
                  ).then((value) {
                    if(value!=null) {
                      load = false;
                      setState((){

                      });
                      getBookingDetails();
                    }
                  });
                },
              ),
            ) :
            getRatingsM(),
        ],
      ),
    );
  }

  getPaymentDetails() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BILLING DETAILS",
                  style: TextStyle(
                    fontSize: MySize.font8(context),
                    fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(
                  height: MySize.sizeh1_5(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mobile No.",
                      style: TextStyle(
                        fontSize: MySize.font7_5(context),
                        color: MyColors.grey30
                      ),
                    ),
                    Text(
                      booking.booking?.bMobile??"",
                      style: TextStyle(
                        fontSize: MySize.font7_5(context),
                        color: MyColors.black,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Padding(
              padding: EdgeInsets.only(left: MySize.size5(context)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.grey)
                ),
                child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "View details",
                      style: TextStyle(
                          color: MyColors.black,
                          fontSize: MySize.font7(context),
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: APIConstant.symbol+(booking.booking?.billAmount??""),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: MyColors.grey.withOpacity(0.5),
                            decoration: TextDecoration.lineThrough,
                          fontSize: MySize.font7(context),
                        ),
                        children: <TextSpan>[
                          TextSpan(text: "  "+APIConstant.symbol+(booking.booking?.billTotal??""),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.black,
                                  decoration: TextDecoration.none,
                                  overflow: TextOverflow.ellipsis,
                                fontSize: MySize.font7_5(context),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: MyColors.grey10,
                        borderRadius: BorderRadius.circular(3)
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Room price for "+getDuration()+" X "+(booking.booking?.totalRooms??"0")+((booking.booking?.totalRooms??"0")=="1" ? " Room" : " Rooms"),
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                APIConstant.symbol+(booking.booking?.billAmount??""),
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Price Drop",
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                "- "+APIConstant.symbol+(booking.booking?.billAmount??""),
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(double.parse(booking.booking?.billDiscountAmount??"0")>0)
                          Container(
                            margin: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text(
                                  "Coupon Discount",
                                  style:  TextStyle(
                                    fontSize: MySize.font7(context),
                                      fontWeight: FontWeight.w300
                                  ),
                                ),
                                Text(
                                  "- "+APIConstant.symbol+(booking.booking?.billAmount??"0"),
                                  style:  TextStyle(
                                    fontSize: MySize.font7(context),
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if((int.parse(booking.booking?.bBreakfast??"0")>0 || int.parse(booking.booking?.bLunch??"0")>0 || int.parse(booking.booking?.bDinner??"0")>0))
                          getMealsBilling(),
                        Divider(
                          thickness: 1,
                          color: MyColors.white,
                        ),
                        SizedBox(height: MySize.sizeh1(context),),
                        Container(
                          margin: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Taxable Price",
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                APIConstant.symbol+getTaxablePrice().toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total GST ("+gst.toString()+"%)",
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              Text(
                                "+ "+APIConstant.symbol+getGSTPrice().toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: MySize.font7(context),
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
                                  fontSize: MySize.font7(context),
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              APIConstant.symbol+(booking.booking?.billTotal??"0"),
                              style:  TextStyle(
                                  fontSize: MySize.font7(context),
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
              ),
            )
          ),
        ],
      ),
    );
  }

  getPaymentDetailsM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BILLING DETAILS",
            style: TextStyle(
                fontSize: MySize.font11(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh1_5(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mobile No.",
                style: TextStyle(
                    fontSize: MySize.font11(context),
                    color: MyColors.grey30
                ),
              ),
              Text(
                booking.booking?.bMobile??"",
                style: TextStyle(
                    fontSize: MySize.font10(context),
                    color: MyColors.black,
                    fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
          SizedBox(
            height: MySize.sizeh2(context),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            childrenPadding: EdgeInsets.all(0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "View details",
                  style: TextStyle(
                      color: MyColors.black,
                      fontSize: MySize.font11(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: APIConstant.symbol+(booking.booking?.billAmount??""),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: MyColors.grey.withOpacity(0.5),
                        decoration: TextDecoration.lineThrough,
                        fontSize: MySize.font11(context)
                    ),
                    children: <TextSpan>[
                      TextSpan(text: "  "+APIConstant.symbol+(booking.booking?.billTotal??""),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: MyColors.black,
                              decoration: TextDecoration.none,
                              overflow: TextOverflow.ellipsis,
                              fontSize: MySize.font12(context)
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: MyColors.grey10,
                    borderRadius: BorderRadius.circular(MySize.sizeh055(context))
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room price for "+getDuration()+" X "+(booking.booking?.totalRooms??"0")+((booking.booking?.totalRooms??"0")=="1" ? " Room" : " Rooms"),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w300
                            ),
                          ),
                          Text(
                            APIConstant.symbol+(booking.booking?.billAmount??""),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
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
                            "- "+APIConstant.symbol+(booking.booking?.billAmount??""),
                            style: TextStyle(
                                fontSize: MySize.font11(context),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),
                    if(double.parse(booking.booking?.billDiscountAmount??"0")>0)
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Coupon Discount",
                              style: TextStyle(
                                  fontSize: MySize.font11(context),
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            Text(
                              "- "+APIConstant.symbol+(booking.booking?.billAmount??"0"),
                              style: TextStyle(
                                  fontSize: MySize.font11(context),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    if((int.parse(booking.booking?.bBreakfast??"0")>0 || int.parse(booking.booking?.bLunch??"0")>0 || int.parse(booking.booking?.bDinner??"0")>0))
                      getMealsBilling(),
                    Divider(
                      thickness: 1,
                      color: MyColors.white,
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
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
                      margin: EdgeInsets.only(bottom: 15),
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
                          APIConstant.symbol+(booking.booking?.billTotal??"0"),
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
          )
        ],
      ),
    );
  }

  getBookingDetail() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HotelDetails(h_id: booking.booking?.hId??"",)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                booking.booking?.hName??"",
                                style: TextStyle(
                                    fontSize: MySize.font8(context),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(
                                height: MySize.sizeh1(context),
                              ),
                              Text(
                                booking.booking?.catName??"",
                                style: TextStyle(
                                    fontSize: MySize.font7_5(context),
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              SizedBox(
                                height: MySize.sizeh1(context),
                              ),
                              Text(
                                booking.booking?.hAddress??"",
                                style: TextStyle(
                                    fontSize: MySize.font7_5(context),
                                    fontWeight: FontWeight.w300,
                                  color: MyColors.grey30
                                ),
                              ),
                            ],
                          ),
                          flex: 3,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: ClipRRect(
                            child: booking.images?.length==0 ? Container(
                              height: MySize.sizeh20(context),
                              width: MySize.size100(context),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            )
                                : Image.network(
                              Environment.imageUrl + (booking.images?[0].hiImage??""),
                              fit: BoxFit.fill,
                              height: MySize.sizeh20(context),
                              width: MySize.size100(context),
                            ),
                          ),
                          flex: 2,
                          fit: FlexFit.tight,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MySize.sizeh2(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BOOKING ID: "+(booking.booking?.bNo??""),
                      style: TextStyle(
                        fontSize: MySize.font7_5(context),
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: booking.booking?.bNo??""));
                          Toast.sendToast(context, "Copied to clipboard");
                        },
                        child: Icon(
                          Icons.copy,
                          color: MyColors.colorPrimary,
                          size: MySize.sizeh3(context),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MySize.sizeh1(context),
                ),
                Text(
                  "BOOKING DATE: "+(booking.booking?.bDate??""),
                  style: TextStyle(
                      fontSize: MySize.font7_5(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(
                  height: MySize.sizeh2(context),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: getTravelDetailsDesign(),
          )
        ],
      ),
    );
  }


  getBookingDetailM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context)),
      decoration: BoxDecoration(
        color: MyColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HotelDetails(h_id: booking.booking?.hId??"",)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                booking.booking?.hName??"",
                                style: TextStyle(
                                    fontSize: MySize.font10(context),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(
                                height: MySize.sizeh1(context),
                              ),
                              Text(
                                booking.booking?.catName??"",
                                style: TextStyle(
                                    fontSize: MySize.font9(context),
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              SizedBox(
                                height: MySize.sizeh1(context),
                              ),
                              Text(
                                booking.booking?.hAddress??"",
                                style: TextStyle(
                                    fontSize: MySize.font9(context),
                                    fontWeight: FontWeight.w300,
                                    color: MyColors.grey30
                                ),
                              ),
                            ],
                          ),
                          flex: 3,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: ClipRRect(
                            child: booking.images?.length==0 ? Container(
                              height: MySize.sizeh20(context),
                              width: MySize.size100(context),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            )
                                : Image.network(
                              Environment.imageUrl + (booking.images?[0].hiImage??""),
                              fit: BoxFit.fill,
                              height: MySize.sizeh20(context),
                              width: MySize.size100(context),
                            ),
                          ),
                          flex: 2,
                          fit: FlexFit.tight,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MySize.sizeh2(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BOOKING ID: "+(booking.booking?.bNo??""),
                      style: TextStyle(
                          fontSize: MySize.font10(context),
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: booking.booking?.bNo??""));
                          Toast.sendToast(context, "Copied to clipboard");
                        },
                        child: Icon(
                          Icons.copy,
                          color: MyColors.colorPrimary,
                          size: MySize.sizeh2_5(context),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MySize.sizeh065(context),
                ),
                Text(
                  "BOOKING DATE: "+(booking.booking?.bDate??""),
                  style: TextStyle(
                      fontSize: MySize.font10(context),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: getTravelDetailsDesignM(),
          )
        ],
      ),
    );
  }


  getSpecialRequests() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Special Requests",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: requests.length,
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 5,);
            },
            itemBuilder: (BuildContext context, index) {
              return getRequestDesign(index);
            },
          ),
        ],
      ),
    );
  }

  getSpecialRequestsM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Text(
            "Special Requests",
            style:  TextStyle(
                fontSize: MySize.font11(context),
                fontWeight: FontWeight.w500
            ),
          ),
           SizedBox(
            height: MySize.sizeh2(context),
          ),
          ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: requests.length,
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: MySize.size05(context),);
            },
            itemBuilder: (BuildContext context, index) {
              return getRequestDesignM(index);
            },
          ),
        ],
      ),
    );
  }

  getRequestDesign(int ind) {
    return Row(
      children: [
        const Icon(
          Icons.arrow_right_outlined,
          size: 26,
        ),
        Text(
          requests[ind],
          style: const TextStyle(
            fontSize: 16
          ),
        )
      ],
    );
  }

  getRequestDesignM(int ind) {
    return Row(
      children: [
        Icon(
          Icons.arrow_right_outlined,
          size: MySize.sizeh3(context),
        ),
        Text(
          requests[ind],
          style: TextStyle(
            fontSize: MySize.font10_5(context)
          ),
        )
      ],
    );
  }

  manageBooking() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Text(
            "Manage your bookings",
            style: TextStyle(
                fontSize: MySize.font8(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  leading: Icon(
                    Icons.cancel_outlined,
                    size: MySize.sizeh3(context),
                    color: MyColors.colorPrimary,
                  ),
                  title: Text(
                    "Cancel Booking",
                    style: TextStyle(
                        fontSize: MySize.font7_75(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  onTap: () {
                    cancelBooking();
                  },
                ),
              ),

              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    size: MySize.sizeh3(context),
                    color: MyColors.colorPrimary,
                  ),
                  title: Text(
                    "Modify Guest Name",
                    style: TextStyle(
                        fontSize: MySize.font7_75(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  onTap: () {
                    modifyName();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  manageBookingM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      // padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           Text(
            "Manage your bookings",
            style: TextStyle(
                fontSize: MySize.font11(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  leading: Icon(
                    Icons.cancel_outlined,
                    size: MySize.sizeh2_5(context),
                    color: MyColors.colorPrimary,
                  ),
                  title: Text(
                    "Cancel Booking",
                    style: TextStyle(
                        fontSize: MySize.font10_5(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  onTap: () {
                    cancelBooking();
                  },
                ),
              ),

              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    size: MySize.sizeh2_5(context),
                    color: MyColors.colorPrimary,
                  ),
                  title: Text(
                    "Modify Guest Name",
                    style: TextStyle(
                        fontSize: MySize.font10_5(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  onTap: () {
                    modifyName();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  manageOther() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  title: Text(
                    "Cancellation Policy",
                    style: TextStyle(
                        fontSize: MySize.font7_75(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  leading: Icon(
                    Icons.arrow_forward_ios,
                    size: MySize.sizeh3(context),
                    color: MyColors.colorPrimary,
                  ),
                  onTap: () {
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
                ),
              ),

              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  title:  Text(
                    "Hotel Rules & Policies",
                    style:  TextStyle(
                        fontSize: MySize.font7_75(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  leading: Icon(
                    Icons.arrow_forward_ios,
                    size: MySize.sizeh3(context),
                    color: MyColors.colorPrimary,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            Policies(
                              policy_type: "Hotel Policy",
                              act: APIConstant.getHP,
                              h_id: booking.booking?.hId??"",
                            )
                        )
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  manageOtherM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  title: Text(
                    "Cancellation Policy",
                    style: TextStyle(
                        fontSize: MySize.font10_5(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  leading: Icon(
                    Icons.arrow_forward_ios,
                    size: MySize.sizeh2_5(context),
                    color: MyColors.colorPrimary,
                  ),
                  onTap: () {
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
                ),
              ),

              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ListTile(
                  title:  Text(
                    "Hotel Rules & Policies",
                    style:  TextStyle(
                        fontSize: MySize.font10_5(context),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  leading: Icon(
                    Icons.arrow_forward_ios,
                    size: MySize.sizeh2_5(context),
                    color: MyColors.colorPrimary,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            Policies(
                              policy_type: "Hotel Policy",
                              act: APIConstant.getHP,
                              h_id: booking.booking?.hId??"",
                            )
                        )
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getCancellationDetails() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Cancellation Details",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: 20,
          ),
          getCancellationDesign("Date of Cancellation", (booking.booking?.bcDate??"")),
          SizedBox(
            height: 5,
          ),
          getCancellationDesign("Reason", (booking.booking?.crName??"")),
          SizedBox(
            height: 5,
          ),
          getCancellationDesign("Description", (booking.booking?.bcDescription??"")),
          SizedBox(
            height: 5,
          ),
          getCancellationDesign("Refund Amount", APIConstant.symbol+(booking.booking?.bcRefund??"")),
          SizedBox(
            height: 5,
          ),
          getCancellationDesign("Refund Status", (booking.booking?.refundStatus??"")),
        ],
      ),
    );
  }

  getCancellationDetailsM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
        color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Cancellation Details",
            style: TextStyle(
                fontSize: MySize.font11(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh2(context),
          ),
          getCancellationDesignM("Date of Cancellation", (booking.booking?.bcDate??"")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getCancellationDesignM("Reason", (booking.booking?.crName??"")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getCancellationDesignM("Description", (booking.booking?.bcDescription??"")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getCancellationDesignM("Refund Amount", APIConstant.symbol+(booking.booking?.bcRefund??"")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getCancellationDesignM("Refund Status", (booking.booking?.refundStatus??"")),
        ],
      ),
    );
  }

  getCancellationDesign(String label, String info)
  {
    return RichText(
      text: TextSpan(
        text: "$label :",
        style: TextStyle(
            fontWeight: label=="Review" ? FontWeight.w500 : FontWeight.w400,
            color: MyColors.black,
            fontSize: MySize.font7_75(context)
        ),
        children: <TextSpan>[
          TextSpan(
              text: "  "+info,
              style: TextStyle(
                  fontWeight: label == "Description" || label=="Review" ? FontWeight.w400 : FontWeight.w500 ,
                  color: MyColors.black,
                  decoration: TextDecoration.none,
                  overflow: TextOverflow.ellipsis,
                  fontSize: MySize.font7_5(context)
              )
          ),
        ],
      ),
    );
  }


  getCancellationDesignM(String label, String info)
  {
    return RichText(
      text: TextSpan(
        text: "$label :",
        style: TextStyle(
            fontWeight: label=="Review" ? FontWeight.w500 : FontWeight.w400,
            color: MyColors.black,
            fontSize: MySize.font10_5(context)
        ),
        children: <TextSpan>[
          TextSpan(
              text: "  "+info,
              style: TextStyle(
                  fontWeight: label == "Description" || label=="Review" ? FontWeight.w400 : FontWeight.w500 ,
                  color: MyColors.black,
                  decoration: TextDecoration.none,
                  overflow: TextOverflow.ellipsis,
                  fontSize: MySize.font9_5(context)
              )
          ),
        ],
      ),
    );
  }

  getRatings() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
        color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Ratings & Review",
            style: TextStyle(
                fontSize: MySize.font8(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          getRatingDesign("Location", double.parse(booking.booking?.brLocation??"0")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getRatingDesign("Food", double.parse(booking.booking?.brFood??"0")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getRatingDesign("Staff", double.parse(booking.booking?.brStaff??"0")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getRatingDesign("Cleanliness", double.parse(booking.booking?.brCleanliness??"0")),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          getRatingDesign("Facilities", double.parse(booking.booking?.brFacilities??"0")),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getCancellationDesign("Review", booking.booking?.brReview??"")

        ],
      ),
    );
  }
  getRatingDesign(String label, double rating) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            label,
            style: TextStyle(
                fontSize: MySize.font7_5(context)
            ),
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: RatingBar.builder(
            initialRating: rating,
            direction: Axis.horizontal,
            ignoreGestures: true,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: MySize.sizeh2(context),
            unratedColor: MyColors.grey10,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: getRatingColor(rating),
            ),
            onRatingUpdate: (double value) {
            },
          ),
        ),
      ],
    );
  }

  getRatingsM() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      decoration: BoxDecoration(
        color: MyColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Ratings & Review",
            style: TextStyle(
                fontSize: MySize.font12(context),
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(
            height: MySize.sizeh1(context),
          ),
          getRatingDesignM("Location", double.parse(booking.booking?.brLocation??"0")),
          getRatingDesignM("Food", double.parse(booking.booking?.brFood??"0")),
          getRatingDesignM("Staff", double.parse(booking.booking?.brStaff??"0")),
          getRatingDesignM("Cleanliness", double.parse(booking.booking?.brCleanliness??"0")),
          getRatingDesignM("Facilities", double.parse(booking.booking?.brFacilities??"0")),
          SizedBox(
            height: MySize.sizeh3(context),
          ),
          getCancellationDesignM("Review", booking.booking?.brReview??"")

        ],
      ),
    );
  }
  getRatingDesignM(String label, double rating) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh025(context)),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: MySize.font10(context)
              ),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: RatingBar.builder(
              initialRating: rating,
              direction: Axis.horizontal,
              ignoreGestures: true,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: MySize.sizeh2(context),
              unratedColor: MyColors.grey10,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: getRatingColor(rating),
              ),
              onRatingUpdate: (double value) {
              },
            ),
          ),
        ],
      ),
    );
  }

  getRatingColor(double rating) {
    return rating<=2 ? MyColors.red : rating<=3 ? MyColors.yellow800 : MyColors.green500;
  }

  Future<void> getBookingDetails() async {

    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByBID,
      "id": id,
    };
    BookingDetailResponse bookingDetailResponse = await APIService().getBookingDetails(queryParameters);

    if(bookingDetailResponse.status=="Success" && bookingDetailResponse.message=="Booking Details Retrieved") {
      booking = bookingDetailResponse.data ?? BookingInfo();
    }
    else {
      booking = BookingInfo();
    }

    String request = bookingDetailResponse.data?.booking?.bRequest??"";
    String temp = request;
    print(request.split(";").length);

    for(int i = 0; i<request.split(";").length; i++) {
      if(i==request.split(";").length-1)
        requests.add(temp.substring(0));
      else
        requests.add(temp.substring(0, temp.indexOf(";")));

      temp = temp.substring(temp.indexOf(";")+1);
    }

    load = true;

    setState(() {

    });
    name.text = booking.booking?.bName??"";
  }

  String getDuration() {
    DateTime ds = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brStart??"");
    DateTime de = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brEnd??"");
    if(int.parse(booking.booking?.brTimePeriod??"0")==24) {
      return (de.day - ds.day).toString()+" Night";
    } else {
      return (booking.booking?.brTimePeriod??"0")+" Hours";
    }
  }

  getTaxablePrice() {
    return double.parse(booking.booking?.billTotal??"0") - getGSTPrice();
  }

  getGSTPrice() {
    return double.parse(booking.booking?.billTotal??"0")*(gst/100);
  }

  getMealsBilling()
  {
    return Column(
      children: [
        if(int.parse(booking.booking?.bBreakfast??"0")>0)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Breakfast",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+(booking.booking?.bBprice??"0"),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        if(int.parse(booking.booking?.bLunch??"0")>0)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lunch",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+(booking.booking?.bLprice??"0"),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        if(int.parse(booking.booking?.bDinner??"0")>0)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dinner",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300
                  ),
                ),
                Text(
                  "+ "+APIConstant.symbol+(booking.booking?.bDprice??"0"),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  getTravelDetailsDesign(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: MySize.size2(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
        border: Border.all(color: MyColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(MySize.sizeh1(context))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getDates(),
          getGuests(),
          SizedBox(
            height: MySize.sizeh2(context),
          ),
          getActions()
        ],
      ),
    );
  }

  getTravelDetailsDesignM(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: MySize.size2(context)),
      decoration: BoxDecoration(
          color: MyColors.white,
        border: Border.all(color: MyColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(MySize.sizeh1(context))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getDatesM(),
          getGuestsM(),
          SizedBox(
            height: MySize.sizeh2(context),
          ),
          getActionsM()
        ],
      ),
    );
  }

  getDates(){
    DateTime ds = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brStart??"");
    DateTime de = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brEnd??"");
    return Padding(
      padding: EdgeInsets.fromLTRB(MySize.size2(context),MySize.sizeh1(context),MySize.size2(context),0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "CHECK-IN",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: MySize.sizeh05(context),),
              Text(
                Strings.weekday[ds.weekday-1]+", "+ds.day.toString()+" "+Strings.month[ds.month-1]+", "+
                    (ds.hour==0 ? 12 : ds.hour>12 ? ds.hour - 12 : ds.hour).toString()+ (ds.hour>=12 && ds.hour!=24? ":00 PM" : ":00 AM"),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7(context),
                    fontWeight: FontWeight.w300
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "CHECK-OUT",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: MySize.sizeh05(context),),
              Text(
                Strings.weekday[de.weekday-1]+", "+de.day.toString()+" "+Strings.month[de.month-1]+", "+
                    (de.hour==0 ? 12 : de.hour>12 ? de.hour - 12 : de.hour).toString()+ (de.hour>=12 && de.hour!=24? ":00 PM" : ":00 AM"),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7(context),
                    fontWeight: FontWeight.w300
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getDatesM(){
    DateTime ds = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brStart??"");
    DateTime de = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(booking.booking?.brEnd??"");
    return Padding(
      padding: EdgeInsets.fromLTRB(MySize.size2(context),MySize.sizeh1(context),MySize.size2(context),MySize.sizeh1(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "CHECK-IN",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: MySize.sizeh05(context),),
              Text(
                Strings.weekday[ds.weekday-1]+", "+ds.day.toString()+" "+Strings.month[ds.month-1]+", "+
                    (ds.hour==0 ? 12 : ds.hour>12 ? ds.hour - 12 : ds.hour).toString()+ (ds.hour>=12 && ds.hour!=24? ":00 PM" : ":00 AM"),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font8_5(context),
                    fontWeight: FontWeight.w300
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "CHECK-OUT",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: MySize.sizeh05(context),),
              Text(
                Strings.weekday[de.weekday-1]+", "+de.day.toString()+" "+Strings.month[de.month-1]+", "+
                    (de.hour==0 ? 12 : de.hour>12 ? de.hour - 12 : de.hour).toString()+ (de.hour>=12 && de.hour!=24? ":00 PM" : ":00 AM"),
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font8_5(context),
                    fontWeight: FontWeight.w300
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getGuests(){
    return Padding(
      padding: EdgeInsets.fromLTRB(MySize.size2(context),MySize.sizeh1(context),MySize.size2(context),0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Rooms",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                booking.booking?.totalRooms??"0",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.sizeh05(context),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Guests",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                booking.booking?.brGuest??"0",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font7_5(context),
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.sizeh05(context),),
          Text(
            "("+(booking.booking?.brAdult??"0")+(int.parse(booking.booking?.brAdult??"0")>1 ? " Adults" : " Adult")+(int.parse(booking.booking?.brChild??"0")>0 ? ", "+(booking.booking?.brChild??"0")+(int.parse(booking.booking?.brChild??"0")>1 ? " Children" : " Child") : "")+")",
            style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font7_5(context),
                fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    );
  }

  getGuestsM(){
    return Padding(
      padding: EdgeInsets.fromLTRB(MySize.size2(context),MySize.sizeh1(context),MySize.size2(context),MySize.sizeh1(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Rooms",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                booking.booking?.totalRooms??"0",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.sizeh05(context),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. of Guests",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w300
                ),
              ),
              Text(
                booking.booking?.brGuest??"0",
                style: TextStyle(
                    color: MyColors.black,
                    fontSize: MySize.font9(context),
                    fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          SizedBox(height: MySize.sizeh05(context),),
          Text(
            "("+(booking.booking?.brAdult??"0")+(int.parse(booking.booking?.brAdult??"0")>1 ? " Adults" : " Adult")+(int.parse(booking.booking?.brChild??"0")>0 ? ", "+(booking.booking?.brChild??"0")+(int.parse(booking.booking?.brChild??"0")>1 ? " Children" : " Child") : "")+")",
            style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font9(context),
                fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    );
  }

  getActions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size05(context), vertical: MySize.sizeh05(context)),
      decoration: BoxDecoration(
        color: MyColors.grey1.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MySize.size1(context)),
          bottomRight: Radius.circular(MySize.size1(context))
        )
      ),
      child: Row(
        children: [
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return RaiseTicket(
                        h_id: booking.booking?.hId??"",
                        b_id: booking.booking?.bNo??"",
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.live_help_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh3(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Need Help",
                      style: TextStyle(
                          fontSize: MySize.font7(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  Essential().map(
                      double.parse(booking.booking?.hgLat??"0"),
                      double.parse(booking.booking?.hgLong??"0"),
                      booking.booking?.hName??""
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh3(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Directions",
                      style: TextStyle(
                          fontSize: MySize.font7(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IgnorePointer(
                ignoring: generate,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      generate = true;
                    });
                    String link = "https://youtu.be/AG-erEMhumc";//await OLRLinks().createDynamicLink(true, kBookingDetailLink+widget.id);
                    Share.share(link, subject: 'Hey, look at the booking I have made!').then((value) {
                      setState(() {
                        generate = false;
                      });
                    });

                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.share,
                        color: MyColors.colorPrimary,
                        size: MySize.sizeh3(context),
                      ),
                      SizedBox(
                        height: MySize.sizeh075(context),
                      ),
                      Text(
                        "Share",
                        style: TextStyle(
                            fontSize: MySize.font7(context)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().call("tel://"+(booking.booking?.hgHelplineCustomer??""));
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.call_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh3(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Call Hotel",
                      style: TextStyle(
                        fontSize: MySize.font7(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
        ],
      ),
    );
  }

  getActionsM() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size05(context), vertical: MySize.sizeh05(context)),
      decoration: BoxDecoration(
        color: MyColors.grey1.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MySize.size1(context)),
          bottomRight: Radius.circular(MySize.size1(context))
        )
      ),
      child: Row(
        children: [
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return RaiseTicket(
                        h_id: booking.booking?.hId??"",
                        b_id: booking.booking?.bNo??"",
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.live_help_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh2_5(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Need Help",
                      style: TextStyle(
                          fontSize: MySize.font8_5(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  Essential().map(
                      double.parse(booking.booking?.hgLat??"0"),
                      double.parse(booking.booking?.hgLong??"0"),
                      booking.booking?.hName??""
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh2_5(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Directions",
                      style: TextStyle(
                          fontSize: MySize.font8_5(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IgnorePointer(
                ignoring: generate,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      generate = true;
                    });
                    String link = "https://youtu.be/AG-erEMhumc";//await OLRLinks().createDynamicLink(true, kBookingDetailLink+widget.id);
                    Share.share(link, subject: 'Hey, look at the booking I have made!').then((value) {
                      setState(() {
                        generate = false;
                      });
                    });

                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.share,
                        color: MyColors.colorPrimary,
                        size: MySize.sizeh2_5(context),
                      ),
                      SizedBox(
                        height: MySize.sizeh075(context),
                      ),
                      Text(
                        "Share",
                        style: TextStyle(
                            fontSize: MySize.font8_5(context)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().call("tel://"+(booking.booking?.hgHelplineCustomer??""));
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.call_outlined,
                      color: MyColors.colorPrimary,
                      size: MySize.sizeh2_5(context),
                    ),
                    SizedBox(
                      height: MySize.sizeh075(context),
                    ),
                    Text(
                      "Call Hotel",
                      style: TextStyle(
                          fontSize: MySize.font8_5(context)
                      ),
                    )
                  ],
                ),
              ),
            ),
            flex: 1,
            fit: FlexFit.tight,
          ),
        ],
      ),
    );
  }

  void cancelBooking() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const LoginPopUp(
          msg: "Are you sure you want to cancel this booking?", 
          key1: 'Confirm',
          key2: 'Cancel',
        );
      },
    ).then((value) {
      if(value=='Confirm') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return CancellationReason(
                data: {
                  APIConstant.act: APIConstant.del,
                  "b_id": booking.booking?.bId??"",
                  "deposit": booking.booking?.bDeposit??"0",
                  "status": double.parse(booking.booking?.bDeposit??"0")>0 ? 'IN PROGRESS' : 'PAID',
                }
            );
          },
        ).then((value) {
          if(value!=null) {
            Navigator.pop(context, value);
          }
        });
      }
    });
  }

  void modifyName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Dialog(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                width: 400,
                height: 200,
                padding: EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: "Guest Name"
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  modifyGuestName();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(7),
                                  margin: EdgeInsets.only(right: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: MyColors.colorPrimary,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text(
                                    "Change",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: MyColors.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(7),
                                  margin: EdgeInsets.only(left: 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: MyColors.colorPrimary,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: MyColors.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if(value!=null) {
        load = false;
        setState(() {

        });
        getBookingDetails();
      }
    });
  }

  getMore() {
    return Column(
      children: [
        manageBooking(),
        manageOther(),
      ],
    );
  }

  getMoreM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      child: Column(
        children: [
          manageBookingM(),
          manageOtherM(),
        ],
      ),
    );
  }

  modifyGuestName() async {
    Map<String, dynamic> data = {
      APIConstant.act : APIConstant.update,
      "b_id" : booking.booking?.bId,
      "name" : name.text
    };

    Response response = await APIService().modifyGuestName(data);
    print(response.toJson());

    Toast.sendToast(context, response.message??"");

    if(response.status == 'Success') {
      Navigator.pop(context,"Change");
    }

  }

}
