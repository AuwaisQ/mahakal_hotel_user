//
// import 'dart:convert';
//
// EventReviewModel eventReviewModelFromJson(String str) => EventReviewModel.fromJson(json.decode(str));
//
// String eventReviewModelToJson(EventReviewModel data) => json.encode(data.toJson());
//
// class EventReviewModel {
//   int? status;
//   String? message;
//   dynamic eventStar;
//   int? recode;
//   List<EventListModel>? data;
//
//   EventReviewModel({
//     this.status,
//     this.message,
//     this.eventStar,
//     this.recode,
//     this.data,
//   });
//
//   factory EventReviewModel.fromJson(Map<String, dynamic> json) => EventReviewModel(
//     status: json["status"],
//     message: json["message"],
//     eventStar: json["event_star"]?.toDouble(),
//     recode: json["recode"],
//     data: json["data"] == null ? [] : List<EventListModel>.from(json["data"]!.map((x) => EventListModel.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "event_star": eventStar,
//     "recode": recode,
//     "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
//   };
// }
//
// class EventListModel {
//   int? star;
//   String? createdAt;
//   String? comment;
//   String? userName;
//   int? isEdited;
//   String? userImage;
//
//   EventListModel({
//     this.star,
//     this.createdAt,
//     this.comment,
//     this.userName,
//     this.isEdited,
//     this.userImage,
//   });
//
//   factory EventListModel.fromJson(Map<String, dynamic> json) => EventListModel(
//     star: json["star"],
//     createdAt: json["created_at"],
//     comment: json["comment"],
//     userName: json["user_name"],
//     isEdited: json["is_edited"],
//     userImage: json["user_image"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "star": star,
//     "created_at": createdAt,
//     "comment": comment,
//     "user_name": userName,
//     "is_edited": isEdited,
//     "user_image": userImage,
//   };
// }

import 'dart:convert';

EventReviewModel eventReviewModelFromJson(String str) =>
    EventReviewModel.fromJson(json.decode(str));

String eventReviewModelToJson(EventReviewModel data) =>
    json.encode(data.toJson());

class EventReviewModel {
  final int status;
  final String message;
  final double eventStar;
  final int recode;
  final List<EventListModel> data;

  EventReviewModel({
    int? status,
    String? message,
    dynamic eventStar,
    int? recode,
    List<EventListModel>? data,
  })  : status = status ?? 0,
        message = message ?? '',
        eventStar = _parseDouble(eventStar),
        recode = recode ?? 0,
        data = data ?? [];

  factory EventReviewModel.fromJson(Map<String, dynamic> json) =>
      EventReviewModel(
        status: json["status"] as int?,
        message: json["message"] as String?,
        eventStar: json["event_star"],
        recode: json["recode"] as int?,
        data: json["data"] is List
            ? List<EventListModel>.from((json["data"] as List).map(
                (x) => EventListModel.fromJson(x as Map<String, dynamic>),
              ))
            : [],
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "event_star": eventStar,
        "recode": recode,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return 'EventReviewModel('
        'status: $status, '
        'message: $message, '
        'eventStar: $eventStar, '
        'recode: $recode, '
        'data: ${data.length} items)';
  }
}

class EventListModel {
  final int star;
  final String createdAt;
  final String comment;
  final String userName;
  final bool isEdited;
  final String userImage;

  EventListModel({
    int? star,
    String? createdAt,
    String? comment,
    String? userName,
    int? isEdited,
    String? userImage,
  })  : star = star ?? 0,
        createdAt = createdAt ?? '',
        comment = comment ?? '',
        userName = userName ?? 'Anonymous',
        isEdited = (isEdited ?? 0) == 1,
        userImage = userImage ?? '';

  factory EventListModel.fromJson(Map<String, dynamic> json) => EventListModel(
        star: json["star"] as int?,
        createdAt: json["created_at"] as String?,
        comment: json["comment"] as String?,
        userName: json["user_name"] as String?,
        isEdited: json["is_edited"] as int?,
        userImage: json["user_image"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "star": star,
        "created_at": createdAt,
        "comment": comment,
        "user_name": userName,
        "is_edited": isEdited ? 1 : 0,
        "user_image": userImage,
      };

  @override
  String toString() {
    return 'EventListModel('
        'star: $star, '
        'createdAt: $createdAt, '
        'comment: ${comment.length > 20 ? '${comment.substring(0, 20)}...' : comment}, '
        'userName: $userName, '
        'isEdited: $isEdited)';
  }
}
