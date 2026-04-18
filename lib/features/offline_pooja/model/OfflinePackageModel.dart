// import 'dart:convert';
//
// List<OfflinePackagesModel> offlinepackagesModelFromJson(String str) => List<OfflinePackagesModel>.from(json.decode(str).map((x) => OfflinePackagesModel.fromJson(x)));
//
// String offlinepackagesModelToJson(List<OfflinePackagesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class OfflinePackagesModel {
//   String? packageId;
//   String? enPackageName;
//   String? hiPackageName;
//   int? person;
//   String? color;
//   String? enDescription;
//   String? hiDescription;
//   String? packagePrice;
//   String? packagePercent;
//
//
//   OfflinePackagesModel({
//     required this.packageId,
//     required this.enPackageName,
//     required this.hiPackageName,
//     required this.person,
//     required this.color,
//     required this.enDescription,
//     required this.hiDescription,
//     required this.packagePrice,
//     required this.packagePercent,
//
//   });
//
//   factory OfflinePackagesModel.fromJson(Map<String, dynamic> json) => OfflinePackagesModel(
//     packageId: json["package_id"],
//     enPackageName: json["en_package_name"],
//     hiPackageName: json["hi_package_name"],
//     person: json["person"],
//     color: json["color"],
//     enDescription: json["en_description"],
//     hiDescription: json["hi_description"],
//     packagePrice: json["package_price"],
//     packagePercent: json["package_percent"],
//
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
//     "package_percent": packagePercent,
//
//   };
// }

import 'dart:convert';

List<OfflinePackagesModel> offlinepackagesModelFromJson(String str) =>
    List<OfflinePackagesModel>.from(
        json.decode(str).map((x) => OfflinePackagesModel.fromJson(x)));

String offlinepackagesModelToJson(List<OfflinePackagesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OfflinePackagesModel {
  OfflinePackagesModel({
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.person,
    required this.color,
    required this.enDescription,
    required this.hiDescription,
    required this.packagePrice,
    required this.packagePercent,
  });

  final String packageId;
  final String enPackageName;
  final String hiPackageName;
  final int person;
  final String color;
  final String enDescription;
  final String hiDescription;
  final String packagePrice;
  final String packagePercent;

  factory OfflinePackagesModel.fromJson(Map<String, dynamic> json) {
    return OfflinePackagesModel(
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      person: json["person"] ?? 0,
      color: json["color"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      packagePrice: json["package_price"] ?? "",
      packagePercent: json["package_percent"] ?? "",
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
        "package_percent": packagePercent,
      };

  @override
  String toString() {
    return "$packageId, $enPackageName, $hiPackageName, $person, $color, $enDescription, $hiDescription, $packagePrice, $packagePercent, ";
  }
}
