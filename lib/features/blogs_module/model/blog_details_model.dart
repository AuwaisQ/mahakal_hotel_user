// class BlogDetailsModel {
//   BlogDetailsModel({
//     required this.status,
//     required this.data,
//   });
//
//   final int status;
//   final BlogData? data;
//
//   factory BlogDetailsModel.fromJson(Map<String, dynamic> json) {
//     return BlogDetailsModel(
//       status: json["status"] ?? 0,
//       data: json["data"] == null ? null : BlogData.fromJson(json["data"]),
//     );
//   }
// }
//
// class BlogData {
//   BlogData({
//     required this.id,
//     required this.langId,
//     required this.title,
//     required this.titleSlug,
//     required this.titleHash,
//     required this.summary,
//     required this.content,
//     required this.keywords,
//     required this.userId,
//     required this.categoryId,
//     required this.imageBig,
//     required this.imageMid,
//     required this.imageSmall,
//     required this.imageSlider,
//     required this.imageMime,
//     required this.imageStorage,
//     required this.isSlider,
//     required this.isPicked,
//     required this.hit,
//     required this.sliderOrder,
//     required this.optionalUrl,
//     required this.postType,
//     required this.videoUrl,
//     required this.videoEmbedCode,
//     required this.imageUrl,
//     required this.needAuth,
//     required this.feedId,
//     required this.postUrl,
//     required this.showPostUrl,
//     required this.visibility,
//     required this.status,
//     required this.createdAt,
//     required this.commentCount,
//   });
//
//   final int id;
//   final int langId;
//   final String title;
//   final String titleSlug;
//   final dynamic titleHash;
//   final String summary;
//   final String content;
//   final String keywords;
//   final int userId;
//   final int categoryId;
//   final String imageBig;
//   final String imageMid;
//   final String imageSmall;
//   final String imageSlider;
//   final String imageMime;
//   final String imageStorage;
//   final int isSlider;
//   final int isPicked;
//   final int hit;
//   final int sliderOrder;
//   final String optionalUrl;
//   final String postType;
//   final String videoUrl;
//   final String videoEmbedCode;
//   final String imageUrl;
//   final int needAuth;
//   final int feedId;
//   final dynamic postUrl;
//   final int showPostUrl;
//   final int visibility;
//   final int status;
//   final DateTime? createdAt;
//   final int commentCount;
//
//   factory BlogData.fromJson(Map<String, dynamic> json) {
//     return BlogData(
//       id: json["id"] ?? 0,
//       langId: json["lang_id"] ?? 0,
//       title: json["title"] ?? "",
//       titleSlug: json["title_slug"] ?? "",
//       titleHash: json["title_hash"],
//       summary: json["summary"] ?? "",
//       content: json["content"] ?? "",
//       keywords: json["keywords"] ?? "",
//       userId: json["user_id"] ?? 0,
//       categoryId: json["category_id"] ?? 0,
//       imageBig: json["image_big"] ?? "",
//       imageMid: json["image_mid"] ?? "",
//       imageSmall: json["image_small"] ?? "",
//       imageSlider: json["image_slider"] ?? "",
//       imageMime: json["image_mime"] ?? "",
//       imageStorage: json["image_storage"] ?? "",
//       isSlider: json["is_slider"] ?? 0,
//       isPicked: json["is_picked"] ?? 0,
//       hit: json["hit"] ?? 0,
//       sliderOrder: json["slider_order"] ?? 0,
//       optionalUrl: json["optional_url"] ?? "",
//       postType: json["post_type"] ?? "",
//       videoUrl: json["video_url"] ?? "",
//       videoEmbedCode: json["video_embed_code"] ?? "",
//       imageUrl: json["image_url"] ?? "",
//       needAuth: json["need_auth"] ?? 0,
//       feedId: json["feed_id"] ?? 0,
//       postUrl: json["post_url"],
//       showPostUrl: json["show_post_url"] ?? 0,
//       visibility: json["visibility"] ?? 0,
//       status: json["status"] ?? 0,
//       createdAt: DateTime.tryParse(json["created_at"] ?? ""),
//       commentCount: json["comment_count"] ?? 0,
//     );
//   }
// }
//


class BlogDetailsModel {
  BlogDetailsModel({
    required this.status,
    required this.data,
    required this.mostViewedBlogs,
    required this.latestBlogs,
  });

  final int? status;
  final BlogData? data;
  final List<BlogSubCategory> mostViewedBlogs;
  final List<BlogSubCategory> latestBlogs;

