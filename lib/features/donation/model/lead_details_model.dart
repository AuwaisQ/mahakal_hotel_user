class LeadDetailsModel {
  LeadDetailsModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final Data? data;

  factory LeadDetailsModel.fromJson(Map<String, dynamic> json) {
    return LeadDetailsModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return "$status, $message, $recode, $data, ";
  }
}

class Data {
  Data({
    required this.id,
  });

  final String id;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
      };

  @override
  String toString() {
    return "$id, ";
  }
}
