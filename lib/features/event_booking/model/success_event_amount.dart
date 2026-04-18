import 'dart:convert';

SuccessEventAmount successEventAmountFromJson(String str) =>
    SuccessEventAmount.fromJson(json.decode(str));

String successEventAmountToJson(SuccessEventAmount data) =>
    json.encode(data.toJson());

class SuccessEventAmount {
  int status;
  String message;
  int recode;
  List<dynamic> data;

  SuccessEventAmount({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  factory SuccessEventAmount.fromJson(Map<String, dynamic> json) =>
      SuccessEventAmount(
        status: int.tryParse(json["status"].toString()) ?? 0,
        message: json["message"] ?? "",
        recode: int.tryParse(json["recode"].toString()) ?? 0,
        data: List<dynamic>.from(json["data"]?.map((x) => x) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
