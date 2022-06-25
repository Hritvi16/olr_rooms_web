/// message : "Child Added"
/// status : "Success"

class Response {
  String? message;
  String? status;

  Response({
    String? message,
    String? status
  });

  Response.fromJson(dynamic json) {
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['status'] = status;
    return map;
  }

}