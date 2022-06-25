import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/size/MySize.dart';

class MyPopTemplate1 extends StatelessWidget {
  final String desc;
  const MyPopTemplate1({Key? key, required this.desc}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.7,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: MySize.size15(context)),
              padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
              child: Html(
                data: unescape.convert(utf8.decode(base64Decode(desc))),
              ),
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(MySize.sizeh1(context))
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
                  child: Icon(
                      Icons.close
                  ),
                  decoration: BoxDecoration(
                    color: MyColors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
