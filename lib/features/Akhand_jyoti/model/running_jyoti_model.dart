// To parse this JSON data, do
//
//     final runningJyotiModel = runningJyotiModelFromJson(jsonString);

import 'dart:convert';

RunningJyotiModel runningJyotiModelFromJson(String str) =>
    RunningJyotiModel.fromJson(json.decode(str));

String runningJyotiModelToJson(RunningJyotiModel data) =>
    json.encode(data.toJson());

class RunningJyotiModel {
  bool status;
  bool akhandJyoti;
  String message;

  RunningJyotiModel({
    required this.status,
    required this.akhandJyoti,
    required this.message,
  });

  factory RunningJyotiModel.fromJson(Map<String, dynamic> json) =>
      RunningJyotiModel(
        status: json["status"],
        akhandJyoti: json["akhandJyoti"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "akhandJyoti": akhandJyoti,
        "message": message,
      };
}
