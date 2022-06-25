import 'package:flutter/material.dart';
import 'package:olr_rooms_web/size/MySize.dart';

import 'colors/MyColors.dart';

class LoginPopUp extends StatelessWidget {
  final String msg, key1, key2;
  const LoginPopUp({Key? key, required this.msg, required this.key1, required this.key2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: MediaQuery.of(context).size.width/3,
            padding: EdgeInsets.fromLTRB(MySize.size3(context), MySize.size2(context), MySize.size3(context), MySize.size2(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg,
                  style: TextStyle(
                      fontSize:  constraints.maxWidth < 600 ? MySize.font9(context) : MySize.font7_75(context)
                  ),
                ),
                SizedBox(
                  height: MySize.sizeh3(context),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, key1);
                        },
                        child: Text(key1,
                          style: TextStyle(
                              color: MyColors.colorPrimary,
                              fontSize:  constraints.maxWidth < 600 ? MySize.font9(context) : MySize.font7_75(context)
                          ),
                        )
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, key2);
                        },
                        child: Text(key2,
                          style: TextStyle(
                              color: MyColors.colorPrimary,
                              fontSize:  constraints.maxWidth < 600 ? MySize.font9(context) : MySize.font7_75(context)
                          ),
                        )
                    ),
                  ],
                ),
              ],
            ),
          );
        },

      )
    );
  }
}
