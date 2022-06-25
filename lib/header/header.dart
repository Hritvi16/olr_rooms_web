import 'package:blinking_text/blinking_text.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olr_rooms_web/Bookings.dart';
import 'package:olr_rooms_web/Essential.dart';
import 'package:olr_rooms_web/GlobalSearch.dart';
import 'package:olr_rooms_web/SearchList.dart';
import 'package:olr_rooms_web/Support.dart';
import 'package:olr_rooms_web/Wishlist.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/components.dart';
import 'package:olr_rooms_web/header/routes.dart';
import 'package:olr_rooms_web/hotel/hotelDetails/HotelDetails.dart';
import 'package:olr_rooms_web/model/SearchInfo.dart';
import 'package:olr_rooms_web/offers/Offers.dart';
import 'package:olr_rooms_web/policies/Policies.dart';
import 'package:olr_rooms_web/profile/Profile.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/strings/Strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/Home.dart';

class ImageWrapper extends StatelessWidget {
  final String image;

  const ImageWrapper({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO Listen to inherited widget width updates.
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Image.asset(
        image,
        width: width,
        height: width / 1.618,
        fit: BoxFit.cover,
      ),
    );
  }
}

class TagWrapper extends StatelessWidget {
  final List<Tag> tags;

  const TagWrapper({Key? key, this.tags = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: paddingBottom24,
        child: Wrap(
          spacing: 8,
          runSpacing: 0,
          children: <Widget>[...tags],
        ));
  }
}

class Tag extends StatelessWidget {
  final String tag;

  const Tag({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {},
      fillColor: const Color(0xFF242424),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      hoverElevation: 0,
      hoverColor: const Color(0xFFC7C7C7),
      highlightElevation: 0,
      focusElevation: 0,
      child: Text(
        tag,
        style: GoogleFonts.openSans(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class ReadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReadMoreButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(textPrimary),
        side: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return const BorderSide(color: textPrimary, width: 2);
          }

          return const BorderSide(color: textPrimary, width: 2);
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return Colors.white;
          }

          return textPrimary;
        }),
        textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return GoogleFonts.montserrat(
              textStyle: const TextStyle(
                  fontSize: 14, color: Colors.white, letterSpacing: 1),
            );
          }

          return GoogleFonts.montserrat(
            textStyle: const TextStyle(
                fontSize: 14, color: textPrimary, letterSpacing: 1),
          );
        }),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
      ),
      child: const Text(
        "READ MORE",
      ),
    );
  }
}

const Widget divider = Divider(color: Color(0xFFEEEEEE), thickness: 1);
Widget dividerSmall = Container(
  width: 40,
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);

List<Widget> authorSection({String? imageUrl, String? name, String? bio}) {
  return [
    divider,
    Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        children: <Widget>[
          if (imageUrl != null)
            Container(
              margin: const EdgeInsets.only(right: 25),
              child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Image.asset(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: <Widget>[
                if (name != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextHeadlineSecondary(text: name),
                  ),
                if (bio != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      bio,
                      style: bodyTextStyle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    divider,
  ];
}

class PostNavigation extends StatelessWidget {
  const PostNavigation({Key? key}) : super(key: key);

  // TODO Get PostID from Global Routing Singleton.
  // Example: String currentPage = RouteController.of(context).currentPage;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(
              Icons.keyboard_arrow_left,
              size: 25,
              color: textSecondary,
            ),
            Text("PREVIOUS POST", style: buttonTextStyle),
          ],
        ),
        const Spacer(),
        Row(
          children: <Widget>[
            Text("NEXT POST", style: buttonTextStyle),
            const Icon(
              Icons.keyboard_arrow_right,
              size: 25,
              color: textSecondary,
            ),
          ],
        )
      ],
    );
  }
}

class ListNavigation extends StatelessWidget {
  const ListNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(
              Icons.keyboard_arrow_left,
              size: 25,
              color: textSecondary,
            ),
            Text("NEWER POSTS", style: buttonTextStyle),
          ],
        ),
        const Spacer(),
        Row(
          children: <Widget>[
            Text("OLDER POSTS", style: buttonTextStyle),
            const Icon(
              Icons.keyboard_arrow_right,
              size: 25,
              color: textSecondary,
            ),
          ],
        )
      ],
    );
  }
}

