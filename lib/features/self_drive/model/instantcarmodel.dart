// To parse this JSON data, do
//
//     final instantCarModel = instantCarModelFromJson(jsonString);

import 'dart:convert';

InstantCarModel instantCarModelFromJson(String str) => InstantCarModel.fromJson(json.decode(str));

String instantCarModelToJson(InstantCarModel data) => json.encode(data.toJson());

class InstantCarModel {
  int? status;
  String? message;
  Data? data;

  InstantCarModel({
    this.status,
    this.message,
    this.data,
  });

  factory InstantCarModel.fromJson(Map<String, dynamic> json) => InstantCarModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? leadId;
  List<CarAvailable>? carAvailable;

  Data({
    this.leadId,
    this.carAvailable,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leadId: json["lead_id"],
    carAvailable: json["car_available"] == null ? [] : List<CarAvailable>.from(json["car_available"]!.map((x) => CarAvailable.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lead_id": leadId,
    "car_available": carAvailable == null ? [] : List<dynamic>.from(carAvailable!.map((x) => x.toJson())),
  };
}

class CarAvailable {
  int? id;
  String? icon;
  int? waitingCharge;
  int? width;
  int? height;
  int? length;
  int? seats;
  String? vehicleType;
  String? vehicleCategory;
  int? vehicleId;
  int? price;
  int? perKmCharge;

  CarAvailable({
    this.id,
    this.icon,
    this.waitingCharge,
    this.width,
    this.height,
    this.length,
    this.seats,
    this.vehicleType,
    this.vehicleCategory,
    this.vehicleId,
    this.price,
    this.perKmCharge,
  });

  factory CarAvailable.fromJson(Map<String, dynamic> json) => CarAvailable(
    id: json["id"],
    icon: json["icon"],
    waitingCharge: json["waiting_charge"],
    width: json["width"],
    height: json["height"],
    length: json["length"],
    seats: json["seats"],
    vehicleType: json["vehicle_type"],
    vehicleCategory: json["vehicle_category"],
    vehicleId: json["vehicle_category_id"],
    price: json["price"],
    perKmCharge: json["per_km_charge"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "icon": icon,
    "waiting_charge": waitingCharge,
    "width": width,
    "height": height,
    "length": length,
    "seats": seats,
    "vehicle_type": vehicleType,
    "vehicle_category": vehicleCategory,
    "vehicle_category_id": vehicleId,
    "price": price,
    "per_km_charge": perKmCharge,
  };
}
