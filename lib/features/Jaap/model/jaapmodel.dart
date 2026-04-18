// To parse this JSON data, do
//
//     final jaapListModel = jaapListModelFromJson(jsonString);

import 'dart:convert';

JaapListModel jaapListModelFromJson(String str) =>
    JaapListModel.fromJson(json.decode(str));

String jaapListModelToJson(JaapListModel data) => json.encode(data.toJson());

class JaapListModel {
  int status;
  List<Jaap> jaap;
  int totalCount;

  JaapListModel({
    required this.status,
    required this.jaap,
    required this.totalCount,
  });

  factory JaapListModel.fromJson(Map<String, dynamic> json) => JaapListModel(
        status: json["status"],
        jaap: List<Jaap>.from(json["jaap"].map((x) => Jaap.fromJson(x))),
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "jaap": List<dynamic>.from(jaap.map((x) => x.toJson())),
        "total_count": totalCount,
      };
}

class Jaap {
  int id;
  int userId;
  String type;
  String name;
  String location;
  int count;
  DateTime createdAt;
  DateTime updatedAt;

  Jaap({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.location,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Jaap.fromJson(Map<String, dynamic> json) => Jaap(
        id: json["id"],
        userId: json["user_id"],
        type: json["type"],
        name: json["name"],
        location: json["location"],
        count: json["count"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "type": type,
        "name": name,
        "location": location,
        "count": count,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
