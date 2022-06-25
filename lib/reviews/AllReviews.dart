import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/APIConstant.dart';
import '../api/APIService.dart';
import '../model/Reviews.dart';
import '../model/ReviewsResponse.dart';

class AllReviews extends StatefulWidget {
  final String h_id, h_rating;
  const AllReviews({Key? key, required this.h_id, required this.h_rating}) : super(key: key);

  @override
  State<AllReviews> createState() => _AllReviewsState();
}

class _AllReviewsState extends State<AllReviews> {


  String h_id = "";
  double h_rating = 0;
  List<Reviews>? ratings = [];
  
  bool load = false;

  @override
  void initState() {
    h_id = widget.h_id;
    h_rating = double.parse(widget.h_rating);
    getAllRatings();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: MyColors.black.withOpacity(0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: MyColors.white,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.4,
                    color: MyColors.white,
                    padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MySize.sizeh7(context),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(MySize.sizeh055(context)),
                                border: Border.all(color: MyColors.grey10),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      MyColors.white,
                                      MyColors.grey10.withOpacity(0.3),
                                      MyColors.grey10
                                    ]
                                )
                            ),
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size2(context)),
                                  padding: EdgeInsets.symmetric(vertical: MySize.sizeh05(context), horizontal: MySize.size05(context)),
                                  height: MySize.sizeh3(context),
                                  width: MySize.size6(context),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(MySize.sizeh05(context)),
                                      color: h_rating.round()<=2 ? MyColors.red : h_rating.round()<=3 ? MyColors.yellow800 : MyColors.green500
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        h_rating.toStringAsFixed(1),
                                        style: TextStyle(
                                            fontSize: MySize.font7_5(context),
                                            fontWeight: FontWeight.w600,
                                            color: MyColors.white
                                        ),
                                      ),
                                      SizedBox(
                                        width: MySize.size05(context),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: MyColors.white,
                                        size: MySize.sizeh1_5(context),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.ratings[h_rating.round()==0 ? 0 : h_rating.round()-1],
                                      style: TextStyle(
                                          fontSize: MySize.font7_25(context),
                                          fontWeight: FontWeight.w600,
                                          color: MyColors.black
                                      ),
                                    ),
                                    SizedBox(
                                      height: MySize.sizeh065(context),
                                    ),
                                    Text(
                                      "("+((ratings?.length??0)==0 ? "No" : ratings?.length??0).toString()+" ratings on verified stays by guests)",
                                      style: TextStyle(
                                          fontSize: MySize.font7(context),
                                          fontWeight: FontWeight.w300,
                                          color: MyColors.grey30.withOpacity(0.7)
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          getReviews()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
  }

  getReviews(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: ratings?.length??0,
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(
            height: MySize.sizeh1(context)
          );
        },
        itemBuilder: (BuildContext context, index) {
          return getReviewCard(index);
        },
      ),
    );
    // List<Widget> rating = [];
    // for(int i = 0 ; i < (ratings?.length??0); i++)
    //   {
    //     rating.add(getReviewCard(i));
    //   }
    // return rating;
  }
  
  getReviewCard(int ind){
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: MySize.sizeh1(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                ratings?[ind]?.cusName??"",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MySize.font8(context)
                ),
              ),
              SizedBox(width: MySize.size05(context),),
              Icon(
                Icons.circle,
                color: MyColors.black,
                size: MySize.size03(context),
              ),
              SizedBox(width: MySize.size05(context),),
              Text(
                ratings?[ind]?.brDate??"",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: MySize.font6_5(context),
                    color: MyColors.black
                ),
              ),
            ],
          ),
          SizedBox(
            height: MySize.sizeh05(context),
          ),
          RatingBar.builder(
            initialRating: getUserRating(ind),
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ignoreGestures: true,
            itemSize: MySize.sizeh1_5(context),
            unratedColor: MyColors.grey10,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: getUserRating(ind).roundToDouble()<=2 ? MyColors.red : getUserRating(ind).roundToDouble()<=3 ? MyColors.yellow800 : MyColors.green500,
            ),
            onRatingUpdate: (double value) {
            },
          ),
          SizedBox(
            height: MySize.sizeh1_5(context),
          ),
          Text(
            ratings?[ind].brReview??"",
            style: TextStyle(
              fontSize: MySize.font7(context),
              color: MyColors.black,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      )
    );
  }

  // double getTotalAverageRating() {
  //   double rating = 0.0;
  //   for(int i = 0; i < (ratings?.length??0); i++) {
  //
  //     rating += getUserRating(i);
  //   }
  //   print("ratings");
  //   print(ratings);
  //   print(ratings?.length??0);
  //   return (rating/(ratings?.length??0));
  // }

  double getUserRating(int ind) {
    double rating = 0.0;
    rating = double.parse((double.parse(ratings![ind].brLocation??"0") + double.parse(ratings![ind].brFood??"0") + double.parse(ratings![ind].brCleanliness??"0") + double.parse(ratings![ind].brStaff??"0") + double.parse(ratings![ind].brFacilities??"0")).toString());
    return (rating/5);
  }

  getAllRatings() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getAll,
      "h_id": h_id
    };
    ReviewsResponse reviewsResponse = await APIService().getRatings(queryParameters);

    if (reviewsResponse.status == 'Success' &&
        reviewsResponse.message == 'Ratings Retrieved')
      ratings = reviewsResponse.data ?? [];
    else
      ratings = [];
    load = true;
    setState(() {

    });
  }
}
