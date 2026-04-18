// To parse this JSON data, do
//
//     final leadGenerateModel = leadGenerateModelFromJson(jsonString);

import 'dart:convert';

LeadGenerateModel leadGenerateModelFromJson(String str) =>
    LeadGenerateModel.fromJson(json.decode(str));

String leadGenerateModelToJson(LeadGenerateModel data) =>
    json.encode(data.toJson());

class LeadGenerateModel {
  int status;
  LeadData data;

  LeadGenerateModel({
    required this.status,
    required this.data,
  });

  factory LeadGenerateModel.fromJson(Map<String, dynamic> json) =>
      LeadGenerateModel(
        status: json["status"],
        data: LeadData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class LeadData {
  int insertId;

  LeadData({
    required this.insertId,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
        insertId: json["insert_id"],
      );

  Map<String, dynamic> toJson() => {
        "insert_id": insertId,
      };
}
