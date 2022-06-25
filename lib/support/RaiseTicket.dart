import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/formatter/UpperCaseTextFormatter.dart';
import 'package:olr_rooms_web/model/RequestTypeResponse.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/toast/Toast.dart';

import '../api/APIConstant.dart';

class RaiseTicket extends StatefulWidget {
  final String h_id, b_id;
  const RaiseTicket({Key? key, required this.h_id, required this.b_id}) : super(key: key);

  @override
  State<RaiseTicket> createState() => _RaiseTicketState();
}

class _RaiseTicketState extends State<RaiseTicket> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool load = false;
  List<String> request_id = [];
  List<String> request_types = [];
  String h_id = "";
  String? ret_type = null;

  TextEditingController bno = TextEditingController();
  TextEditingController desc = TextEditingController();

  @override
  void initState() {
    h_id = widget.h_id;
    bno.text = widget.b_id;
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: load ?
      Dialog(
          child: RefreshIndicator(
            onRefresh: () async {
              await getRequestTypes();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              width: 500,
              height: 400,
              child: Column(
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
                  TextFormField(
                    controller: bno,
                    enabled: h_id.isEmpty,
                    readOnly: h_id.isNotEmpty,
                    inputFormatters: [
                      UpperCaseTextFormatter()
                    ],
                    decoration: InputDecoration(
                        labelText: "Booking No"
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: ret_type,
                    hint: Text("Select Request Type"),
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        ret_type = newValue;
                      });
                    },
                    items: request_types.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: desc,
                    maxLines: 4,
                    decoration: InputDecoration(
                        labelText: "Description"
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if(validate())
                          raiseTicket();
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: MyColors.colorPrimary,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(
                          "RAISE TICKET",
                          style: TextStyle(
                            color: MyColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
      ) : Center(
        child: CircularProgressIndicator(
          color: MyColors.colorPrimary,
        ),
      ),
    );
  }

  void start() {
    getRequestTypes();
  }

  getRequestTypes() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getAll,
    };
    RequestTypeResponse requestTypeResponse = await APIService().getRequestTypes(queryParameters);
    print("requestTypeResponse.toJson()");
    print(requestTypeResponse.toJson());

    if(requestTypeResponse.status=="Success" && requestTypeResponse.message=="Request Types Retrieved") {
      int len = requestTypeResponse.data?.length??0;
      if(len > 0) {
        for (int i = 0; i < len; i++) {
          request_types.add(requestTypeResponse.data?[i].rtType??"");
          request_id.add(requestTypeResponse.data?[i].rtId??"");
        }
      }
      else {
        request_types = [];
        request_id = [];
      }
    }
    else {
      request_types = [];
      Toast.sendToast(context, requestTypeResponse.message??"");
    }
    load = true;

    setState(() {

    });
  }

  bool validate() {
    if(ret_type==null) {
      Toast.sendToast(context, "Select Request Type");
      return false;
    }
    else if(desc.text.isEmpty) {
      Toast.sendToast(context, "Please write description.");
      return false;
    }
    return true;
  }

  raiseTicket() async {
    Map<String, String> data = {
      APIConstant.act: APIConstant.add,
      "b_no": bno.text,
      "ret_id": request_id[request_types.indexOf(ret_type??"")],
      "rt_desc":desc.text,
      if(h_id.isNotEmpty)
        "h_id" : h_id,
      "rt_to" : h_id.isEmpty ? "OLR" : "HOTEL"
    };
    Response response = await APIService().raiseTicket(data);
    print("response.toJson()");
    print(response.toJson());

    if(response.status=="Success" && response.message=="Ticket Raised Successfully") {
      print("response.toJson()sss");
      Toast.sendToast(context, response.message??"");
      Navigator.pop(context, "refresh");
    }
    else {
      Toast.sendToast(context, response.message??"");
    }
  }
}
