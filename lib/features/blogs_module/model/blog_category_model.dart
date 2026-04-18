// // To parse this JSON data, do
// //
// //     final BlogCategoryModel = BlogCategoryModelFromJson(jsonString);
//
// import 'dart:convert';
//
// BlogCategoryModel BlogCategoryModelFromJson(String str) => BlogCategoryModel.fromJson(json.decode(str));
//
// String BlogCategoryModelToJson(BlogCategoryModel data) => json.encode(data.toJson());
//
// class BlogCategoryModel {
//   int status;
//   List<BlogCategory> categories;
//
//   BlogCategoryModel({
//     required this.status,
//     required this.categories,
//   }
//   );
//
//   factory BlogCategoryModel.fromJson(Map<String, dynamic> json) => BlogCategoryModel(
//     status: json["status"],
//     categories: List<BlogCategory>.from(json["categories"].map((x) => BlogCategory.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
//   };
// }
//
// class BlogCategory {
//   int id;
//   int langId;
//   String name;
//
//   BlogCategory({
//     required this.id,
//     required this.langId,
//     required this.name,
//   });
//
//   factory BlogCategory.fromJson(Map<String, dynamic> json) => BlogCategory(
//     id: json["id"],
//     langId: json["lang_id"],
//     name: json["name"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "lang_id": langId,
//     "name": name,
//   };
// }

class BlogCategoryModel {
  BlogCategoryModel({
    required this.status,
    required this.categories,
  });

  final int status;
  final List<BlogCategory> categories;

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      status: json["status"] ?? 0,
      categories: json["categories"] == null
          ? []
          : List<BlogCategory>.from(
              json["categories"]!.map((x) => BlogCategory.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "categories": categories.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $categories, ";
  }
}

class BlogCategory {
  BlogCategory({
    required this.id,
    required this.langId,
    required this.name,
    required this.categoryOrder,
  });

  final int id;
  final int langId;
  final String name;
  final int categoryOrder;

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json["id"] ?? 0,
      langId: json["lang_id"] ?? 0,
      name: json["name"] ?? "",
      categoryOrder: json["category_order"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "lang_id": langId,
        "name": name,
        "category_order": categoryOrder,
      };

  @override
  String toString() {
    return "$id, $langId, $name, $categoryOrder, ";
  }
}
