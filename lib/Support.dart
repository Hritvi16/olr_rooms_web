import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/api/APIConstant.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/header/header.dart';
import 'package:olr_rooms_web/model/RequestTypes.dart';
import 'package:olr_rooms_web/model/RequestTypeResponse.dart';
import 'package:olr_rooms_web/model/Tickets.dart';
import 'package:olr_rooms_web/model/TicketResponse.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/support/RaiseTicket.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  bool load = false;
  List<RequestTypes> request_types = [];
  List<Tickets> tickets = [];
  List<Tickets> show_tickets = [];
  int selected = 0;

  late SharedPreferences sharedPreferences;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return load ? Scaffold(
      key: scaffoldkey,
      endDrawer: CustomDrawer(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey, name: "SUPPORT"),
      backgroundColor: MyColors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Padding(
                  padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                  child: constraints.maxWidth < 600 ? MenuBarM(sharedPreferences: sharedPreferences, scaffoldkey: scaffoldkey)
                      : MenuBar(sharedPreferences: sharedPreferences, name: "SUPPORT"),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                            padding: constraints.maxWidth < 600 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 32),
                            child: constraints.maxWidth < 600 ? getSupportM() : getSupportW()
                        ),
                        Footer()
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        )
    ) :
    Center(
      child: CircularProgressIndicator(
        color: MyColors.colorPrimary,
      ),
    );
  }

  void start() async {
    sharedPreferences = await SharedPreferences.getInstance();
    checkCache();
  }

  getSupportW() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: MySize.sizeh2(context), horizontal: MySize.size7(context)),
        child: Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return RaiseTicket(h_id: "", b_id: "",);
                    },
                  ).then((value) {
                    if(value!=null) {
                      load = false;
                      setState(() {

                      });
                      getRequestedTickets();
                    }
                  });
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    alignment: Alignment.center,
                    width: 130,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    margin: EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                        color: MyColors.colorPrimary,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text(
                      "RAISE TICKET",
                      style: TextStyle(
                          color: MyColors.white,
                          fontSize: 14
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MySize.sizeh3(context),
              child: getRequestTypesDesign(),
            ),
            SizedBox(height: MySize.sizeh2(context),),
            show_tickets.isNotEmpty ?
            getRequestTicketsDesignW() :
            Center(
              child: Text("No Tickets Raised"),
            )
          ],
        )
    );
  }

  getSupportM() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: MySize.sizeh3(context), horizontal: MySize.size3(context)),
        child: Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return RaiseTicket(h_id: "", b_id: "",);
                    },
                  ).then((value) {
                    if(value!=null) {
                      load = false;
                      setState(() {

                      });
                      getRequestedTickets();
                    }
                  });
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    alignment: Alignment.center,
                    width: 80,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    margin: EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                        color: MyColors.colorPrimary,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text(
                      "RAISE TICKET",
                      style: TextStyle(
                          color: MyColors.white,
                          fontSize: 10
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MySize.sizeh3(context),
              child: getRequestTypesDesignM(),
            ),
            SizedBox(
              height: MySize.sizeh2(context),
            ),
            show_tickets.isNotEmpty ?
            getRequestTicketsDesignM() :
            Center(
              child: Text("No Tickets Raised"),
            )
          ],
        )
    );
  }
  void checkCache() {
    print("helloooo");
    CacheManagerUtils.conditionalCache(
        key: "key_ticket",
        valueType: ValueType.BoolValue,
        actionIfNull: () async {
          print("hellooooii");
          load = false;
          setState(() {

          });
          await getRequestedTickets();
        },
        actionIfNotNull: () async {
          print("helloooojj");
          print(await ReadCache.getJson(key: "ticket"));
          TicketResponse ticketResponse = TicketResponse.fromJson(await ReadCache.getJson(key: "ticket"));
          print(ticketResponse.tickets);


          request_types.add(RequestTypes.fromJson({"rt_id": "-1", "rt_type": "All", "rt_message": null, "created_at": null,
            "created_by": null, "updated_at": null, "updated_by": null, "is_delete": null}));
          request_types.addAll(ticketResponse.types ?? []);
          selected = 0;
          tickets = ticketResponse.tickets ?? [];

          await getShowTickets();

          load = true;

          setState(() {

          });
        }
    );
  }

  getRequestTypes() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getAll,
    };
    RequestTypeResponse requestTypeResponse = await APIService().getRequestTypes(queryParameters);

    if(requestTypeResponse.status=="Success" && requestTypeResponse.message=="Request Types Retrieved") {
      request_types.add(RequestTypes.fromJson({"rt_id": "-1", "rt_type": "All", "rt_message": null, "created_at": null,
        "created_by": null, "updated_at": null, "updated_by": null, "is_delete": null}));
      request_types.addAll(requestTypeResponse.data ?? []);
      selected = 0;
    }
    else {
      request_types = [];
      Toast.sendToast(context, requestTypeResponse.message??"");
    }

    setState(() {

    });
  }

  getRequestedTickets() async {
    Map<String, String> queryParameters = {
      APIConstant.act: APIConstant.getByID,
    };
    TicketResponse ticketResponse = await APIService().getRequestedTickets(queryParameters);

    if(ticketResponse.status=="Success" && ticketResponse.message=="Tickets Retrieved") {
      request_types.add(RequestTypes.fromJson({"rt_id": "-1", "rt_type": "All", "rt_message": null, "created_at": null,
        "created_by": null, "updated_at": null, "updated_by": null, "is_delete": null}));
      request_types.addAll(ticketResponse.types ?? []);
      selected = 0;
      tickets = ticketResponse.tickets ?? [];
    }
    else {
      request_types = [];
      tickets = [];
      Toast.sendToast(context, ticketResponse.message??"");
    }

    await WriteCache.setBool(key: "key_ticket", value: true);
    await WriteCache.setJson(key: "ticket", value: ticketResponse.toJson());
    List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
    keys.add("key_ticket");
    keys.add("ticket");
    await WriteCache.setListString(key: "keys", value: keys);

    await getShowTickets();

    load = true;

    setState(() {

    });
  }

  getRequestTypesDesign() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: request_types.length>1 ? request_types.length : 0,
      separatorBuilder: (BuildContext context, index){
        return SizedBox(width: MySize.size1_5(context));
      },
      itemBuilder: (BuildContext context, index){
        return getTypeCard(index);
      },
    );
  }

  getRequestTypesDesignM() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: request_types.length>1 ? request_types.length : 0,
      separatorBuilder: (BuildContext context, index){
        return SizedBox(width: MySize.size1_5(context));
      },
      itemBuilder: (BuildContext context, index){
        return getTypeCardM(index);
      },
    );
  }

  getTypeCard(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          selected = index;
          await getShowTickets();
          setState(() {

          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh02(context)),
          decoration: BoxDecoration(
              color: selected==index ? MyColors.colorPrimary.withOpacity(0.9) : MyColors.white,
              border: Border.all(color: selected==index ? MyColors.grey1 : MyColors.colorPrimary),
              borderRadius: BorderRadius.circular(MySize.sizeh2(context))
          ),
          child: Text(
            request_types[index].rtType??"",
            style: TextStyle(
                color: selected==index ? MyColors.white : MyColors.black,
              fontSize: MySize.font7(context)
            ),
          ),
        ),
      ),
    );
  }

  getTypeCardM(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          selected = index;
          await getShowTickets();
          setState(() {

          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: MySize.size2(context), vertical: MySize.sizeh01(context)),
          decoration: BoxDecoration(
              color: selected==index ? MyColors.colorPrimary.withOpacity(0.9) : MyColors.white,
              border: Border.all(color: selected==index ? MyColors.grey1 : MyColors.colorPrimary),
              borderRadius: BorderRadius.circular(MySize.sizeh2(context))
          ),
          child: Text(
            request_types[index].rtType??"",
            style: TextStyle(
                color: selected==index ? MyColors.white : MyColors.black,
              fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  getRequestTicketsDesignW() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: MySize.sizeh2(context),
          mainAxisSpacing: MySize.sizeh2(context),
          mainAxisExtent: 230
      ),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: show_tickets.length,
      itemBuilder: (BuildContext context, index){
        return getTicketCardW(index);
      },
    );
  }

  getRequestTicketsDesignM() {
    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: show_tickets.length,
      separatorBuilder: (BuildContext context, index){
        return SizedBox(height: MySize.sizeh2(context),);
      },
      itemBuilder: (BuildContext context, index){
        return getTicketCardM(index);
      },
    );
  }
  // decoration: BoxDecoration(
  // color: bookings[index].booking?.bStatus=="BOOKED" ? MyColors.green500 :
  // bookings[index].booking?.bStatus=="CHECKED IN" ? MyColors.blue :
  // bookings[index].booking?.bStatus=="CANCELLED" ? MyColors.yellow800 : MyColors.red,
  // borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))
  // ),
  getTicketCardW(int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: MyColors.grey1),
          borderRadius: BorderRadius.circular(MySize.sizeh055(context))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 26,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: "TICKET NO :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtTicketNo??"",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "BOOKING NO :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].bNo??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "RAISED DATE :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtDate?.substring(0, 10)??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    maxLines: 2,
                    text: TextSpan(
                        text: "TICKET TYPE :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtType??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh025(context),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: MyColors.colorPrimary,
                        size: MySize.sizeh2_5(context),
                      ),
                      SizedBox(width: MySize.size05(context),),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (show_tickets[index].rtMessage??""),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                overflow: TextOverflow.fade,
                                fontSize: MySize.font7(context),
                                color: MyColors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "STATUS :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtStatus??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: "DESCRIPTION :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: (show_tickets[index].rtDesc??""),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    maxLines: 5,
                    text: TextSpan(
                        text: "RAISED FOR :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtTo??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: MySize.sizeh065(context),
                  ),
                  RichText(
                    text: TextSpan(
                        text: "SOLVED DATE :  ",
                        style: TextStyle(
                            fontSize: MySize.font7_25(context),
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtSolvedDate?.substring(0, 10)??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: show_tickets[index].rtStatus=="RAISED" ? MyColors.blue :
                  show_tickets[index].rtStatus=="OPEN" ? MyColors.green500 :
                  show_tickets[index].rtStatus=="IN REVIEW" ? MyColors.yellow800 :
                  show_tickets[index].rtStatus=="CLOSED" ? MyColors.grey30 : MyColors.red,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(MySize.sizeh055(context)), bottomRight: Radius.circular(MySize.sizeh055(context)))
              ),
            ),
          ),
        ],
      ),
    );
  }

  getTicketCardM(int index) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(color: MyColors.grey1),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 32,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MySize.size1(context), vertical: MySize.sizeh1(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: "TICKET NO :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtTicketNo??"",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "BOOKING NO :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].bNo??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "RAISED DATE :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtDate?.substring(0, 10)??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    maxLines: 2,
                    text: TextSpan(
                        text: "TICKET TYPE :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtType??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: MyColors.colorPrimary,
                        size: 14,
                      ),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (show_tickets[index].rtMessage??""),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                overflow: TextOverflow.fade,
                                fontSize: 11,
                                color: MyColors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "STATUS :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtStatus??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: "DESCRIPTION :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: (show_tickets[index].rtDesc??""),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    maxLines: 5,
                    text: TextSpan(
                        text: "RAISED FOR :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtTo??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "SOLVED DATE :  ",
                        style: TextStyle(
                            fontSize: 12,
                            color: MyColors.black
                        ),
                        children: [
                          TextSpan(
                            text: show_tickets[index].rtSolvedDate?.substring(0, 10)??"",
                            style: TextStyle(
                                fontWeight: FontWeight.w700
                            ),
                          )
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: show_tickets[index].rtStatus=="RAISED" ? MyColors.blue :
                  show_tickets[index].rtStatus=="OPEN" ? MyColors.green500 :
                  show_tickets[index].rtStatus=="IN REVIEW" ? MyColors.yellow800 :
                  show_tickets[index].rtStatus=="CLOSED" ? MyColors.grey30 : MyColors.red,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(MySize.sizeh055(context)), bottomRight: Radius.circular(MySize.sizeh055(context)))
              ),
            ),
          ),
        ],
      ),
    );
  }

  getShowTickets() {
    show_tickets = [];
    for(int i = 0; i < tickets.length; i++)
    {
      if(request_types[selected].rtId == "-1" || request_types[selected].rtId==tickets[i].retId)
        show_tickets.add(tickets[i]);
    }
    setState(() {

    });
  }
}
