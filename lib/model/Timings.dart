class Timings {
  int? time;
  String? start;
  String? end;
  int? rooms;
  int? booked;
  String? available;

  Timings({
      int? time, 
      String? start, 
      String? end, 
      int? rooms,
      int? booked,
      String? available,});

  Timings.fromJson(dynamic json) {
    time = json['time'];
    start = json['start'];
    end = json['end'];
    rooms = json['rooms'];
    booked = json['booked'];
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['start'] = start;
    map['end'] = end;
    map['rooms'] = rooms;
    map['booked'] = booked;
    map['available'] = available;
    return map;
  }

}