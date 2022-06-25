import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/OfferDetailResponse.dart';
import 'package:olr_rooms_web/model/OfferInfo.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

class OfferDetails extends StatefulWidget {
  final String id, by;
  const OfferDetails({Key? key, required this.id, required this.by}) : super(key: key);

  @override
  State<OfferDetails> createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  bool load = false;
  OfferInfo offer = OfferInfo();
  String id = "";
  String by = "";
  DateTime date = DateTime.now();

  var unescape = HtmlUnescape();
  @override
  void initState() {
    id = widget.id;
    by = widget.by;
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context), horizontal: MySize.size7(context)),
      child: Dialog(
          child: SingleChildScrollView(
            child: Padding(
             padding: EdgeInsets.symmetric(horizontal: MySize.size2(context), vertical: MySize.sizeh1(context),),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,

                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: MySize.sizeh1(context)),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Container(
                            color: Colors.blue,
                            child: Image.network(
                              Environment.imageUrl + (offer.offer?.image??""),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MySize.size2(context),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.offer?.name??"",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: MySize.font8(context)
                                  ),
                                ),
                                SizedBox(
                                  height: MySize.sizeh1(context),
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: "DISCOUNT: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: MyColors.black,
                                          fontSize: MySize.font7_25(context)
                                      ),
                                      children: [
                                        TextSpan(
                                          text: (offer.offer?.discount??"")+((offer.offer?.discountType??"")=="PERCENTAGE" ? "%" : "/-") + " OFF",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                          ),
                                        )
                                      ]
                                  ),
                                ),
                                SizedBox(
                                  height: MySize.sizeh2(context),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: offer.offer?.code??""));
                                      Toast.sendToast(context, "Copied to clipboard");
                                    },
                                    child: DottedBorder(
                                      color: MyColors.orange,
                                      strokeWidth: 1,
                                      borderType: BorderType.RRect,
                                      radius: Radius.circular(MySize.size10(context)),
                                      dashPattern: const [
                                        5,
                                        5,
                                      ],
                                      child: Container(
                                        height: MySize.sizeh4(context),
                                        padding: EdgeInsets.symmetric(vertical: MySize.sizeh05(context), horizontal: MySize.size1(context)),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: MyColors.orange.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(MySize.size10(context))
                                        ),
                                        child: Text(
                                          "CODE:   "+(offer.offer?.code??""),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MySize.font8(context)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MySize.sizeh3(context),
                                ),
                                Text(
                                  "Expires on "+date.day.toString()+" "+Strings.month[date.month-1]+", "+date.year.toString(),
                                  style: TextStyle(
                                      fontSize: MySize.font7_5(context)
                                  ),
                                ),
                                ExpansionTile(
                                  leading: Icon(
                                    Icons.info_outline, color: MyColors.black,
                                    size: MySize.sizeh3(context),
                                  ),
                                  title: Text(
                                    "Offer Details",
                                    style: TextStyle(
                                        fontSize: MySize.font7_5(context)
                                    ),
                                  ),
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  children: [
                                    Html(
                                      data: unescape.convert(utf8.decode(base64Decode(offer.offer?.description??""))),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.list, color: MyColors.black,),
                    title: Text(
                      "Steps To Avail Offer",
                      style: TextStyle(
                          fontSize: MySize.font7_5(context)
                      ),
                    ),
                    children: [
                      Container()
                    ],
                  ),
                ],
              )
            ),
          ),
      ),
    ) : Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  Future<void> start() async {
    await getOfferDetails();
  }
  
  Future<void> getOfferDetails() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
      "id" : id,
      "by" : by
    };
    OfferDetailResponse offerDetailResponse = await APIService().getOfferDetails(queryParameters);
    print("offerDetailResponse.toJson()");
    print(offerDetailResponse.toJson());

    if(offerDetailResponse.status=="Success" && offerDetailResponse.message=="Offer Details Retrieved") {
      offer = offerDetailResponse.data ?? OfferInfo();
      date = DateFormat("yyyy-MM-dd").parse(offer.offer?.endDate??"");
    }
    else {
      offer = OfferInfo();
      Toast.sendToast(context, offerDetailResponse.message??"");
    }

    load = true;

    setState(() {

    });
  }
}
