// // To parse this JSON data, do
// //
// //     final offlineSubCategoryModel = offlineSubCategoryModelFromJson(jsonString);
//
// import 'dart:convert';
//
// OfflineSubCategoryModel offlineSubCategoryModelFromJson(String str) => OfflineSubCategoryModel.fromJson(json.decode(str));
//
// String offlineSubCategoryModelToJson(OfflineSubCategoryModel data) => json.encode(data.toJson());
//
// class OfflineSubCategoryModel {
//   bool? status;
//   List<OfflinePoojaList>? poojaList;
//
//   OfflineSubCategoryModel({
//     this.status,
//     this.poojaList,
//   });
//
//   factory OfflineSubCategoryModel.fromJson(Map<String, dynamic> json) => OfflineSubCategoryModel(
//     status: json["status"],
//     poojaList: json["poojaList"] == null ? [] : List<OfflinePoojaList>.from(json["poojaList"]!.map((x) => OfflinePoojaList.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "poojaList": poojaList == null ? [] : List<dynamic>.from(poojaList!.map((x) => x.toJson())),
//   };
// }
//
// class OfflinePoojaList {
//   String? enName;
//   String? hiName;
//   String? enShortBenifits;
//   String? hiShortBenifits;
//   int? id;
//   String? slug;
//   String? thumbnail;
//
//   OfflinePoojaList({
//     this.enName,
//     this.hiName,
//     this.enShortBenifits,
//     this.hiShortBenifits,
//     this.id,
//     this.slug,
//     this.thumbnail,
//   });
//
//   factory OfflinePoojaList.fromJson(Map<String, dynamic> json) => OfflinePoojaList(
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     enShortBenifits: json["en_short_benifits"],
//     hiShortBenifits: json["hi_short_benifits"],
//     id: json["id"],
//     slug: json["slug"],
//     thumbnail: json["thumbnail"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_name": enName,
//     "hi_name": hiName,
//     "en_short_benifits": enShortBenifits,
//     "hi_short_benifits": hiShortBenifits,
//     "id": id,
//     "slug": slug,
//     "thumbnail": thumbnail,
//   };
// }

class OfflineSubCategoryModel {
  OfflineSubCategoryModel({
    required this.status,
    required this.poojaList,
  });

  final bool status;
  final List<OfflinePoojaList> poojaList;

  factory OfflineSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return OfflineSubCategoryModel(
      status: json["status"] ?? false,
      poojaList: json["poojaList"] == null
          ? []
          : List<OfflinePoojaList>.from(
              json["poojaList"]!.map((x) => OfflinePoojaList.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "poojaList": poojaList.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $poojaList, ";
  }
}

class OfflinePoojaList {
  OfflinePoojaList({
    required this.enName,
    required this.hiName,
    required this.enShortBenifits,
    required this.hiShortBenifits,
    required this.id,
    required this.slug,
    required this.thumbnail,
  });

  final String enName;
  final String hiName;
  final String enShortBenifits;
  final String hiShortBenifits;
  final int id;
  final String slug;
  final String thumbnail;

  factory OfflinePoojaList.fromJson(Map<String, dynamic> json) {
    return OfflinePoojaList(
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enShortBenifits: json["en_short_benifits"] ?? "",
      hiShortBenifits: json["hi_short_benifits"] ?? "",
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "hi_name": hiName,
        "en_short_benifits": enShortBenifits,
        "hi_short_benifits": hiShortBenifits,
        "id": id,
        "slug": slug,
        "thumbnail": thumbnail,
      };

  @override
  String toString() {
    return "$enName, $hiName, $enShortBenifits, $hiShortBenifits, $id, $slug, $thumbnail, ";
  }
}
