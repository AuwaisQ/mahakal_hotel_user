// To parse this JSON data, do
//
//     final carListModel = carListModelFromJson(jsonString);

import 'dart:convert';

CarListModel carListModelFromJson(String str) => CarListModel.fromJson(json.decode(str));

String carListModelToJson(CarListModel data) => json.encode(data.toJson());

class CarListModel {
  int? status;
  String? message;
  List<CarsDatum>? carsData;

  CarListModel({
    this.status,
    this.message,
    this.carsData,
  });

  factory CarListModel.fromJson(Map<String, dynamic> json) => CarListModel(
    status: json['status'],
    message: json['message'],
    carsData: json['cars_data'] == null ? [] : List<CarsDatum>.from(json['cars_data']!.map((x) => CarsDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'cars_data': carsData == null ? [] : List<dynamic>.from(carsData!.map((x) => x.toJson())),
  };
}

class CarsDatum {
  int? id;
  String? slug;
  String? carType;
  int? basicPrice;
  String? dayType;
  String? fuelType;
  String? enCabName;
  int? cabSeat;
  int? airConditioning;
  int? rating;
  String? hiCabName;
  String? thumbnail;
  List<String>? images;

  CarsDatum({
    this.id,
    this.slug,
    this.carType,
    this.basicPrice,
    this.dayType,
    this.fuelType,
    this.enCabName,
    this.cabSeat,
    this.airConditioning,
    this.rating,
    this.hiCabName,
    this.thumbnail,
    this.images,
  });

  factory CarsDatum.fromJson(Map<String, dynamic> json) => CarsDatum(
    id: json['id'],
    slug: json['slug'],
    carType: json['car_type'],
    basicPrice: json['basic_price'],
    dayType: json['self_tour_type'],
    fuelType: json['fuel_type'],
    enCabName: json['en_cab_name'],
    cabSeat: json['cab_seat'],
    airConditioning: json['air_conditioning'],
    rating: json['rating'],
    hiCabName: json['hi_cab_name'],
    thumbnail: json['thumbnail'],
    images: json['images'] == null ? [] : List<String>.from(json['images']!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'car_type': carType,
    'basic_price': basicPrice,
    'self_tour_type': dayType,
    'fuel_type': fuelType,
    'en_cab_name': enCabName,
    'cab_seat': cabSeat,
    'air_conditioning': airConditioning,
    'rating': rating,
    'hi_cab_name': hiCabName,
    'thumbnail': thumbnail,
    'images': images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
  };
}
