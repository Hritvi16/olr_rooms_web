class Tickets {
  Tickets({
      String? rtId, 
      String? rtTicketNo,
      String? bNo,
      String? retId,
      String? rtType,
      String? rtMessage,
      String? rtDesc,
      String? rtDate, 
      String? rtTo,
      String? hId,
      String? rtSolvedDate,
      String? rtStatus,});

  Tickets.fromJson(dynamic json) {
    rtId = json['rt_id'];
    rtTicketNo = json['rt_ticket_no'];
    bNo = json['b_no'];
    retId = json['ret_id'];
    rtType = json['rt_type'];
    rtMessage = json['rt_message'];
    rtDesc = json['rt_desc'];
    rtDate = json['rt_date'];
    rtTo = json['rt_to'];
    hId = json['h_id'];
    rtSolvedDate = json['rt_solved_date'];
    rtStatus = json['rt_status'];
  }
  String? rtId;
  String? rtTicketNo;
  String? bNo;
  String? retId;
  String? rtType;
  String? rtMessage;
  String? rtDesc;
  String? rtDate;
  String? rtTo;
  String? hId;
  String? rtSolvedDate;
  String? rtStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rt_id'] = rtId;
    map['rt_ticket_no'] = rtTicketNo;
    map['ret_id'] = retId;
    map['rt_type'] = rtType;
    map['rt_message'] = rtMessage;
    map['rt_desc'] = rtDesc;
    map['rt_date'] = rtDate;
    map['rt_to'] = rtTo;
    map['h_id'] = hId;
    map['rt_solved_date'] = rtSolvedDate;
    map['rt_status'] = rtStatus;
    return map;
  }

}