// To parse this JSON data, do
//
//     final mandirSearchModel = mandirSearchModelFromJson(jsonString);

import 'dart:convert';

MandirSearchModel mandirSearchModelFromJson(String str) =>
    MandirSearchModel.fromJson(json.decode(str));

String mandirSearchModelToJson(MandirSearchModel data) =>
    json.encode(data.toJson());

class MandirSearchModel {
  int? status;
  String? message;
  int? recode;
  Mandirsearch? mandirsearch;

  MandirSearchModel({
    this.status,
    this.message,
    this.recode,
    this.mandirsearch,
  });

  factory MandirSearchModel.fromJson(Map<String, dynamic> json) =>
      MandirSearchModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        mandirsearch: json["mandirsearch"] == null
            ? null
            : Mandirsearch.fromJson(json["mandirsearch"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "mandirsearch": mandirsearch?.toJson(),
      };
}

class Mandirsearch {
  List<Temple>? temples;
  List<Restaurant>? restaurants;
  List<Hotel>? hotels;
  List<City>? cities;

  Mandirsearch({
    this.temples,
    this.restaurants,
    this.hotels,
    this.cities,
  });

  factory Mandirsearch.fromJson(Map<String, dynamic> json) => Mandirsearch(
        temples: json["temples"] == null
            ? []
            : List<Temple>.from(
                json["temples"]!.map((x) => Temple.fromJson(x))),
        restaurants: json["restaurants"] == null
            ? []
            : List<Restaurant>.from(
                json["restaurants"]!.map((x) => Restaurant.fromJson(x))),
        hotels: json["hotels"] == null
            ? []
            : List<Hotel>.from(json["hotels"]!.map((x) => Hotel.fromJson(x))),
        cities: json["cities"] == null
            ? []
            : List<City>.from(json["cities"]!.map((x) => City.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "temples": temples == null
            ? []
            : List<dynamic>.from(temples!.map((x) => x.toJson())),
        "restaurants": restaurants == null
            ? []
            : List<dynamic>.from(restaurants!.map((x) => x.toJson())),
        "hotels": hotels == null
            ? []
            : List<dynamic>.from(hotels!.map((x) => x.toJson())),
        "cities": cities == null
            ? []
            : List<dynamic>.from(cities!.map((x) => x.toJson())),
      };
}

class City {
  String? enCity;
  String? hiCity;
  int? id;

  City({
    this.enCity,
    this.hiCity,
    this.id,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        enCity: json["en_city"],
        hiCity: json["hi_city"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "en_city": enCity,
        "hi_city": hiCity,
        "id": id,
      };
}

class Hotel {
  String? enHotelName;
  String? hiHotelName;
  int? id;

  Hotel({
    this.enHotelName,
    this.hiHotelName,
    this.id,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
        enHotelName: json["en_hotel_name"],
        hiHotelName: json["hi_hotel_name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "en_hotel_name": enHotelName,
        "hi_hotel_name": hiHotelName,
        "id": id,
      };
}

class Restaurant {
  String? enRestaurantName;
  String? hiRestaurantName;
  int? id;

  Restaurant({
    this.enRestaurantName,
    this.hiRestaurantName,
    this.id,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        enRestaurantName: json["en_restaurant_name"],
        hiRestaurantName: json["hi_restaurant_name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "en_restaurant_name": enRestaurantName,
        "hi_restaurant_name": hiRestaurantName,
        "id": id,
      };
}

class Temple {
  String? enName;
  String? hiName;
  int? id;

  Temple({
    this.enName,
    this.hiName,
    this.id,
  });

  factory Temple.fromJson(Map<String, dynamic> json) => Temple(
        enName: json["en_name"],
        hiName: json["hi_name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "hi_name": hiName,
        "id": id,
      };
}
