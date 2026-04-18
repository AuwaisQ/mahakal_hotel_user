// To parse this JSON data, do
//
// final returnPolicyModel = returnPolicyModelFromJson(jsonString);

import 'dart:convert';

ReturnPolicyModel returnPolicyModelFromJson(String str) =>
    ReturnPolicyModel.fromJson(json.decode(str));

String returnPolicyModelToJson(ReturnPolicyModel data) =>
    json.encode(data.toJson());

class ReturnPolicyModel {
  bool? status;
  List<RefundListElement>? refundList;
  List<SheduleistElement>? scheduleList;

  ReturnPolicyModel({
    this.status,
    this.refundList,
    this.scheduleList,
  });

  factory ReturnPolicyModel.fromJson(Map<String, dynamic> json) =>
      ReturnPolicyModel(
        status: json["status"],
        refundList: json["refundList"] == null
            ? []
            : List<RefundListElement>.from(
                json["refundList"]!.map((x) => RefundListElement.fromJson(x))),
        scheduleList: json["scheduleList"] == null
            ? []
            : List<SheduleistElement>.from(json["scheduleList"]!
                .map((x) => SheduleistElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "refundList": refundList == null
            ? []
            : List<dynamic>.from(refundList!.map((x) => x.toJson())),
        "scheduleList": scheduleList == null
            ? []
            : List<dynamic>.from(scheduleList!.map((x) => x.toJson())),
      };
}

class RefundListElement {
  String? enMessage;
  String? hiMessage;
  int? id;
  int? days;
  int? percent;

  RefundListElement({
    this.enMessage,
    this.hiMessage,
    this.id,
    this.days,
    this.percent,
  });

  factory RefundListElement.fromJson(Map<String, dynamic> json) =>
      RefundListElement(
        enMessage: json["en_message"],
        hiMessage: json["hi_message"],
        id: json["id"],
        days: json["days"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "en_message": enMessage,
        "hi_message": hiMessage,
        "id": id,
        "days": days,
        "percent": percent,
      };
}

class SheduleistElement {
  String? enMessage;
  String? hiMessage;
  int? id;
  int? days;
  int? percent;

  SheduleistElement({
    this.enMessage,
    this.hiMessage,
    this.id,
    this.days,
    this.percent,
  });

  factory SheduleistElement.fromJson(Map<String, dynamic> json) =>
      SheduleistElement(
        enMessage: json["en_message"],
        hiMessage: json["hi_message"],
        id: json["id"],
        days: json["days"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "en_message": enMessage,
        "hi_message": hiMessage,
        "id": id,
        "days": days,
        "percent": percent,
      };
}
