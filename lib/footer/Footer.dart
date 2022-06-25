import 'package:flutter/material.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/size/MySize.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: constraints.maxWidth< 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
            : EdgeInsets.symmetric(vertical: MySize.sizeh4(context), horizontal: MySize.size7(context)),
        color: MyColors.colorPrimary.withOpacity(0.2),
        child: getBody(),
      );
    },

    );
  }

  getBody() {
    return Row(
      children: [
        Column(
          children: [
            Image.asset(
              "assets/logo/appbar_logo.png",
              width: 80,
              height: 80,
              fit: BoxFit.fill,
            ),
            Row(
              children: [
                Image.asset(
                  "assets/logo/appbar_logo.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.fill,
                ),
                Image.asset(
                  "assets/logo/appbar_logo.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.fill,
                ),
                Image.asset(
                  "assets/social/facebook.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.fill,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
