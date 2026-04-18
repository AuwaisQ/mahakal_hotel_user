// To parse this JSON data, do
//
//     final restaurantModel = restaurantModelFromJson(jsonString);

import 'dart:convert';

RestaurantModel restaurantModelFromJson(String str) =>
    RestaurantModel.fromJson(json.decode(str));

String restaurantModelToJson(RestaurantModel data) =>
    json.encode(data.toJson());

class RestaurantModel {
  int status;
  String message;
  int recode;
  List<Restaurant> restaurant;

  RestaurantModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.restaurant,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        restaurant: List<Restaurant>.from(
            json["Restaurant"].map((x) => Restaurant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "Restaurant": List<dynamic>.from(restaurant.map((x) => x.toJson())),
      };
}

class Restaurant {
  String enRestaurantName;
  String enDescription;
  String enMenuHighlights;
  String enMoreDetails;
  int id;
  String latitude;
  String longitude;
  String openTime;
  String closeTime;
  int zipcode;
  int phoneNo;
  String youtubeVideo;
  String emailId;
  String websiteLink;
  String hiRestaurantName;
  String hiDescription;
  String hiMenuHighlights;
  String hiMoreDetails;
  String image;

  Restaurant({
    required this.enRestaurantName,
    required this.enDescription,
    required this.enMenuHighlights,
    required this.enMoreDetails,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    required this.zipcode,
    required this.phoneNo,
    required this.youtubeVideo,
    required this.emailId,
    required this.websiteLink,
    required this.hiRestaurantName,
    required this.hiDescription,
    required this.hiMenuHighlights,
    required this.hiMoreDetails,
    required this.image,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        enRestaurantName: json["en_restaurant_name"],
        enDescription: json["en_description"],
        enMenuHighlights: json["en_menu_highlights"],
        enMoreDetails: json["en_more_details"],
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        openTime: json["open_time"],
        closeTime: json["close_time"],
        zipcode: json["zipcode"],
        phoneNo: json["phone_no"],
        youtubeVideo: json["youtube_video"],
        emailId: json["email_id"],
        websiteLink: json["website_link"],
        hiRestaurantName: json["hi_restaurant_name"],
        hiDescription: json["hi_description"],
        hiMenuHighlights: json["hi_menu_highlights"],
        hiMoreDetails: json["hi_more_details"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "en_restaurant_name": enRestaurantName,
        "en_description": enDescription,
        "en_menu_highlights": enMenuHighlights,
        "en_more_details": enMoreDetails,
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "open_time": openTime,
        "close_time": closeTime,
        "zipcode": zipcode,
        "phone_no": phoneNo,
        "youtube_video": youtubeVideo,
        "email_id": emailId,
        "website_link": websiteLink,
        "hi_restaurant_name": hiRestaurantName,
        "hi_description": hiDescription,
        "hi_menu_highlights": hiMenuHighlights,
        "hi_more_details": hiMoreDetails,
        "image": image,
      };
}
