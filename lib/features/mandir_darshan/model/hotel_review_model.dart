// To parse this JSON data, do
//
//     final hotelReviewModel = hotelReviewModelFromJson(jsonString);

import 'dart:convert';

HotelReviewModel hotelReviewModelFromJson(String str) =>
    HotelReviewModel.fromJson(json.decode(str));

String hotelReviewModelToJson(HotelReviewModel data) =>
    json.encode(data.toJson());

class HotelReviewModel {
  int status;
  String message;
  int hotelStar;
  int recode;
  List<Hotelreview> hotelreview;

  HotelReviewModel({
    required this.status,
    required this.message,
    required this.hotelStar,
    required this.recode,
    required this.hotelreview,
  });

  factory HotelReviewModel.fromJson(Map<String, dynamic> json) =>
      HotelReviewModel(
        status: json["status"],
        message: json["message"],
        hotelStar: json["hotel_star"],
        recode: json["recode"],
        hotelreview: List<Hotelreview>.from(
            json["hotelreview"].map((x) => Hotelreview.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "hotel_star": hotelStar,
        "recode": recode,
        "hotelreview": List<dynamic>.from(hotelreview.map((x) => x.toJson())),
      };
}

class Hotelreview {
  String? userName;
  int userId;
  String userImage;
  String comment;
  int star;
  DateTime createdAt;

  Hotelreview({
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.comment,
    required this.star,
    required this.createdAt,
  });

  factory Hotelreview.fromJson(Map<String, dynamic> json) => Hotelreview(
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
