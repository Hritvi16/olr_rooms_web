import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_browser/web_browser.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Invoice extends StatefulWidget {
  final String b_id, action;
  const Invoice({Key? key, required this.b_id, required this.action}) : super(key: key);

  @override
  InvoiceState createState() => InvoiceState();
}

class InvoiceState extends State<Invoice> {
  String url = "";
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    url = 'http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+widget.b_id+'&action='+widget.action;
    print('http://vijaywargiya.rupayweb.in/OLR/admin/flut-invoice.php?b_id='+widget.b_id+'&action='+widget.action);
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return widget.action=="VIEW" ?
     WebView(
      initialUrl: url,
    ) :  WebBrowser(
      initialUrl: url,
      javascriptEnabled: true,
    );
  }
}