import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:olr_rooms_web/colors/MyColors.dart';
import 'package:olr_rooms_web/size/MySize.dart';
import 'package:olr_rooms_web/toast/Toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetails extends StatefulWidget {
  final int guest, adult, child, max_adult, max_child, limit, available;
  final List<Map<String, dynamic>> rooms;
  const BookingDetails({Key? key, required this.guest, required this.adult, required this.child,  required this.max_adult, required this.max_child, required this.limit, required this.rooms, required this.available}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  DateTime dt = DateTime.now();
  int guest = 1;
  int adult = 1;
  int child = 0;
  int max_adult = 1;
  int max_child = 0;
  int limit = 1;
  int available = 1;

  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    guest = widget.guest;
    adult = widget.adult;
    child = widget.child;
    max_adult = widget.max_adult;
    max_child = widget.max_child;
    limit = widget.limit;
    available = widget.available;

    print("available");
    print(available);

    rooms = widget.rooms;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Dialog(
          insetPadding: constraints.maxWidth < 600 ? EdgeInsets.symmetric(vertical: MySize.sizeh5(context), horizontal: MySize.size5(context))
              : EdgeInsets.symmetric(vertical: MySize.sizeh10(context), horizontal: MySize.size15(context)),
          child: MaterialApp(
            home: DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Select Rooms & Guests"),
                  backgroundColor: MyColors.white,
                  titleTextStyle: TextStyle(
                      color: MyColors.black,
                      fontSize: 20
                  ),
                  leading: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close, color: MyColors.black,)
                    ),
                  ),
                  bottom: TabBar(
                    labelColor: MyColors.colorPrimary,
                    indicatorColor: MyColors.colorPrimary,
                    unselectedLabelColor: MyColors.black,
                    tabs: [
                      // Tab(
                      //   icon: Text(
                      //     "CHECK IN",
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.w300,
                      //       color: MyColors.black,
                      //       fontSize: 12
                      //     ),
                      //   ),
                      //   text: Strings.weekday[ds.weekday-1]+", "+ds.day.toString()+" "+Strings.month[ds.month-1],
                      // ),
                      // Tab(
                      //   icon: Text(
                      //     "CHECK OUT",
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.w300,
                      //       color: MyColors.black,
                      //       fontSize: 12
                      //     ),
                      //   ),
                      //   text: Strings.weekday[de.weekday-1]+", "+de.day.toString()+" "+Strings.month[de.month-1],
                      // ),
                      Tab(
                        icon: Text(
                          rooms.length.toString()+" Room"+(rooms.length>1 ? "s" : ""),
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: MyColors.black,
                              fontSize: 16
                          ),
                        ),
                        child: child>0 ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.man),
                            Text(adult.toString(),
                              style: TextStyle(
                                  color: MyColors.colorPrimary,
                                  fontSize: 16
                              ),
                            ),
                            SizedBox(width: 5,),
                            Icon(Icons.child_friendly),
                            SizedBox(width: 3,),
                            Text(child.toString(),
                              style: TextStyle(
                                  color: MyColors.colorPrimary,
                                  fontSize: 16
                              ),
                            )
                          ],
                        ) :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.man),
                            Text(adult.toString()+" Adult",
                              style: TextStyle(
                                  color: MyColors.colorPrimary,
                                  fontSize: 16
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: MyColors.grey10))
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        guest = adult+child;
                        Map<String, dynamic> data = {"guest" : guest, "adult" : adult, "child" : child, "rooms" : rooms};
                        Navigator.pop(context, data);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                            color: MyColors.green500,
                            borderRadius: BorderRadius.circular(3)
                        ),
                        child: Text(
                          "APPLY",
                          style: TextStyle(
                            color: MyColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    getRoomDetailsDesign(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },

    );
  }

  getCheckinDesign() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(dt.year, dt.month),
        lastDate: DateTime(dt.year, dt.month+6));
  }

  getRoomDetailsDesign(BuildContext buildContext) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.separated(
        itemBuilder: (BuildContext context, index) {
          return getRoomDesign(index, buildContext);
        },
        separatorBuilder: (BuildContext context, index) {
          return SizedBox(height: 10);
        },
        itemCount: rooms.length
      ),
    );
  }

  getRoomDesign(int ind, BuildContext buildContext) {
    return Column(
      children: [
        Container(
          color: MyColors.white,
          child: ExpansionTile(
            collapsedTextColor: MyColors.black,
            collapsedIconColor: MyColors.colorPrimary,
            textColor: MyColors.black,
            iconColor: MyColors.colorPrimary,
            backgroundColor: MyColors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Room "+(ind+1).toString()
                ),
                Text(
                  rooms[ind]['adult'].toString()+(rooms[ind]['adult']>1 ? " Guests" : " Guest")+(rooms[ind]['child']>0 ? ", "+rooms[ind]['child'].toString()+(rooms[ind]['child']>1 ? " Children" : " Child") : "")
                ),
              ],
            ),
            children: [
              Divider(
                thickness: 1,
                color: MyColors.grey10,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: "Adults\n",
                              style: TextStyle(
                                color: MyColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300
                              ),
                              children: [
                                TextSpan(
                                  text: "(5+ years)",
                                  style: TextStyle(
                                      color: MyColors.grey30,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300
                                  )
                                )
                              ]
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: MyColors.grey10.withOpacity(0.3)),
                              color: MyColors.white
                          ),
                          child: Row(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap:() {
                                    if(rooms[ind]['adult']>1) {
                                      rooms[ind]['adult'] -= 1;
                                      adult -= 1;
                                      setState(() {

                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    color: rooms[ind]['adult']>1 ? MyColors.colorPrimary : MyColors.colorPrimary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                rooms[ind]['adult'].toString()
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: (){
                                    if(rooms[ind]['adult']<max_adult && rooms[ind]['adult']+rooms[ind]['child']<limit) {
                                      rooms[ind]['adult'] += 1;
                                      adult += 1;
                                      setState(() {

                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: rooms[ind]['adult']<max_adult && rooms[ind]['adult']+rooms[ind]['child']<limit ? MyColors.colorPrimary : MyColors.colorPrimary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Divider(
                      thickness: 1,
                      color: MyColors.grey10,
                    ),
                    CheckboxListTile(
                      value: rooms[ind]['child']>0 ? true : false,
                      title: Text(
                        "Travelling with children? (0-5 years)",
                        style: TextStyle(
                            color: MyColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                      activeColor: MyColors.colorPrimary,
                      contentPadding: EdgeInsets.all(0),
                      onChanged: (value){
                        print(value);
                        if(value!=null && value) {
                          rooms[ind]['child'] += 1;
                          child += 1;
                        }
                        else {
                          int count = rooms[ind]['child'];
                          print(count);
                          child -= count;
                          rooms[ind]['child'] = 0;
                        }
                        setState(() {

                        });
                      }
                    ),
                    if(rooms[ind]['child']>0)
                      SizedBox(height: 20,),
                    Visibility(
                      visible: rooms[ind]['child']>0 ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: MyColors.grey10)
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.child_care, size: 18,),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "Children",
                                style: TextStyle(
                                    color: MyColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(
                                Icons.info_outline,
                                color: MyColors.colorPrimary.withOpacity(0.8),
                                size: 18,
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                border: Border.all(color: MyColors.grey10.withOpacity(0.3)),
                                color: MyColors.white
                            ),
                            child: Row(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap:() {
                                      if(rooms[ind]['child']>1) {
                                        rooms[ind]['child'] -= 1;
                                        child -= 1;
                                        setState(() {

                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.remove,
                                      color: rooms[ind]['child']>1 ? MyColors.colorPrimary : MyColors.colorPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                    rooms[ind]['child'].toString()
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: (){
                                      if(rooms[ind]['adult']+rooms[ind]['child']<limit) {
                                        rooms[ind]['child'] += 1;
                                        child += 1;
                                        setState(() {

                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.add,
                                      color: rooms[ind]['adult']+rooms[ind]['child']<limit ? MyColors.colorPrimary : MyColors.colorPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
        if(rooms.length==1)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if(rooms.length<available) {
                  rooms.add({"adult": 1, "child": 0});
                  adult += 1;
                  setState(() {

                  });
                }
                else {
                  Toast.sendToast(buildContext, "No more rooms available");
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 2),
                height: 50,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rooms.length<available ? MyColors.white : MyColors.grey.withOpacity(0.3),
                ),
                child: Text(
                  rooms.length<available ? "Add Room" : "No Rooms Available",
                  style: TextStyle(
                      color: rooms.length<available ? MyColors.colorPrimary : MyColors.black,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          )
        else if(rooms.length>1 && ind==rooms.length-1)
          Container(
            margin: EdgeInsets.only(top: 2),
            height: 50,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MyColors.white
            ),
            child: Row(
              children: [
                Flexible(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Map<String, dynamic> map = rooms.last;
                        int a = map['adult'];
                        int c = map['child'];
                        adult -= a;
                        child -= c;
                        rooms.removeLast();
                        setState(() {
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: MyColors.grey10))
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Delete Room",
                          style: TextStyle(
                            color: MyColors.colorPrimary,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
                Flexible(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        print("jdj");
                        if(rooms.length<available) {
                          rooms.add({"adult": 1, "child": 0});
                          adult += 1;
                          setState(() {});
                        }
                        else {
                          print("jdjss");
                          Toast.sendToast(buildContext, "No more rooms available");
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: rooms.length<available ? MyColors.white : MyColors.grey.withOpacity(0.3),
                          border: Border(
                            left: BorderSide(color: MyColors.grey10)
                          )
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          rooms.length<available ? "Add Room" : "No Rooms Available",
                          style: TextStyle(
                              color: rooms.length<available ? MyColors.colorPrimary : MyColors.black,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                ),
              ],
            ),
          )
      ],
    );
  }
}
