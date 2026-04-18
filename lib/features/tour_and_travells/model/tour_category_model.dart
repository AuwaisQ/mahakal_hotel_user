import 'dart:convert';

TourCategoryModel tourCategoryModelFromJson(String str) =>
    TourCategoryModel.fromJson(json.decode(str));

String tourCategoryModelToJson(TourCategoryModel data) =>
    json.encode(data.toJson());

class TourCategoryModel {
  int status;
  int count;
  List<TourTabs> data;

  TourCategoryModel({
    required this.status,
    required this.count,
    required this.data,
  });

  factory TourCategoryModel.fromJson(Map<String, dynamic> json) =>
      TourCategoryModel(
        status: json["status"],
        count: json["count"],
        data:
            List<TourTabs>.from(json["data"].map((x) => TourTabs.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TourTabs {
  String slug;
  String enName;
  String hiName;

  TourTabs({
    required this.slug,
    required this.enName,
    required this.hiName,
  });

  factory TourTabs.fromJson(Map<String, dynamic> json) => TourTabs(
        slug: json["slug"],
        enName: json["en_name"],
        hiName: json["hi_name"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "en_name": enName,
        "hi_name": hiName,
      };
}
