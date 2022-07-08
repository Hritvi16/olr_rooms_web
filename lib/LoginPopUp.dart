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
            width: 120,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg,
                  style: TextStyle(
                      fontSize:  16
                  ),
                ),
                SizedBox(
                  height: 10,
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
                              fontSize:  14
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
                              fontSize:  14
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
