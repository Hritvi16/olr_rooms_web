// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:olr_rooms_web/path/path_constant.dart';
//
// class OLRLinks
// {
//
//   FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//   Future<String> createDynamicLink(bool short, String link) async {
//     // setState(() {
//     //   _isCreatingLink = true;
//     // });
//
//     final DynamicLinkParameters parameters = DynamicLinkParameters(
//       uriPrefix: kUriPrefix,
//       link: Uri.parse(kUriPrefix + link),
//       androidParameters: const AndroidParameters(
//         packageName: 'com.ss.olr_rooms_web',
//         minimumVersion: 0,
//       ),
//     );
//
//     Uri url;
//     if (short) {
//       final ShortDynamicLink shortLink =
//       await dynamicLinks.buildShortLink(parameters);
//       url = shortLink.shortUrl;
//     } else {
//       url = await dynamicLinks.buildLink(parameters);
//     }
//
//     // setState(() {
//     //   _linkMessage = url.toString();
//     //   _isCreatingLink = false;
//     // });
//     //
//     // print("_linkMessage");
//     // print(_linkMessage);
//     return url.toString();
//   }
// }