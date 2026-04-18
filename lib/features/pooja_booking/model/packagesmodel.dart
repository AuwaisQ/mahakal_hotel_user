// // To parse this JSON data, do
// //
// //     final packagesModel = packagesModelFromJson(jsonString);
//
// import 'dart:convert';
//
// List<PackagesModel> packagesModelFromJson(String str) => List<PackagesModel>.from(json.decode(str).map((x) => PackagesModel.fromJson(x)));
//
// String packagesModelToJson(List<PackagesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class PackagesModel {
//   String packageId;
//   String enPackageName;
//   String hiPackageName;
//   int person;
//   String color;
//   String enDescription;
//   String hiDescription;
//   String packagePrice;
//
//   PackagesModel({
//     required this.packageId,
//     required this.enPackageName,
//     required this.hiPackageName,
//     required this.person,
//     required this.color,
//     required this.enDescription,
//     required this.hiDescription,
//     required this.packagePrice,
//   });
//
//   factory PackagesModel.fromJson(Map<String, dynamic> json) => PackagesModel(
//     packageId: json["package_id"],
//     enPackageName: json["en_package_name"],
//     hiPackageName: json["hi_package_name"],
//     person: json["person"],
//     color: json["color"],
//     enDescription: json["en_description"],
//     hiDescription: json["hi_description"],
//     packagePrice: json["package_price"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "package_id": packageId,
//     "en_package_name": enPackageName,
//     "hi_package_name": hiPackageName,
//     "person": person,
//     "color": color,
//     "en_description": enDescription,
//     "hi_description": hiDescription,
//     "package_price": packagePrice,
//   };
// }

import 'dart:convert';

List<PackagesModel> packagesModelFromJson(String str) =>
    List<PackagesModel>.from(
        json.decode(str).map((x) => PackagesModel.fromJson(x)));

String packagesModelToJson(List<PackagesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PackagesModel {
  PackagesModel({
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.person,
    required this.color,
    required this.enDescription,
    required this.hiDescription,
    required this.packagePrice,
  });

  final String packageId;
  final String enPackageName;
  final String hiPackageName;
  final int person;
  final String color;
  final String enDescription;
  final String hiDescription;
  final String packagePrice;

  factory PackagesModel.fromJson(Map<String, dynamic> json) {
    return PackagesModel(
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      person: json["person"] ?? 0,
      color: json["color"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      packagePrice: json["package_price"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "package_id": packageId,
        "en_package_name": enPackageName,
        "hi_package_name": hiPackageName,
        "person": person,
        "color": color,
        "en_description": enDescription,
        "hi_description": hiDescription,
        "package_price": packagePrice,
      };

  @override
  String toString() {
    return "$packageId, $enPackageName, $hiPackageName, $person, $color, $enDescription, $hiDescription, $packagePrice, ";
  }
}
