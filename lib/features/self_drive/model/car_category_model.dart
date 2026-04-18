// To parse this JSON data, do
//
//     final CarCategoryModel = CarCategoryModelFromJson(jsonString);

import 'dart:convert';

CarCategoryModel CarCategoryModelFromJson(String str) => CarCategoryModel.fromJson(json.decode(str));

String CarCategoryModelToJson(CarCategoryModel data) => json.encode(data.toJson());

class CarCategoryModel {
  int? status;
  String? message;
  List<CarList>? carList;

  CarCategoryModel({
    this.status,
    this.message,
    this.carList,
  });

  factory CarCategoryModel.fromJson(Map<String, dynamic> json) => CarCategoryModel(
    status: json['status'],
    message: json['message'],
    carList: json['car_list'] == null ? [] : List<CarList>.from(json['car_list']!.map((x) => CarList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'car_list': carList == null ? [] : List<dynamic>.from(carList!.map((x) => x.toJson())),
  };
}

class CarList {
  int? id;
  String? enBrandName;
  String? hiBrandName;
  String? image;

  CarList({
    this.id,
    this.enBrandName,
    this.hiBrandName,
    this.image,
  });

  factory CarList.fromJson(Map<String, dynamic> json) => CarList(
    id: json['id'],
    enBrandName: json['en_brand_name'],
    hiBrandName: json['hi_brand_name'],
    image: json['image'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'en_brand_name': enBrandName,
    'hi_brand_name': hiBrandName,
    'image': image,
  };
}
