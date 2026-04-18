// import 'dart:convert';
//
// AdvertisementModel advertisementModelFromJson(String str) => AdvertisementModel.fromJson(json.decode(str));
//
// String advertisementModelToJson(AdvertisementModel data) => json.encode(data.toJson());
//
//
// class AdvertisementModel {
//   int status;
//   String message;
//   int recode;
//   List<AdvertiseMent> data;
//
//   AdvertisementModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.data,
//   });
//
//   factory AdvertisementModel.fromJson(Map<String, dynamic> json) => AdvertisementModel(
//     status: json["status"],
//     message: json["message"],
//     recode: json["recode"],
//     data: List<AdvertiseMent>.from(json["data"].map((x) => AdvertiseMent.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "recode": recode,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// class AdvertiseMent {
//   String? enName;
//   String? hiName;
//   String? enDescription;
//   String? hiDescription;
//   int id;
//   String? image;
//
//   AdvertiseMent({
//     this.enName,
//     this.hiName,
//     this.enDescription,
//     this.hiDescription,
//     required this.id,
//     this.image,
//   });
//
//   factory AdvertiseMent.fromJson(Map<String, dynamic> json) => AdvertiseMent(
//     enName: json["en_name"] ?? '',
//     hiName: json["hi_name"] ?? '',
//     enDescription: json["en_description"] ?? '',
//     hiDescription: json["hi_description"] ?? '',
//     id: json["id"],
//     image: json["image"] ?? '',
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_name": enName ?? '',
//     "hi_name": hiName ?? '',
//     "en_description": enDescription ?? '',
//     "hi_description": hiDescription ?? '',
//     "id": id,
//     "image": image ?? '',
//   };
// }

class AdvertisementModel {
  AdvertisementModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<AdvertiseMent> data;

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null
          ? []
          : List<AdvertiseMent>.from(
              json["data"]!.map((x) => AdvertiseMent.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $message, $recode, $data, ";
  }
}

class AdvertiseMent {
  AdvertiseMent({
    required this.enName,
    required this.hiName,
    required this.enDescription,
    required this.hiDescription,
    required this.purposeId,
    required this.reqAmount,
    required this.reqCollected,
    required this.reqProgress,
    required this.id,
    required this.image,
  });

  final String enName;
  final String hiName;
  final String enDescription;
  final String hiDescription;
  final int purposeId;
  final String reqAmount;
  final String reqCollected;
  final int reqProgress;
  final int id;
  final String image;

  factory AdvertiseMent.fromJson(Map<String, dynamic> json) {
    return AdvertiseMent(
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      purposeId: json["purpose_id"] ?? 0,
      reqAmount: json["req_amount"] ?? "",
      reqCollected: json["req_collected"] ?? "",
      reqProgress: json["req_progress"] ?? 0,
      id: json["id"] ?? 0,
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "hi_name": hiName,
        "en_description": enDescription,
        "hi_description": hiDescription,
        "purpose_id": purposeId,
        "id": id,
        "image": image,
      };

  @override
  String toString() {
    return "$enName, $hiName, $enDescription, $hiDescription, $purposeId, $id, $image, ";
  }
}
