import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

class Ratings extends StatefulWidget {
  final String id, h_id;
  const Ratings({Key? key, required this.id, required this.h_id}) : super(key: key);

  @override
  State<Ratings> createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  Map<String, dynamic> data = {};

  TextEditingController review = TextEditingController();
  double location = 0;
  double food = 0;
  double staff = 0;
  double cleanliness = 0;
  double facilities = 0;

  String? id = "";
  String? h_id = "";

  bool ignore = false;


  @override
  void initState() {
    id = widget.id;
    h_id = widget.h_id;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
            child: Container(
              width: 500,
              height: 400,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  getRatingDesign("Location"),
                  SizedBox(
                    height: 7,
                  ),
                  getRatingDesign("Food"),
                  SizedBox(
                    height: 7,
                  ),
                  getRatingDesign("Staff"),
                  SizedBox(
                    height: 7,
                  ),
                  getRatingDesign("Cleanliness"),
                  SizedBox(
                    height: 7,
                  ),
                  getRatingDesign("Facilities"),
                  TextFormField(
                    controller: review,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Review"
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if(!ignore) {
                          ignore = true;
                          setState(() {

                          });
                          giveRatings();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: MyColors.colorPrimary,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(
                          "SUBMIT",
                          style: TextStyle(
                              fontSize: 20,
                              color: MyColors.white
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  getRatingDesign(String label) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 20
            ),
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: RatingBar.builder(
            initialRating: label=='Location' ? location : label=='Food' ? food : label=='Staff' ? staff : label=='Cleanliness' ? cleanliness : facilities,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 22,
            unratedColor: MyColors.grey10,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: getRatingColor(label=='Location' ? location : label=='Food' ? food : label=='Staff' ? staff : label=='Cleanliness' ? cleanliness : facilities),
            ),
            onRatingUpdate: (double value) {
              if(label=='Location')
                location = value;
              else if(label=='Food')
                food = value;
              else if(label=='Staff')
                staff = value;
              else if(label=='Cleanliness')
                cleanliness = value;
              else
                facilities = value;

              setState(() {

              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> giveRatings() async {
    Map<String, dynamic> data = {
      APIConstant.act : APIConstant.add,
      "br_location" : location.toString(),
      "br_food" : food.toString(),
      "br_staff" : staff.toString(),
      "br_cleanliness" : cleanliness.toString(),
      "br_facilities" : facilities.toString(),
      "br_review" : review.text,
      "avg" : ((location+food+staff+cleanliness+facilities)/5).toString(),
      "id" : id,
      "h_id" : h_id,
    };
    print(data);

    Response response = await APIService().giveRatings(data);
    print(response.toJson());

    Toast.sendToast(context, response.message??"");

    if(response.status == 'Success') {
      Navigator.pop(context, "Success");
    }
    ignore = false;
    setState(() {

    });

  }

  getRatingColor(double rating) {
    return rating<=2 ? MyColors.red : rating<=3 ? MyColors.yellow800 : MyColors.green500;
  }
}
