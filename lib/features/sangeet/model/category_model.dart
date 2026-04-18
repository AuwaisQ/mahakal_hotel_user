import 'dart:convert';

CategoryModel categoryModelFromJson(String str) =>
    CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  int status;
  List<SangeetCategory> sangeetcategory;

  CategoryModel({
    required this.status,
    required this.sangeetcategory,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        status: json["status"],
        sangeetcategory: List<SangeetCategory>.from(
            json["data"].map((x) => SangeetCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(sangeetcategory.map((x) => x.toJson())),
      };
}

class SangeetCategory {
  int id;
  String enName;
  String hiName;
  String image;
  String banner;

  SangeetCategory({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.image,
    required this.banner,
  });

  factory SangeetCategory.fromJson(Map<String, dynamic> json) =>
      SangeetCategory(
        id: json["id"],
        enName: json["en_name"],
        hiName: json["hi_name"],
        image: json["image"],
        banner: json["banner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "image": image,
        "banner": banner,
      };
}
