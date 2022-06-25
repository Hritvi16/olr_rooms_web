import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/PolicyResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Policies extends StatefulWidget {
  final String policy_type, act, h_id;
  const Policies({Key? key, required this.policy_type, required this.act, required this.h_id}) : super(key: key);

  @override
  State<Policies> createState() => _PoliciesState();
}

class _PoliciesState extends State<Policies> {
  bool load = false;
  var unescape = HtmlUnescape();
  String policy_type = "";
  String act = "";
  String policy = "";
  String h_id = "";

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    policy_type = widget.policy_type;
    act = widget.act;
    h_id = widget.h_id;
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
        backgroundColor: MyColors.white,
        key: scaffoldkey,
        endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: policy_type,),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                children: [
                  Padding(
                    padding: constraints.maxWidth < 600 ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 32),
                    child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                        : MenuBar(sharedPreferences: sharedPreferences, name: policy_type),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: constraints.maxWidth < 600 ? null : const EdgeInsets.symmetric(horizontal: 32),
                            padding: constraints.maxWidth< 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
                                : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size5(context)),
                            child: Html(
                              data: unescape.convert(policy),
                            ),
                          ),
                          Footer()
                        ],
                      ),
                    ),
                  )
                ],
            );
          },
        )
    ) : Center(child: CircularProgressIndicator(color: MyColors.colorPrimary,));
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_outlined, color: MyColors.black,)
        ),
        title: Text(policy_type),
        titleTextStyle: TextStyle(
          color: MyColors.black,
          fontSize: 18
        ),
        backgroundColor: MyColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
      ),
      body: load ?
      RefreshIndicator(
        onRefresh: () async {
          await getPolicy();
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Html(
              data: unescape.convert(policy),
            ),
          ),
        ),
      ) :
          Center(
            child: CircularProgressIndicator(
              color: MyColors.colorPrimary,
            ),
          )
    );
  }

  void start() async {
    await getPolicy();
  }

  getPolicy() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> queryParameters = {
      APIConstant.act: act,
      "h_id" : h_id
    };
    PolicyResponse policyResponse = await APIService().getPolicy(queryParameters);
    print(policyResponse.toJson());
    if (policyResponse.status == 'Success' && policyResponse.message == 'Policy Retrieved') {
      policy = policyResponse.data ?? "";
    }
    else
      policy = "";

    policy = utf8.decode(base64Decode(policy));

    load = true;
    setState(() {

    });
  }
}
