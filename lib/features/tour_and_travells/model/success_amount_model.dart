// To parse this JSON data, do
//
//     final successAmountModel = successAmountModelFromJson(jsonString);

import 'dart:convert';

SuccessAmountModel successAmountModelFromJson(String str) =>
    SuccessAmountModel.fromJson(json.decode(str));

String successAmountModelToJson(SuccessAmountModel data) =>
    json.encode(data.toJson());

class SuccessAmountModel {
  int status;
  String message;
  List<dynamic> data;

  SuccessAmountModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SuccessAmountModel.fromJson(Map<String, dynamic> json) =>
      SuccessAmountModel(
        status: json["status"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
