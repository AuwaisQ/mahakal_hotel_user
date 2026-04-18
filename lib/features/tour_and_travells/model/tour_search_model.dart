// To parse this JSON data, do
//
//     final tourSearchModel = tourSearchModelFromJson(jsonString);

import 'dart:convert';

TourSearchModel tourSearchModelFromJson(String str) =>
    TourSearchModel.fromJson(json.decode(str));

String tourSearchModelToJson(TourSearchModel data) =>
    json.encode(data.toJson());

class TourSearchModel {
  int status;
  int count;
  List<TourSearchData> data;

  TourSearchModel({
    required this.status,
    required this.count,
    required this.data,
  });

  factory TourSearchModel.fromJson(Map<String, dynamic> json) =>
      TourSearchModel(
        status: json["status"],
        count: json["count"],
        data: List<TourSearchData>.from(
            json["data"].map((x) => TourSearchData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TourSearchData {
  int id;
  String name;

  TourSearchData({
    required this.id,
    required this.name,
  });

  factory TourSearchData.fromJson(Map<String, dynamic> json) => TourSearchData(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