  factory BlogDetailsModel.fromJson(Map<String, dynamic> json){
    return BlogDetailsModel(
      status: json["status"],
      data: json["data"] == null ? null : BlogData.fromJson(json["data"]),
      mostViewedBlogs: json["most_viewed_blogs"] == null ? [] : List<BlogSubCategory>.from(json["most_viewed_blogs"]!.map((x) => BlogSubCategory.fromJson(x))),
      latestBlogs: json["latest_blogs"] == null ? [] : List<BlogSubCategory>.from(json["latest_blogs"]!.map((x) => BlogSubCategory.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "most_viewed_blogs": mostViewedBlogs.map((x) => x?.toJson()).toList(),
    "latest_blogs": latestBlogs.map((x) => x?.toJson()).toList(),
  };

}

class BlogData {
  BlogData({
    required this.id,
    required this.langId,
    required this.title,
    required this.titleSlug,
    required this.titleHash,
    required this.summary,
    required this.content,
    required this.keywords,
    required this.userId,
    required this.categoryId,
    required this.imageBig,
    required this.imageMid,
    required this.imageSmall,
    required this.imageSlider,
    required this.imageMime,
    required this.imageStorage,
    required this.isSlider,
    required this.isPicked,
    required this.hit,
    required this.sliderOrder,
    required this.optionalUrl,
    required this.postType,
    required this.videoUrl,
    required this.videoEmbedCode,
    required this.imageUrl,
    required this.needAuth,
    required this.feedId,
    required this.postUrl,
    required this.showPostUrl,
    required this.visibility,
    required this.status,
    required this.createdAt,
    required this.commentCount,
  });

  final int? id;
  final int? langId;
  final String? title;
  final String? titleSlug;
  final dynamic titleHash;
  final String? summary;
  final String? content;
  final String? keywords;
  final int? userId;
  final int? categoryId;
  final String? imageBig;
  final String? imageMid;
  final String? imageSmall;
  final String? imageSlider;
  final String? imageMime;
  final String? imageStorage;
  final int? isSlider;
  final int? isPicked;
  final int? hit;
  final int? sliderOrder;
  final String? optionalUrl;
  final String? postType;
  final String? videoUrl;
  final String? videoEmbedCode;
  final String? imageUrl;
  final int? needAuth;
  final int? feedId;
  final dynamic postUrl;
  final int? showPostUrl;
  final int? visibility;
  final int? status;
  final DateTime? createdAt;
  final int? commentCount;

  factory BlogData.fromJson(Map<String, dynamic> json){
    return BlogData(
      id: json["id"],
      langId: json["lang_id"],
      title: json["title"],
      titleSlug: json["title_slug"],
      titleHash: json["title_hash"],
      summary: json["summary"],
      content: json["content"],
      keywords: json["keywords"],
      userId: json["user_id"],
      categoryId: json["category_id"],
      imageBig: json["image_big"],
      imageMid: json["image_mid"],
      imageSmall: json["image_small"],
      imageSlider: json["image_slider"],
      imageMime: json["image_mime"],
      imageStorage: json["image_storage"],
      isSlider: json["is_slider"],
      isPicked: json["is_picked"],
      hit: json["hit"],
      sliderOrder: json["slider_order"],
      optionalUrl: json["optional_url"],
      postType: json["post_type"],
      videoUrl: json["video_url"],
      videoEmbedCode: json["video_embed_code"],
      imageUrl: json["image_url"],
      needAuth: json["need_auth"],
      feedId: json["feed_id"],
      postUrl: json["post_url"],
      showPostUrl: json["show_post_url"],
      visibility: json["visibility"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      commentCount: json["comment_count"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "lang_id": langId,
    "title": title,
    "title_slug": titleSlug,
    "title_hash": titleHash,
    "summary": summary,
    "content": content,
    "keywords": keywords,
    "user_id": userId,
    "category_id": categoryId,
    "image_big": imageBig,
    "image_mid": imageMid,
    "image_small": imageSmall,
    "image_slider": imageSlider,
    "image_mime": imageMime,
    "image_storage": imageStorage,
    "is_slider": isSlider,
    "is_picked": isPicked,
    "hit": hit,
    "slider_order": sliderOrder,
    "optional_url": optionalUrl,
    "post_type": postType,
    "video_url": videoUrl,
    "video_embed_code": videoEmbedCode,
    "image_url": imageUrl,
    "need_auth": needAuth,
    "feed_id": feedId,
    "post_url": postUrl,
    "show_post_url": showPostUrl,
    "visibility": visibility,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "comment_count": commentCount,
  };

}

class BlogSubCategory {
  BlogSubCategory({
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

  factory BlogSubCategory.fromJson(Map<String, dynamic> json) {
    return BlogSubCategory(
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
