import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/size/MySize.dart';

class MyPopTemplate extends StatelessWidget {
  final String banner;
  const MyPopTemplate({Key? key, required this.banner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              height: MySize.sizeh100(context),
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(8),
              child: Image.network(
                Environment.imageUrl+banner,
                fit: BoxFit.fill,
              ),
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(MySize.size5(context)),
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
