// // To parse this JSON data, do
// //
// //     final donationCategoryModel = donationCategoryModelFromJson(jsonString);
//
// import 'dart:convert';
//
// DonationCategoryModel donationCategoryModelFromJson(String str) => DonationCategoryModel.fromJson(json.decode(str));
//
// String donationCategoryModelToJson(DonationCategoryModel data) => json.encode(data.toJson());
//
// class DonationCategoryModel {
//   int status;
//   String message;
//   int recode;
//   List<DonationTabs> data;
//
//   DonationCategoryModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.data,
//   });
//
//   factory DonationCategoryModel.fromJson(Map<String, dynamic> json) => DonationCategoryModel(
//     status: json["status"],
//     message: json["message"],
//     recode: json["recode"],
//     data: List<DonationTabs>.from(json["data"].map((x) => DonationTabs.fromJson(x))),
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
// class DonationTabs {
//   String? enName;
//   String? hiName;
//   int? id;
//   String? slug;
//   String? image;
//
//   DonationTabs({
//     required this.enName,
//     required this.hiName,
//     required this.id,
//     required this.slug,
//     required this.image,
//   });
//
//   factory DonationTabs.fromJson(Map<String, dynamic> json) => DonationTabs(
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     id: json["id"],
//     slug: json["slug"],
//     image: json["image"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_name": enName ?? '',
//     "hi_name": hiName ?? '',
//     "id": id ?? '',
//     "slug": slug ?? '',
//     "image": image ?? '',
//   };
// }
class DonationCategoryModel {
  DonationCategoryModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<DonationTabs> data;

  factory DonationCategoryModel.fromJson(Map<String, dynamic> json) {
    return DonationCategoryModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null
          ? []
          : List<DonationTabs>.from(
              json["data"]!.map((x) => DonationTabs.fromJson(x))),
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

class DonationTabs {
  DonationTabs({
    required this.enName,
    required this.hiName,
    required this.id,
    required this.slug,
    required this.image,
  });

  final String enName;
  final String hiName;
  final int id;
  final String slug;
  final String image;

  factory DonationTabs.fromJson(Map<String, dynamic> json) {
    return DonationTabs(
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "hi_name": hiName,
        "id": id,
        "slug": slug,
        "image": image,
      };

  @override
  String toString() {
    return "$enName, $hiName, $id, $slug, $image, ";
  }
}
