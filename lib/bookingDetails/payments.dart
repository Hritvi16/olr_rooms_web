import 'dart:html';
import 'package:flutter/material.dart';
import 'package:olr_rooms_web/bookingDetails/UiFake.dart' if (dart.library.html) 'dart:ui' as ui;
class Webpayment extends StatelessWidget{
  final String? name;
  final String? image;
  final String? mobile;
  final String? email;
  final String? order_id;
  final int? price;
  Webpayment({this.name,this.price,this.image, this.mobile, this.order_id, this.email});
  @override
  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory("rzp-html",(int viewId) {
      IFrameElement element=IFrameElement();
      window.onMessage.forEach((element) {
        print('Event Received in callback: ${element.data}');
        if(element.data=='MODAL_CLOSED'){
          Navigator.pop(context);
        }
        else if(element.data=='SUCCESS'){
          Navigator.pop(context, "SUCCESS");
          print('PAYMENT SUCCESSFULL!!!!!!!');
        }
        print("hello");
      });

      element.src='assets/payments.html?name=$name&price=$price&image=$image&mobile=$mobile&email=$email&order_id=$order_id';
      element.style.border = 'none';

      return element;
    });
    return  Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Container(
            child: HtmlElementView(viewType: 'rzp-html'),
          );
        }));
  }

}