import 'dart:convert';

List<KathaModel> kathaModelFromJson(String str) =>
    List<KathaModel>.from(json.decode(str).map((x) => KathaModel.fromJson(x)));

String kathaModelToJson(List<KathaModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KathaModel {
  KathaModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.hiName,
    required this.translations,
  });

  final int id;
  final int categoryId;
  final String name;
  final String image;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String hiName;
  final List<dynamic> translations;

  factory KathaModel.fromJson(Map<String, dynamic> json) {
    return KathaModel(
      id: json["id"] ?? 0,
      categoryId: json["category_id"] ?? 0,
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      hiName: json["hi_name"] ?? "",
      translations: json["translations"] == null
          ? []
          : List<dynamic>.from(json["translations"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "hi_name": hiName,
        "translations": translations.map((x) => x).toList(),
      };

  @override
  String toString() {
    return "$id, $categoryId, $name, $image, $status, $createdAt, $updatedAt, $hiName, $translations, ";
  }
}
