// // To parse this JSON data, do
// //
// //     final pooojaCategoryModel = pooojaCategoryModelFromJson(jsonString);
//
// import 'dart:convert';
//
// PooojaCategoryModel pooojaCategoryModelFromJson(String str) => PooojaCategoryModel.fromJson(json.decode(str));
//
// String pooojaCategoryModelToJson(PooojaCategoryModel data) => json.encode(data.toJson());
//
// class PooojaCategoryModel {
//   int status;
//   List<GetPoojaCategory> getPoojaCategory;
//
//   PooojaCategoryModel({
//     required this.status,
//     required this.getPoojaCategory,
//   });
//
//   factory PooojaCategoryModel.fromJson(Map<String, dynamic> json) => PooojaCategoryModel(
//     status: json["status"],
//     getPoojaCategory: List<GetPoojaCategory>.from(json["getPoojaCategory"].map((x) => GetPoojaCategory.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "getPoojaCategory": List<dynamic>.from(getPoojaCategory.map((x) => x.toJson())),
//   };
// }
//
// class GetPoojaCategory {
//   int id;
//   String enName;
//   String hiName;
//   String icon;
//
//   GetPoojaCategory({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.icon,
//   });
//
//   factory GetPoojaCategory.fromJson(Map<String, dynamic> json) => GetPoojaCategory(
//     id: json["id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     icon: json["icon"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "icon": icon,
//   };
// }

class PooojaCategoryModel {
  PooojaCategoryModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<GetPoojaCategory> data;

  factory PooojaCategoryModel.fromJson(Map<String, dynamic> json) {
    return PooojaCategoryModel(
      status: json["status"] ?? 0,
      data: json["data"] == null
          ? []
          : List<GetPoojaCategory>.from(
              json["data"]!.map((x) => GetPoojaCategory.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $data, ";
  }
}

class GetPoojaCategory {
  GetPoojaCategory({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.icon,
  });

  final int id;
  final String enName;
  final String hiName;
  final String icon;

  factory GetPoojaCategory.fromJson(Map<String, dynamic> json) {
    return GetPoojaCategory(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      icon: json["icon"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "icon": icon,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $icon, ";
  }
}
