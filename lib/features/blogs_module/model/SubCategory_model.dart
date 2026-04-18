class BlogSubCategoryModel {
  BlogSubCategoryModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<BlogSubCategoryData> data;

  factory BlogSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogSubCategoryModel(
      status: json["status"] ?? 0,
      data: json["data"] == null
          ? []
          : List<BlogSubCategoryData>.from(
              json["data"]!.map((x) => BlogSubCategoryData.fromJson(x))),
    );
  }
}

class BlogSubCategoryData {
  BlogSubCategoryData({
    required this.id,
    required this.title,
    required this.titleSlug,
    required this.createdAt,
    required this.hit,
    required this.imageBig,
    required this.imageSmall,
    required this.imageMid,
    required this.imageSlider,
    required this.commentCount,
  });

  final int id;
  final String title;
  final String titleSlug;
  final DateTime? createdAt;
  final int hit;
  final String imageBig;
  final String imageSmall;
  final String imageMid;
  final String imageSlider;
  final int commentCount;

  factory BlogSubCategoryData.fromJson(Map<String, dynamic> json) {
    return BlogSubCategoryData(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      titleSlug: json["title_slug"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      hit: json["hit"] ?? 0,
      imageBig: json["image_big"] ?? "",
      imageSmall: json["image_small"] ?? "",
      imageMid: json["image_mid"] ?? "",
      imageSlider: json["image_slider"] ?? "",
      commentCount: json["comment_count"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "title_slug": titleSlug,
      "created_at": createdAt?.toIso8601String(),
      "hit": hit,
      "image_big": imageBig,
      "image_small": imageSmall,
      "image_mid": imageMid,
      "image_slider": imageSlider,
      "comment_count": commentCount,
    };
  }
}
