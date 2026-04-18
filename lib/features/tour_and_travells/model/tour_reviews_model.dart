// To parse this JSON data, do
//
//     final tourReviewsModel = tourReviewsModelFromJson(jsonString);

import 'dart:convert';

TourReviewsModel tourReviewsModelFromJson(String str) =>
    TourReviewsModel.fromJson(json.decode(str));

String tourReviewsModelToJson(TourReviewsModel data) =>
    json.encode(data.toJson());

class TourReviewsModel {
  int? status;
  String? message;
  String? tourStar;
  int? recode;
  List<TourReviewList>? data;

  TourReviewsModel({
    this.status,
    this.message,
    this.tourStar,
    this.recode,
    this.data,
  });

  factory TourReviewsModel.fromJson(Map<String, dynamic> json) =>
      TourReviewsModel(
        status: json["status"],
        message: json["message"],
        tourStar: json["tour_star"],
        recode: json["recode"],
        data: json["data"] == null
            ? []
            : List<TourReviewList>.from(
                json["data"]!.map((x) => TourReviewList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "tour_star": tourStar,
        "recode": recode,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TourReviewList {
  int? star;
  DateTime? createdAt;
  String? comment;
  String? userName;
  String? userImage;

  TourReviewList({
    this.star,
    this.createdAt,
    this.comment,
    this.userName,
    this.userImage,
  });

  factory TourReviewList.fromJson(Map<String, dynamic> json) => TourReviewList(
        star: json["star"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        comment: json["comment"],
        userName: json["user_name"],
        userImage: json["user_image"],
      );

  Map<String, dynamic> toJson() => {
        "star": star,
        "created_at": createdAt?.toIso8601String(),
        "comment": comment,
        "user_name": userName,
        "user_image": userImage,
      };
}
