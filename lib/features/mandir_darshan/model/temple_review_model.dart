// To parse this JSON data, do
//
//     final templeReviewModel = templeReviewModelFromJson(jsonString);

import 'dart:convert';

TempleReviewModel templeReviewModelFromJson(String str) =>
    TempleReviewModel.fromJson(json.decode(str));

String templeReviewModelToJson(TempleReviewModel data) =>
    json.encode(data.toJson());

class TempleReviewModel {
  int status;
  String message;
  int templeStar;
  int recode;
  List<Templereview> templereview;

  TempleReviewModel({
    required this.status,
    required this.message,
    required this.templeStar,
    required this.recode,
    required this.templereview,
  });

  factory TempleReviewModel.fromJson(Map<String, dynamic> json) =>
      TempleReviewModel(
        status: json["status"],
        message: json["message"],
        templeStar: json["temple_star"],
        recode: json["recode"],
        templereview: List<Templereview>.from(
            json["templereview"].map((x) => Templereview.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "temple_star": templeStar,
        "recode": recode,
        "templereview": List<dynamic>.from(templereview.map((x) => x.toJson())),
      };
}

class Templereview {
  String? userName;
  int userId;
  String userImage;
  String comment;
  int star;
  DateTime createdAt;

  Templereview({
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.comment,
    required this.star,
    required this.createdAt,
  });

  factory Templereview.fromJson(Map<String, dynamic> json) => Templereview(
        userName: json["user_name"],
        userId: json["user_id"],
        userImage: json["user_image"],
        comment: json["comment"],
        star: json["star"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "user_id": userId,
        "user_image": userImage,
        "comment": comment,
        "star": star,
        "created_at": createdAt.toIso8601String(),
      };
}
