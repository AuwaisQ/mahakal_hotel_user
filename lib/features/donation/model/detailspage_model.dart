class DetailsModel {
  DetailsModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final Data? data;

  factory DetailsModel.fromJson(Map<String, dynamic> json) {
    return DetailsModel(
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
    required this.enTrustName,
    required this.hiTrustName,
    required this.enDescription,
    required this.hiDescription,
    required this.id,
    required this.autoStatus,
    required this.image,
  });

  final String enTrustName;
  final String hiTrustName;
  final String enDescription;
  final String hiDescription;
  final int id;
  final int autoStatus;
  final List<String> image;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      enTrustName: json["en_trust_name"] ?? "",
      hiTrustName: json["hi_trust_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      autoStatus: json["auto_pay_set_status"] ?? 0,
      id: json["id"] ?? 0,
      image: json["image"] == null
          ? []
          : List<String>.from(json["image"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "en_trust_name": enTrustName,
        "hi_trust_name": hiTrustName,
        "en_description": enDescription,
        "hi_description": hiDescription,
        "auto_pay_set_status": autoStatus,
        "id": id,
        "image": image.map((x) => x).toList(),
      };

  @override
  String toString() {
    return "$enTrustName, $hiTrustName, $enDescription, $hiDescription, $id, $image, ";
  }
}