// class Footer extends StatelessWidget {
//   const Footer({Key? key}) : super(key: key);
//
//   // TODO Add additional footer components (i.e. about, links, logos).
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: const Align(
//         alignment: Alignment.centerRight,
//         child: TextBody(text: "Copyright © 2020"),
//       ),
//     );
//   }
// }
class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return BlurryContainer(
        blur: 10,
        elevation: 0,
        color: MyColors.colorPrimary.withOpacity(0.2),
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: constraints.maxWidth< 300 ? EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context))
              : EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size1(context)),
          // color: MyColors.colorPrimary.withOpacity(0.1),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.white.withOpacity(0.2),
            //     Colors.white.withOpacity(0.2),
            //   ],
            //   begin: AlignmentDirectional.topStart,
            //   end: AlignmentDirectional.bottomEnd,
            // ),
          ),
          child: getBody(),
        ),
      );
    },

    );
  }

  getBody() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getDivision1(),
            SizedBox(
              width: MySize.size1(context),
            ),
            getDivision2(),
            SizedBox(
              width: MySize.size1(context),
            ),
            getDivision3(),
            SizedBox(
              width: MySize.size1(context),
            ),
            getDivision4(),
          ],
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Copyright © 2020",
            style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font7_5(context)
            ),
          ),
        ),
      ],
    );
  }

  getDivision1() {
    return
      Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/logo/appbar_logo.png",
              width: MySize.size10(context),
              // height: 130,
              color: MyColors.colorPrimary,
              fit: BoxFit.fill,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    "assets/social/facebook.png",
                    width: MySize.size3(context),
                    // height: 30,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    "assets/social/instagram.png",
                    width: MySize.size3(context),
                    // height: 30,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    "assets/social/twitter.png",
                    width: MySize.size3(context),
                    // height: 30,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    "assets/social/youtube.png",
                    width: MySize.size3(context),
                    // height: 30,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Image.asset(
                    "assets/social/pinterest.png",
                    width: MySize.size3(context),
                    // height: 30,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  getDivision2() {
    return
      Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "COMPANY",
              style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font9(context),
                decoration: TextDecoration.underline
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context, 2);
                },
                child: Text(
                  "Become a Partner",
                  style: TextStyle(
                      color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context, 3);
                },
                child: Text(
                  "About Us",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // Essential().directTo(context, 2);
                },
                child: Text(
                  "Contact Us",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context, 4);
                },
                child: Text(
                  "Support",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context, 5);
                },
                child: Text(
                  "Help",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  getDivision3() {
    return
      Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "POLICIES",
              style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font9(context),
                decoration: TextDecoration.underline
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context,11);
                },
                child: Text(
                  "Terms & Conditions",
                  style: TextStyle(
                      color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context,12);
                },
                child: Text(
                  "Guest Policy",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context,13);
                },
                child: Text(
                  "Privacy Policy",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context,14);
                },
                child: Text(
                  "Cancellation Policy",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().directTo(context,15);
                },
                child: Text(
                  "Rules",
                  style: TextStyle(
                color: MyColors.black,
                      fontSize: MySize.font7_5(context)
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  getDivision4() {
    return
      Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "GET IN TOUCH",
              style: TextStyle(
                color: MyColors.black,
                fontSize: MySize.font9(context),
                decoration: TextDecoration.underline
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Registered & Corporate Office",
              style: TextStyle(
                color: MyColors.black,
                  fontSize: MySize.font7_5(context)
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().map(78.44949, 67.88555, "Head Office");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: MyColors.black,
                      size: MySize.size2(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "B-344, SS Web Creation, Second Floor, Royal Trading Tower, Ring Road, Surat - 395003, Gujarat.",
                            style: TextStyle(
                                color: MyColors.black,
                                fontSize: MySize.font7_5(context)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().email("support@olr.com");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: MyColors.black,
                      size: MySize.size2(context),
                    ),
                    Text(
                      "support@olr.com",
                      style: TextStyle(
                          color: MyColors.black,
                          fontSize: MySize.font7_5(context)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Essential().call("9237485858");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.call_outlined,
                      color: MyColors.black,
                      size: MySize.size2(context),
                    ),
                    Text(
                      "9237485858",
                      style: TextStyle(
                          color: MyColors.black,
                          fontSize: MySize.font7_5(context)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class ListItem extends StatelessWidget {
  // TODO replace with Post item model.
  final String title;
  final String? imageUrl;
  final String? description;

  const ListItem(
      {Key? key, required this.title, this.imageUrl, this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (imageUrl != null)
          ImageWrapper(
            image: imageUrl!,
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: marginBottom12,
            child: Text(
              title,
              style: headlineTextStyle,
            ),
          ),
        ),
        if (description != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: marginBottom12,
              child: Text(
                description!,
                style: bodyTextStyle,
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: marginBottom24,
            child: ReadMoreButton(
              onPressed: () => Navigator.pushNamed(context, Routes.post),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: slash_for_doc_comments
/**
 * Menu/Navigation Bar
 *
 * A top menu bar with a text or image logo and
 * navigation links. Navigation links collapse into
 * a hamburger menu on screens smaller than 400px.
 */
class MenuBar extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final String name;
  const MenuBar({Key? key, required this.sharedPreferences, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Essential().directTo(context, 0);
                  },
                  child: Image.asset(
                    "assets/logo/appbar_logo.png",
                    width: 80,
                    height: 80,
                    color: MyColors.colorPrimary,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                width: MySize.size30(context),
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    style: TextStyle(color: MyColors.black, fontSize: 16),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: MyColors.white),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        fillColor: MyColors.white,
                        filled: true,
                        hintText: "Search for Hotel, City or Location",
                        hintStyle: const TextStyle(
                            fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                        )
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  suggestionsCallback: (pattern) async {
                    List<SearchInfo> search_list = await GlobalSearch().search(pattern);
                    // setState((){
                    //
                    // });
                    return search_list;
                  },
                  itemBuilder: (context, SearchInfo suggestion) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        suggestion.search?.name??"",
                        style: const TextStyle(
                            fontSize: 16
                        ),
                      ),
                    );
                  },
                  noItemsFoundBuilder: (context) {
                    return Container(
                      height: 0,
                    );
                  },
                  onSuggestionSelected: (SearchInfo suggestion) {
                    print(suggestion.search?.id);
                    print(suggestion.search?.name);
                    print(suggestion?.type);
                    if((suggestion.type??"")=='hotel') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              HotelDetails(h_id: suggestion.search?.id ?? "",)));
                    }
                    else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              SearchList(id: suggestion.search?.id ?? "", name: suggestion.search?.name ?? "", type: suggestion.type??"",)));
                    }
                  },
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          if(name!='HOME') {
                            Essential().directTo(context, 0);
                          }
                        },
                        style: menuButtonStyle,
                        child: const Text(
                          "HOME",
                        ),
                      ),
                      TextButton(
                        onPressed: () {

                          if(name!='OFFER') {
                            Essential().directTo(context, 1);
                          }
                        },
                        style: menuButtonStyle,
                        child: const Text(
                          "OFFER",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Essential().directTo(context, 2);
                            },
                            child: BlinkText(
                                'BECOME A PARTNER',
                                style: buttonTextStyle,
                                beginColor: MyColors.colorPrimary,
                                endColor: MyColors.grey1,
                                duration: Duration(milliseconds: 200),
                            ),
                          ),
                        ),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     Essential().directTo(context, 2);
                      //   },
                      //   style: menuButtonStyle,
                      //   child: const Text(
                      //     "BECOME A PARTNER",
                      //   ),
                      // ),
                      TextButton(
                        onPressed: () {
                          if(name!='About Us') {
                            Essential().directTo(context, 3);
                          }
                        },
                        style: menuButtonStyle,
                        child: const Text(
                          "ABOUT US",
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: PopupMenuButton(
                          tooltip: "Open Menu",
                          position: PopupMenuPosition.under,
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                                "MORE",
                                style: buttonTextStyle,
                            ),
                          ),
                          itemBuilder: (context) {
                            return List.generate(Strings.more.length, (index) {
                              return PopupMenuItem(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Essential().directTo(context, index+4);
                                    },
                                    child: ListTile(
                                      mouseCursor: SystemMouseCursors.click,
                                      leading: Icon(Strings.moreIcons[index]),
                                      title: Text(Strings.more[index],

                                        style: buttonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                          onSelected: (value) {
                            print(value);
                          },
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: PopupMenuButton(
                          tooltip: "",
                          position: PopupMenuPosition.under,
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              "Hi, "+(sharedPreferences.getString("name")??"Guest"),
                                style: buttonTextStyle,
                            ),
                          ),
                          itemBuilder: (context) {
                            print(Strings.menu.length+1);
                            return List.generate(Strings.menu.length+1, (index) {
                              print(index);
                              print(Strings.menuIcons.length-1);
                              return PopupMenuItem(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      if(sharedPreferences.getString("login_type")=="customer") {
                                          Essential().directTo(context, index+6);
                                        }
                                        else{
                                          Essential().loginPopUp(context);
                                        }
                                    },
                                    child: ListTile(
                                      mouseCursor: SystemMouseCursors.click,
                                      leading: Icon(index!=Strings.menuIcons.length ? Strings.menuIcons[index] : Icons.logout),
                                      title: Text(index!=Strings.menuIcons.length ? Strings.menu[index] : sharedPreferences.getString("login_type")=="customer" ? 'Logout' : "Login",

                                        style: buttonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                          onSelected: (value) {
                            print(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            height: 1,
            // margin: const EdgeInsets.only(bottom: 30),
            color: const Color(0xFFEEEEEE)),
      ],
    );
  }
}

class MenuBarM extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final GlobalKey<ScaffoldState> scaffoldkey;
  MenuBarM({Key? key, required this.sharedPreferences, required this.scaffoldkey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size2(context)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin:  EdgeInsets.symmetric(vertical: MySize.sizeh3(context)),
              child: Row(
                children: <Widget>[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => Home()));
                      },
                      child: Image.asset(
                        "assets/logo/appbar_logo.png",
                        height: MySize.sizeh10(context),
                        color: MyColors.colorPrimary,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Container(
                    width: MySize.size60(context),
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        autofocus: false,
                        style: TextStyle(color: MyColors.black, fontSize: 16),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: MyColors.white),
                                borderRadius: BorderRadius.circular(30)
                            ),
                            fillColor: MyColors.white,
                            filled: true,
                            hintText: "Search for Hotel, City or Location",
                            hintStyle: const TextStyle(
                                fontSize: 12,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                            )
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      suggestionsCallback: (pattern) async {
                        List<SearchInfo> search_list = await GlobalSearch().search(pattern);
                        // setState((){
                        //
                        // });
                        return search_list;
                      },
                      itemBuilder: (context, SearchInfo suggestion) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: Text(
                              suggestion.search?.name??"",
                              style: const TextStyle(
                                  fontSize: 16
                              ),
                            ),
                          ),
                        );
                      },
                      noItemsFoundBuilder: (context) {
                        return Container(
                          height: 0,
                        );
                      },
                      onSuggestionSelected: (SearchInfo suggestion) {
                        if((suggestion.type??"")=='hotel') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  HotelDetails(h_id: suggestion.search?.id ?? "",)));
                        }
                        else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  SearchList(id: suggestion.search?.id ?? "", name: suggestion.search?.name ?? "", type: suggestion.type??"",)));
                        }
                      },
                    ),
                  ),
                  Flexible(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if(scaffoldkey.currentState?.isEndDrawerOpen??true)
                            scaffoldkey.currentState?.closeEndDrawer();
                          else
                            scaffoldkey.currentState?.openEndDrawer();
                        },
                        child: Container(
                            alignment: Alignment.centerRight,
                            child: Icon(
                                  Icons.menu,
                                  color: MyColors.black,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                height: 1,
                // margin: const EdgeInsets.only(bottom: 30),
                color: const Color(0xFFEEEEEE)),
          ],
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  final String name;
  final GlobalKey<ScaffoldState> scaffoldkey;
  CustomDrawer({Key? key, required this.sharedPreferences, required this.scaffoldkey, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: MySize.sizeh2_5(context), horizontal: MySize.size2(context)),
                color: MyColors.black,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon(Icons.account_circle_rounded,
                        //   color: MyColors.grey10, size: 50,),
                        Container(
                          height: MySize.sizeh8(context),
                          width: MySize.size8(context),
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(right: MySize.size5(context)),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyColors.colorPrimary
                          ),
                          child: Text(
                            (sharedPreferences.getString("name")??"Guest").substring(0,1).toUpperCase(),
                            style: TextStyle(
                                color: MyColors.white,
                                fontSize: MySize.font12(context)
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 7,
                          fit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                  visible: sharedPreferences.getString("login_type")=="customer" ? false : true,
                                  child: SizedBox(height: MySize.size5(context),)),
                              Text(
                                "Hi " + (sharedPreferences.getString("name")??"Guest"),
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: MySize.font12(context),
                                    fontWeight: FontWeight.w400),),
                              Visibility(
                                  visible: sharedPreferences.getString("login_type")=="customer" ? true : false,
                                  child: SizedBox(height: MySize.sizeh1(context),)),
                              Visibility(
                                visible: sharedPreferences.getString("login_type")=="customer" ? true : false,
                                child: Text(
                                  (sharedPreferences.getString("code")??"") + "" + (sharedPreferences.getString("mobile")??""),
                                  style: TextStyle(
                                      fontSize: MySize.font10(context),
                                      color: MyColors.grey30,
                                      fontWeight: FontWeight.w300
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: IconButton(
                              onPressed: () {
                                if(sharedPreferences.getString("login_type")=="customer") {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Profile()));
                                }
                                else{
                                  Essential().loginPopUp(context);
                                }
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                size: MySize.sizeh4(context),
                                color: MyColors.grey30,
                              )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MySize.sizeh1(context),),
                    Text("Welcome to OLR ROOMS", style: TextStyle(
                        fontSize: MySize.font13(context),
                        fontWeight: FontWeight.w700,
                        color: MyColors.colorPrimary),),
                  ],
                )
            ),
          ),
          Container(
            color: MyColors.grey1,
            height: 1,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                print(scaffoldkey.currentState?.isEndDrawerOpen);
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                if(name!='HOME') {
                  Essential().directTo(context, 0);
                }
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.home_outlined),
                title: Text('Home'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                Navigator.of(context).pop();

              if(sharedPreferences.getString("login_type")=="customer") {
                Essential().directTo(context, 7);
              }
              else{
                if(name!='WISHLIST') {
                  Essential().loginPopUp(context);
                }
              }
            },
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              leading: Icon(Icons.star_border),
              title: Text('Your Saved Property'),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                if(sharedPreferences.getString("login_type")=="customer") {
                  Essential().directTo(context, 8);
                }
                else{
                  Essential().loginPopUp(context);
                }
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.work),
                title: Text('My Bookings'),
              ),
            ),
          ),
            GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                if(name!='SUPPORT') {
                  Essential().directTo(context, 9);
                }
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.airplane_ticket),
                title: Text('My Tickets'),
              ),
            ),
          GestureDetector(
            onTap: () {
              if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                Navigator.of(context).pop();

              if(name!='OFFER') {
                Essential().directTo(context, 1);
              }
            },
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              leading: Icon(Icons.local_offer_outlined),
              title: Text('Offer'),
            ),
          ),
          GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                Essential().directTo(context, 2);
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.card_membership),
                title: BlinkText(
                  'Become a Partner',
                  style: buttonTextStyle,
                  beginColor: MyColors.colorPrimary,
                  endColor: MyColors.grey1,
                  duration: Duration(milliseconds: 200),
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                Navigator.of(context).pop();

              if(name!='HELPLINE') {
                Essential().directTo(context, 4);
              }
            },
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              leading: Icon(Icons.call_outlined),
              title: Text('Support'),
            ),
          ),
          GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                if(name!='HELP') {
                  Essential().directTo(context, 5);
                }
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.help_outline),
                title: Text('Help'),
              ),
            ),
          GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                if(name!='About Us') {
                  Essential().directTo(context, 3);
                }
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.info_outline_rounded),
                title: Text('About Us'),
              ),
            ),
          // ExpansionTile(
          //   leading: Icon(Icons.policy),
          //   title: Text('Policies & More'),
          //   children: <Widget>[
          //     MouseRegion(
          //       cursor: SystemMouseCursors.click,
          //       child: GestureDetector(
          //         onTap: () {
          //           if (scaffoldkey.currentState?.isEndDrawerOpen??true)
          //             Navigator.of(context).pop();
          //
          //           if(name!='Terms & Conditions') {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) =>
          //                     Policies(
          //                       policy_type: "Terms & Conditions",
          //                       act: APIConstant.getTC,
          //                       h_id: "",
          //                     )
          //                 )
          //             );
          //           }
          //         },
          //         child: ListTile(
          //           mouseCursor: SystemMouseCursors.click,
          //           leading: Icon(Icons.description),
          //           title: Text('Terms & Conditions'),
          //         ),
          //       ),
          //     ),
          //     GestureDetector(
          //         onTap: () {
          //           if (scaffoldkey.currentState?.isEndDrawerOpen??true)
          //             Navigator.of(context).pop();
          //
          //           if(name!='Guest Policy') {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) =>
          //                     Policies(
          //                       policy_type: "Guest Policy",
          //                       act: APIConstant.getGP,
          //                       h_id: "",
          //                     )
          //                 )
          //             );
          //           }
          //         },
          //         child: ListTile(
          //       mouseCursor: SystemMouseCursors.click,
          //           leading: Icon(Icons.local_police_outlined),
          //           title: Text('Guest Policy'),
          //         ),
          //       ),
          //     GestureDetector(
          //         onTap: () {
          //           if (scaffoldkey.currentState?.isEndDrawerOpen??true)
          //             Navigator.of(context).pop();
          //
          //           if(name!='Privacy Policy') {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) =>
          //                     Policies(
          //                       policy_type: "Privacy Policy",
          //                       act: APIConstant.getPP,
          //                       h_id: "",
          //                     )
          //                 )
          //             );
          //           }
          //         },
          //         child: ListTile(
          //       mouseCursor: SystemMouseCursors.click,
          //           leading: Icon(Icons.lock_outline),
          //           title: Text('Privacy Policy'),
          //         ),
          //       ),
          //     GestureDetector(
          //         onTap: () {
          //           if (scaffoldkey.currentState?.isEndDrawerOpen??true)
          //             Navigator.of(context).pop();
          //
          //           if(name!='Cancellation Policy') {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) =>
          //                     Policies(
          //                       policy_type: "Cancellation Policy",
          //                       act: APIConstant.getCP,
          //                       h_id: "",
          //                     )
          //                 )
          //             );
          //           }
          //         },
          //         child: ListTile(
          //       mouseCursor: SystemMouseCursors.click,
          //           leading: Icon(Icons.policy_outlined),
          //           title: Text('Cancellation Policy'),
          //         ),
          //       ),
          //     GestureDetector(
          //         onTap: () {
          //           if (scaffoldkey.currentState?.isEndDrawerOpen??true)
          //             Navigator.of(context).pop();
          //
          //           if(name!='Rules') {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) =>
          //                     Policies(
          //                       policy_type: "Rules",
          //                       act: APIConstant.getR,
          //                       h_id: "",
          //                     )
          //                 )
          //             );
          //           }
          //         },
          //         child: ListTile(
          //       mouseCursor: SystemMouseCursors.click,
          //           leading: Icon(Icons.rule),
          //           title: Text('Rules'),
          //         ),
          //       ),
          //   ],
          // ),
          GestureDetector(
              onTap: () {
                if (scaffoldkey.currentState?.isEndDrawerOpen??true)
                  Navigator.of(context).pop();

                Essential().directTo(context, 10);
              },
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(Icons.logout),
                title: Text(sharedPreferences.getString("login_type")=="customer" ? 'Logout' : "Login"),
              ),
            ),
        ],
      ),
    );
  }
}
