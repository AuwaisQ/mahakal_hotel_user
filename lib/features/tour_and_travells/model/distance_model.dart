// // To parse this JSON data, do
// //
// //     final distanceModel = distanceModelFromJson(jsonString);
//
// import 'dart:convert';
//
// DistanceModel distanceModelFromJson(String str) => DistanceModel.fromJson(json.decode(str));
//
// String distanceModelToJson(DistanceModel data) => json.encode(data.toJson());
//
// class DistanceModel {
//   int status;
//   String message;
//   int recode;
//   double data;
//
//   DistanceModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.data,
//   });
//
//   factory DistanceModel.fromJson(Map<String, dynamic> json) => DistanceModel(
//     status: json["status"],
//     message: json["message"],
//     recode: json["recode"],
//     data: json["data"]?.toDouble(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "recode": recode,
//     "data": data,
//   };
// }

// To parse this JSON data, do
//
//     final distanceModel = distanceModelFromJson(jsonString);

import 'dart:convert';

DistanceModel distanceModelFromJson(String str) =>
    DistanceModel.fromJson(json.decode(str));

String distanceModelToJson(DistanceModel data) => json.encode(data.toJson());

class DistanceModel {
  int? status;
  String? message;
  int? recode;
  double? data;
  int? exChargeAmount;

  DistanceModel({
    this.status,
    this.message,
    this.recode,
    this.data,
    this.exChargeAmount,
  });

  factory DistanceModel.fromJson(Map<String, dynamic> json) => DistanceModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        data: json["data"]?.toDouble(),
        exChargeAmount: json["ExChargeAmount"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data,
        "ExChargeAmount": exChargeAmount,
      };
}
