import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/APIConstant.dart';
import '../api/APIService.dart';
import '../model/Reviews.dart';
import '../model/ReviewsResponse.dart';

class AllReviewsM extends StatefulWidget {
  final String h_id, h_rating;
  const AllReviewsM({Key? key, required this.h_id, required this.h_rating}) : super(key: key);

  @override
  State<AllReviewsM> createState() => _AllReviewsMState();
}

class _AllReviewsMState extends State<AllReviewsM> {


  String h_id = "";
  double h_rating = 0;
  List<Reviews>? ratings = [];
  
  bool load = false;

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    h_id = widget.h_id;
    h_rating = double.parse(widget.h_rating);
    getAllRatings();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ?Scaffold(
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "ALLREVIEWS",),
      backgroundColor: MyColors.white,

      body:  Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(15.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                              margin: EdgeInsets.all(20),
                              height: 30,
                              width: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: h_rating.round()<=2 ? MyColors.red : h_rating.round()<=3 ? MyColors.yellow800 : MyColors.green500
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    h_rating.toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      color: MyColors.white
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: MyColors.white,
                                    size: 12,
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.black
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "("+((ratings?.length??0)==0 ? "No" : ratings?.length??0).toString()+" ratings on verified stays by guests)",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: MyColors.grey30.withOpacity(0.7)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: getReviews(),
                        ),
                      ),
                      Footer()
                    ],
                  ),
                ),
              ),
            ],
      )
    ) :
    Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  getReviews(){
    List<Widget> rating = [];
    for(int i = 0 ; i < (ratings?.length??0); i++)
      {
        rating.add(getReviewCard(i));
      }
    return rating;
  }
  
  getReviewCard(int ind){
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ratings![ind]?.cusName??"",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating: getUserRating(ind),
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                ignoreGestures: true,
                itemSize: 20,
                unratedColor: MyColors.grey10,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: getUserRating(ind).roundToDouble()<=2 ? MyColors.red : getUserRating(ind).roundToDouble()<=3 ? MyColors.yellow800 : MyColors.green500,
                ),
                onRatingUpdate: (double value) {
                },
              ),
              SizedBox(width: 10,),
              Text(
                ratings![ind]?.brDate??"",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: MyColors.grey30.withOpacity(0.5)
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            ratings![ind]?.brReview??"",
            style: TextStyle(
                fontSize: 12,
                color: MyColors.black
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
    sharedPreferences  = await SharedPreferences.getInstance();
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
