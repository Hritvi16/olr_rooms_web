import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/size/MySize.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with TickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // controller.reset();
        // controller.forward();
        Navigator.pop(context);
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: Lottie.asset(
            'assets/lottie/booking_confirm.json',
            controller: controller,
            repeat: true,
            reverse: true,
            animate: true,
            onLoaded: (composition) {
              // Configure the AnimationController with the duration of the
              // Lottie file and start the animation.
              // print("hello");
              controller
                ..duration = composition.duration
                ..forward();
            },
            height: 40,
            width: 40
        ),
        // child: Container(
        //   width: MediaQuery.of(context).size.width,
        //   height: 400,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //
        //           Text(
        //             "Booking Confirmed",
        //             style: TextStyle(
        //               fontSize: 24,
        //               fontWeight: FontWeight.w400
        //             ),
        //           ),
        //         ],
        //       ),
        //       MouseRegion(
        //         cursor: SystemMouseCursors.click,
        //         child: GestureDetector(
        //           onTap: () {
        //             Navigator.pop(context);
        //           },
        //           child: Container(
        //             width: 150,
        //             height: 40,
        //             alignment: Alignment.center,
        //             decoration: BoxDecoration(
        //                 color: MyColors.white,
        //                 border: Border.all(color: MyColors.colorPrimary),
        //                 borderRadius: BorderRadius.circular(20)
        //             ),
        //             child: Text(
        //               "Done",
        //               style: TextStyle(
        //                   fontSize: 20,
        //                   fontWeight: FontWeight.w400
        //               ),
        //             ),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
    );
  }
}
