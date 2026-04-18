// // To parse this JSON data, do
// //
// // final returnPolicyModel = returnPolicyModelFromJson(jsonString);
//
// import 'dart:convert';
//
// ReturnPolicyModel returnPolicyModelFromJson(String str) => ReturnPolicyModel.fromJson(json.decode(str));
//
// String returnPolicyModelToJson(ReturnPolicyModel data) => json.encode(data.toJson());
//
// class ReturnPolicyModel {
//   bool? status;
//   List<RefundListElement>? refundList;
//   List<SheduleistElement>? scheduleList;
//
//   ReturnPolicyModel({
//     this.status,
//     this.refundList,
//     this.scheduleList,
//   });
//
//   factory ReturnPolicyModel.fromJson(Map<String, dynamic> json) => ReturnPolicyModel(
//     status: json["status"],
//     refundList: json["refundList"] == null ? [] : List<RefundListElement>.from(json["refundList"]!.map((x) => RefundListElement.fromJson(x))),
//     scheduleList: json["scheduleList"] == null ? [] : List<SheduleistElement>.from(json["scheduleList"]!.map((x) => SheduleistElement.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "refundList": refundList == null ? [] : List<dynamic>.from(refundList!.map((x) => x.toJson())),
//     "scheduleList": scheduleList == null ? [] : List<dynamic>.from(scheduleList!.map((x) => x.toJson())),
//   };
// }
//
// class RefundListElement {
//   String? enMessage;
//   String? hiMessage;
//   int? id;
//   int? days;
//   int? percent;
//
//   RefundListElement({
//     this.enMessage,
//     this.hiMessage,
//     this.id,
//     this.days,
//     this.percent,
//   });
//
//   factory RefundListElement.fromJson(Map<String, dynamic> json) => RefundListElement(
//     enMessage: json["en_message"],
//     hiMessage: json["hi_message"],
//     id: json["id"],
//     days: json["days"],
//     percent: json["percent"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_message": enMessage,
//     "hi_message": hiMessage,
//     "id": id,
//     "days": days,
//     "percent": percent,
//   };
// }
//
// class SheduleistElement {
//   String? enMessage;
//   String? hiMessage;
//   int? id;
//   int? days;
//   int? percent;
//
//   SheduleistElement({
//     this.enMessage,
//     this.hiMessage,
//     this.id,
//     this.days,
//     this.percent,
//   });
//
//   factory SheduleistElement.fromJson(Map<String, dynamic> json) => SheduleistElement(
//     enMessage: json["en_message"],
//     hiMessage: json["hi_message"],
//     id: json["id"],
//     days: json["days"],
//     percent: json["percent"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_message": enMessage,
//     "hi_message": hiMessage,
//     "id": id,
//     "days": days,
//     "percent": percent,
//   };
// }

class ReturnPolicyModel {
  ReturnPolicyModel({
    required this.status,
    required this.refundList,
    required this.scheduleList,
  });

  final bool status;
  final List<RefundListElement> refundList;
  final List<RefundListElement> scheduleList;

  factory ReturnPolicyModel.fromJson(Map<String, dynamic> json) {
    return ReturnPolicyModel(
      status: json["status"] ?? false,
      refundList: json["refundList"] == null
          ? []
          : List<RefundListElement>.from(
              json["refundList"]!.map((x) => RefundListElement.fromJson(x))),
      scheduleList: json["scheduleList"] == null
          ? []
          : List<RefundListElement>.from(
              json["scheduleList"]!.map((x) => RefundListElement.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "refundList": refundList.map((x) => x.toJson()).toList(),
        "scheduleList": scheduleList.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $refundList, $scheduleList, ";
  }
}

class RefundListElement {
  RefundListElement({
    required this.enMessage,
    required this.hiMessage,
    required this.id,
    required this.days,
    required this.percent,
  });

  final String enMessage;
  final String hiMessage;
  final int id;
  final int days;
  final int percent;

  factory RefundListElement.fromJson(Map<String, dynamic> json) {
    return RefundListElement(
      enMessage: json["en_message"] ?? "",
      hiMessage: json["hi_message"] ?? "",
      id: json["id"] ?? 0,
      days: json["days"] ?? 0,
      percent: json["percent"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "en_message": enMessage,
        "hi_message": hiMessage,
        "id": id,
        "days": days,
        "percent": percent,
      };

  @override
  String toString() {
    return "$enMessage, $hiMessage, $id, $days, $percent, ";
  }
}
