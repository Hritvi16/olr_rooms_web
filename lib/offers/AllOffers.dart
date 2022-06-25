import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/HotelOfferResponse.dart';
import 'package:olr_rooms_web/model/OfferInfo.dart';
import 'package:olr_rooms_web/offers/OfferDetails.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllOffers extends StatefulWidget {
  final int offer;
  final String h_id;
  const AllOffers({Key? key, required this.offer, required this.h_id}) : super(key: key);

  @override
  State<AllOffers> createState() => _AllOffersState();
}

class _AllOffersState extends State<AllOffers> {

  List<OfferInfo> offers = [];
  int offer = 0;
  String h_id = "0";

  TextEditingController offerController = TextEditingController();
  // var unescape = HtmlUnescape();

  bool load = false;
  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // offers = widget.offers;
    offer = widget.offer;
    h_id = widget.h_id;
    getHotelOffers();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, offer);
        return true;
      },
      child: Scaffold(
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "ALLOFFERS"),
        backgroundColor: MyColors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Padding(
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "ALLOFFERS"),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                            child: constraints.maxWidth < 600 ? getOffersBodyM() : getOffersBodyW()
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
      )
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
  }

  getOffersBodyW() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              onFieldSubmitted: (value) {
                checkOffer();
              },
              controller: offerController,
              cursorColor: MyColors.colorPrimary,
              style: TextStyle(color: MyColors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MySize.size10(context)),
                    // borderSide: BorderSide(width: 0.0, style: BorderStyle.none, color: MyColors.colorPrimary)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MySize.size10(context)),
                    // borderSide: BorderSide(width: 0.0, style: BorderStyle.none, color: MyColors.colorPrimary)
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh05(context)),
                fillColor: MyColors.white,
                filled: true,
                hintText: "PROMO CODE",
                suffixIcon : MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () {
                        checkOffer();
                      },
                      child: Icon(Icons.arrow_forward,)
                  ),
                ),

              ),
              keyboardType: TextInputType.name,
            ),
            getOffersW()
          ],
        ),
      ),
    );
  }

  getOffersBodyM() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              onFieldSubmitted: (value) {
                checkOffer();
              },
              controller: offerController,
              cursorColor: MyColors.colorPrimary,
              style: TextStyle(color: MyColors.black),
              decoration: InputDecoration(
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.7),
                    // borderSide: new BorderSide(width: 0.0, style: BorderStyle.none)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.7),
                    // borderSide: new BorderSide(width: 0.0, style: BorderStyle.none)
                ),
                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                fillColor: MyColors.white,
                filled: true,
                hintText: "PROMO CODE",
                hintStyle: const TextStyle(
                    fontSize: 16
                ),
                suffixIcon : MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () {
                        checkOffer();
                      },
                      child: Icon(Icons.arrow_forward, size: 20,)
                  ),
                ),

              ),
              keyboardType: TextInputType.name,
            ),
            getOffersM()
          ],
        ),
      ),
    );
  }

  Future<void> getHotelOffers() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> data = {
      APIConstant.act: APIConstant.getByHotel,
      "h_id": h_id,
    };
    HotelOfferResponse hotelOfferResponse = await APIService().getHotelOffers(data);
    print("hotelOfferResponse.toJson()");
    print(hotelOfferResponse.toJson());

    if(hotelOfferResponse.status=="Success" && hotelOfferResponse.message=="Offers Retrieved") {
      offers = hotelOfferResponse.data ?? [];
    }
    else {
      offers = [];
      Toast.sendToast(context, hotelOfferResponse.message??"");
    }
    offer = offers.length>0 ? 0 : -1;
    load = true;
    setState(() {

    });
  }

  getOffersW(){
    return Container(
      margin: EdgeInsets.only(top: MySize.sizeh2(context)),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: MySize.sizeh04(context),
        mainAxisSpacing: MySize.sizeh1(context),
        crossAxisSpacing: MySize.size1(context),
        shrinkWrap: true,
        children: List.generate(offers.length, (index) {
          return getOfferCardW(index);
        }),
      ),
    );
  }

  getOffersM(){
    return Container(
      margin: EdgeInsets.only(top: MySize.sizeh2(context)),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: offers.length,
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, index){
          return SizedBox(height: MySize.sizeh2(context));
        },
        itemBuilder: (BuildContext context, index){
          return getOfferCardM(index);
        },
      ),
    );
  }

  getOfferCardW(int ind){
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          print(offers[ind].offer?.id??"");
          print(offers[ind].by??"");
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return OfferDetails(
                  id: offers[ind].offer?.id??"",
                  by: offers[ind].by??""
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.all(Radius.circular(MySize.sizeh055(context))),
            border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: MySize.size1(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              height: MySize.sizeh7(context),
                              child: Image.network(
                                Environment.imageUrl + (offers[ind].offer?.image??""),
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(width: MySize.size1(context),),
                            DottedBorder(
                              color: MyColors.orange,
                              strokeWidth: 1,
                              dashPattern: const [
                                5,
                                5,
                              ],
                              child: Container(
                                height: MySize.sizeh2_5(context),
                                padding: EdgeInsets.symmetric(horizontal: MySize.size05(context), vertical: MySize.sizeh02(context)),
                                // margin: EdgeInsets.all(3),
                                color: MyColors.orange.withOpacity(0.3),
                                alignment: Alignment.center,
                                child: Text(
                                  offers[ind].offer?.code??"",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: MySize.font7(context)
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        fit: FlexFit.tight,
                        flex: 7,
                      ),
                      Flexible(
                        child: offer==ind ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh05(context)),
                                decoration: BoxDecoration(
                                  color: MyColors.purple100.withOpacity(0.4),
                                  borderRadius: BorderRadius.all(Radius.circular(MySize.size1(context))),
                                  border: Border.all(color: MyColors.purple100.withOpacity(0.5))
                                ),
                                child: Row(
                                  children: [
                                    Text("Applied",
                                      style: TextStyle(
                                          fontSize: MySize.font7(context)
                                      ),
                                    ),
                                    SizedBox(
                                      width: MySize.size1(context),
                                    ),
                                    Icon(Icons.check_circle, color: MyColors.black, size: MySize.size1(context),)
                                  ],
                                ),
                              ),
                            ],
                          ) :
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    offer = ind;
                                    setState(() {

                                    });
                                    Navigator.pop(context, offer);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh05(context)),
                                    decoration: BoxDecoration(
                                      color: MyColors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(MySize.size1(context))),
                                        border: Border.all(color: MyColors.grey10.withOpacity(0.7))
                                    ),
                                    child: Text(
                                      "Apply",
                                      style: TextStyle(
                                        color: MyColors.red,
                                        fontSize: MySize.font7(context)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        fit: FlexFit.tight,
                        flex: 3,
                      ),
                    ],
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: MySize.size1(context)),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offers[ind].offer?.name??"",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MySize.font8(context)
                      ),
                    ),
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: MySize.size1(context)),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offers[ind].offer?.short??"",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: MySize.font7(context)
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // child: Html(
                    //   data: unescape.convert(offers[ind].offer?.description??""),
                    // ),
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                              text: "DISCOUNT: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.black,
                                  fontSize: MySize.font7_5(context)
                              ),
                              children: [
                                TextSpan(
                                  text: (offers[ind].offer?.discount??"")+((offers[ind].offer?.discountType??"")=="PERCENTAGE" ? "%" : "/-") + " OFF",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                  ),
                                )
                              ]
                          ),
                        ),
                      ),
                      fit: FlexFit.tight,
                      flex: 4,
                    ),
                    Flexible(
                      child: Container(
                        margin:  EdgeInsets.only(left: MySize.size1(context)),
                        alignment: Alignment.center,
                        height: MySize.size10(context),
                        decoration: BoxDecoration(
                            color: MyColors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(MySize.sizeh055(context)), bottomLeft: Radius.circular(MySize.sizeh055(context)))
                        ),
                        child: Text(
                          offers[ind].by=='user' ? 'For You' : offers[ind].by=='hotel' ? 'HOTEL' : 'OLR',
                          style: TextStyle(
                              color: MyColors.white
                          ),
                        ),
                      ),
                      fit: FlexFit.tight,
                      flex: 1,
                    )
                  ],
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getOfferCardM(int ind){
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return OfferDetails(
                  id: offers[ind].offer?.id??"",
                  by: offers[ind].by??""
              );
            },
          );
        },
        child: Container(
          height: MySize.sizeh20(context),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 15, right: 0, top: 15, bottom: 15),
          decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
              border: Border.all(color: MyColors.grey.withOpacity(0.3))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 20,
                              child: Image.network(
                                Environment.imageUrl + (offers[ind].offer?.image??""),
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(width: 10,),
                            DottedBorder(
                              color: MyColors.orange,
                              strokeWidth: 1,
                              dashPattern: const [
                                5,
                                5,
                              ],
                              child: Container(
                                height: 15,
                                padding: EdgeInsets.fromLTRB(2, 1, 2, 1),
                                // margin: EdgeInsets.all(3),
                                color: MyColors.orange.withOpacity(0.3),
                                alignment: Alignment.center,
                                child: Text(
                                  offers[ind].offer?.code??"",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        fit: FlexFit.tight,
                        flex: 7,
                      ),
                      Flexible(
                        child: offer==ind ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                              decoration: BoxDecoration(
                                  color: MyColors.purple100.withOpacity(0.4),
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                  border: Border.all(color: MyColors.purple100.withOpacity(0.5))
                              ),
                              child: Row(
                                children: [
                                  Text("Applied",
                                    style: TextStyle(
                                        fontSize: 12
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(Icons.check_circle, color: MyColors.black, size: 12,)
                                ],
                              ),
                            ),
                          ],
                        ) :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  offer = ind;
                                  setState(() {

                                  });
                                  Navigator.pop(context, offer);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                  decoration: BoxDecoration(
                                      color: MyColors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(3)),
                                      border: Border.all(color: MyColors.grey10.withOpacity(0.7))
                                  ),
                                  child: Text(
                                    "Apply",
                                    style: TextStyle(
                                        color: MyColors.red
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        fit: FlexFit.tight,
                        flex: 3,
                      ),
                    ],
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offers[ind].offer?.name??"",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13
                      ),
                    ),
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offers[ind].offer?.short??"",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // child: Html(
                    //   data: unescape.convert(offers[ind].offer?.description??""),
                    // ),
                  ),
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                              text: "DISCOUNT: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.black,
                                  fontSize: MySize.font14(context)
                              ),
                              children: [
                                TextSpan(
                                  text: (offers[ind].offer?.discount??"")+((offers[ind].offer?.discountType??"")=="PERCENTAGE" ? "%" : "/-") + " OFF",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ]
                          ),
                        ),
                      ),
                      fit: FlexFit.tight,
                      flex: 4,
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        alignment: Alignment.center,
                        height: 25,
                        decoration: BoxDecoration(
                            color: MyColors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))
                        ),
                        child: Text(
                          offers[ind].by=='user' ? 'For You' : offers[ind].by=='hotel' ? 'HOTEL' : 'OLR',
                          style: TextStyle(
                              color: MyColors.white
                          ),
                        ),
                      ),
                      fit: FlexFit.tight,
                      flex: 1,
                    )
                  ],
                ),
                fit: FlexFit.tight,
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkOffer() {
    int cnt = 0;
    for(int i = 0; i < offers.length; i++) {
      if((offers[i].offer?.code??"")==offerController.text) {
        cnt++;
        offer = i;
        setState(() {

        });
        Toast.sendToast(context, "Offer Applied");
        break;
        // Navigator.pop(context, offer);
      }

    }
    if(cnt==0)
      Toast.sendToast(context, "There's no such promo code.");
  }
}
