import 'package:flutter/material.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/model/CancellationReasonResponse.dart';
import 'package:olr_rooms_web/model/CancellationReasons.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

class CancellationReason extends StatefulWidget {
  // final String b_id, deposit, status;
  final Map<String, dynamic> data;
  const CancellationReason({Key? key, required this.data}) : super(key: key);

  @override
  State<CancellationReason> createState() => _CancellationReasonState();
}

class _CancellationReasonState extends State<CancellationReason> {
  Map<String, dynamic> data = {};

  TextEditingController otherController = TextEditingController();

  List<CancellationReasons> reasons = [];

  bool load = false;
  bool others = false;

  int selected = -1;

  @override
  void initState() {
    data = widget.data;
    getCancellationReasons();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Dialog(
        backgroundColor: Colors.white,
          child: Container(
            width: 500,
            height: 350,
            padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size2(context)),
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    getReasons(),
                    if(others)
                      getDescriptionDesign(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if(selected<0)
                            Toast.sendToast(context, "Please select a reason for cancellation");
                          else
                            cancelBooking();
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: MyColors.colorPrimary,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            "Cancel Booking",
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
        ) :
      Center(
        child: CircularProgressIndicator(
          color: MyColors.colorPrimary,
        ),
      );
  }

  getReasons() {
    return ListView.separated(
      itemCount: reasons.length,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, index) {
        return SizedBox(
          height: 5,
        );
      },
      itemBuilder: (BuildContext context, index) {
        return getReasonsDesign(index);
      },
    );
  }

  getReasonsDesign(int ind) {
    return Row(
      children: [
        Radio(
          value: ind,
          groupValue: selected,
          onChanged: (Object? value) {
            if(value==ind) {
              selected = ind;
              if((reasons[ind].crName??"")=="Other")
                others = true;
              else {
                others = false;
                otherController.text = "";
              }
            }
            setState(() {

            });
            print(value);
          },
        ),
        Text(
          reasons[ind].crName??"",
          style: TextStyle(
              fontSize: 12,
              color: MyColors.black
          ),
        )
      ],
    );
  }

  getDescriptionDesign(){
    return TextFormField(
      controller: otherController,
      maxLines: 5,
      decoration: InputDecoration(
          labelText: "Reason"
      ),
    );
  }

  getCancellationReasons() async {
    CancellationReasonResponse cancellationReasonResponse = await APIService().getCancellationReasons();
    print("cancellationReasonResponse.toJson()");
    print(cancellationReasonResponse.toJson());

    if (cancellationReasonResponse.status == 'Success' && cancellationReasonResponse.message == 'Cancellation Reasons Retrieved')
      reasons = cancellationReasonResponse.data ?? [];
    else
      reasons = [];
    load = true;
    print(reasons);
    setState(() {

    });
  }

  Future<void> cancelBooking() async {
    Map<String, dynamic> data = this.data;
    data.addAll(
      {
        "cr_id" : reasons[selected].crId,
        "desc" : otherController.text
      }
    );
    print(data);

    Response response = await APIService().cancelBooking(data);
    print(response.toJson());

    Toast.sendToast(context, response.message??"");

    if(response.status == 'Success') {
      Map<String, dynamic> data = new Map();
      data[APIConstant.act] = APIConstant.SENDSA;
      data[APIConstant.type] = "3";
      data['id'] = this.data['b_id'];
      // data['id'] = widget.mobile;

      print(data);

      APIService().sendNSE(data);
      Navigator.pop(context, "Success");
    }

  }
}
