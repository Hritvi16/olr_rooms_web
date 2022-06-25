// ignore: file_names
import 'package:olr_rooms_web/model/RequestTypes.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:olr_rooms_web/model/Tickets.dart';

class TicketResponse extends Response{
  List<RequestTypes>? types;
  List<Tickets>? tickets;

  TicketResponse({
    List<Tickets>? tickets
  });

  TicketResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    if (json['types'] != null) {
      types = [];
      json['types'].forEach((v) {
        types?.add(RequestTypes.fromJson(v));
      });
    }
    if (json['tickets'] != null) {
      tickets = [];
      json['tickets'].forEach((v) {
        tickets?.add(Tickets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['types'] = [];
    if (types != null) {
      map['types'] = types?.map((v) => v.toJson()).toList();
    }
    map['tickets'] = [];
    if (tickets != null) {
      map['tickets'] = tickets?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
