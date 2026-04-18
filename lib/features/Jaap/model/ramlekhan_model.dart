// To parse this JSON data, do
//
//     final ramlekhanModel = ramlekhanModelFromJson(jsonString);

import 'dart:convert';

RamlekhanModel ramlekhanModelFromJson(String str) =>
    RamlekhanModel.fromJson(json.decode(str));

String ramlekhanModelToJson(RamlekhanModel data) => json.encode(data.toJson());

class RamlekhanModel {
  int status;
  List<Ramlekhan> ramlekhan;
  int totalCount;

  RamlekhanModel({
    required this.status,
    required this.ramlekhan,
    required this.totalCount,
  });

  factory RamlekhanModel.fromJson(Map<String, dynamic> json) => RamlekhanModel(
        status: json["status"],
        ramlekhan: List<Ramlekhan>.from(
            json["ramlekhan"].map((x) => Ramlekhan.fromJson(x))),
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "ramlekhan": List<dynamic>.from(ramlekhan.map((x) => x.toJson())),
        "total_count": totalCount,
      };
}

class Ramlekhan {
  int id;
  int userId;
  String type;
  String name;
  String location;
  String count;
  String duration;
  String date;
  String time;
  DateTime createdAt;
  DateTime updatedAt;

  Ramlekhan({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.location,
    required this.count,
    required this.duration,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ramlekhan.fromJson(Map<String, dynamic> json) => Ramlekhan(
        id: json["id"],
        userId: json["user_id"],
        type: json["type"],
        name: json["name"],
        location: json["location"],
        count: json["count"],
        duration: json["duration"],
        date: json["date"],
        time: json["time"],
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
        "duration": duration,
        "date": date,
        "time": time,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
