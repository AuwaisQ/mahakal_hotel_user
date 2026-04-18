// // To parse this JSON data, do
// //
// //     final categoryModel = categoryModelFromJson(jsonString);
//
// import 'dart:convert';
//
// CategoryModel categoryModelFromJson(String str) => CategoryModel.fromJson(json.decode(str));
//
// String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());
//
// class CategoryModel {
//   bool? status;
//   List<OfflineCategory>? categoryList;
//
//   CategoryModel({
//     this.status,
//     this.categoryList,
//   });
//
//   factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
//     status: json["status"],
//     categoryList: json["categoryList"] == null ? [] : List<OfflineCategory>.from(json["categoryList"]!.map((x) => OfflineCategory.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "categoryList": categoryList == null ? [] : List<dynamic>.from(categoryList!.map((x) => x.toJson())),
//   };
// }
//
// class OfflineCategory {
//   String? enName;
//   String? hiName;
//   String? image;
//   int? id;
//
//   OfflineCategory({
//     this.enName,
//     this.hiName,
//     this.image,
//     this.id,
//   });
//
//   factory OfflineCategory.fromJson(Map<String, dynamic> json) => OfflineCategory(
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     image: json["image"],
//     id: json["id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_name": enName,
//     "hi_name": hiName,
//     "image": image,
//     "id": id,
//   };
// }

class CategoryModel {
  CategoryModel({
    required this.status,
    required this.categoryList,
  });

  final bool status;
  final List<OfflineCategory> categoryList;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      status: json["status"] ?? false,
      categoryList: json["categoryList"] == null
          ? []
          : List<OfflineCategory>.from(
              json["categoryList"]!.map((x) => OfflineCategory.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "categoryList": categoryList.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $categoryList, ";
  }
}

class OfflineCategory {
  OfflineCategory({
    required this.enName,
    required this.hiName,
    required this.id,
    required this.image,
  });

  final String enName;
  final String hiName;
  final int id;
  final String image;

  factory OfflineCategory.fromJson(Map<String, dynamic> json) {
    return OfflineCategory(
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      id: json["id"] ?? 0,
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "hi_name": hiName,
        "id": id,
        "image": image,
      };

  @override
  String toString() {
    return "$enName, $hiName, $id, $image, ";
  }
}
