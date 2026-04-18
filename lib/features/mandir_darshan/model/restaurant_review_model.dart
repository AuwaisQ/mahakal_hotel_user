// To parse this JSON data, do
//
//     final restaurantReviewModel = restaurantReviewModelFromJson(jsonString);

import 'dart:convert';

RestaurantReviewModel restaurantReviewModelFromJson(String str) =>
    RestaurantReviewModel.fromJson(json.decode(str));

String restaurantReviewModelToJson(RestaurantReviewModel data) =>
    json.encode(data.toJson());

class RestaurantReviewModel {
  int status;
  String message;
  int restaurantStar;
  int recode;
  List<Restaurantreview> restaurantreview;

  RestaurantReviewModel({
    required this.status,
    required this.message,
    required this.restaurantStar,
    required this.recode,
    required this.restaurantreview,
  });

  factory RestaurantReviewModel.fromJson(Map<String, dynamic> json) =>
      RestaurantReviewModel(
        status: json["status"],
        message: json["message"],
        restaurantStar: json["restaurant_star"],
        recode: json["recode"],
        restaurantreview: List<Restaurantreview>.from(
            json["restaurantreview"].map((x) => Restaurantreview.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "restaurant_star": restaurantStar,
        "recode": recode,
        "restaurantreview":
            List<dynamic>.from(restaurantreview.map((x) => x.toJson())),
      };
}

class Restaurantreview {
  String? userName;
  int userId;
  String userImage;
  String comment;
  int star;
  DateTime createdAt;
  String? image;

  Restaurantreview({
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.comment,
    required this.star,
    required this.createdAt,
    this.image,
  });

  factory Restaurantreview.fromJson(Map<String, dynamic> json) =>
      Restaurantreview(
        userName: json["user_name"],
        userId: json["user_id"],
        userImage: json["user_image"],
        comment: json["comment"],
        star: json["star"],
        createdAt: DateTime.parse(json["created_at"]),
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "user_id": userId,
        "user_image": userImage,
        "comment": comment,
        "star": star,
        "created_at": createdAt.toIso8601String(),
        "image": image,
      };
}
