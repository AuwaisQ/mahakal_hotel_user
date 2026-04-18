class HotelLocationModel {
  HotelLocationModel({
    required this.status,
    required this.data,
    required this.message,
  });

  final bool status;
  final Data? data;
  final String message;

  factory HotelLocationModel.fromJson(Map<String, dynamic> json){
    return HotelLocationModel(
      status: json["status"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
    "message": message,
  };

}

class Data {
  Data({
    required this.locations,
  });

  final List<HotelLocation> locations;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      locations: json["locations"] == null ? [] : List<HotelLocation>.from(json["locations"]!.map((x) => HotelLocation.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "locations": locations.map((x) => x?.toJson()).toList(),
  };

}

class HotelLocation {
  HotelLocation({
    required this.id,
    required this.name,
    required this.content,
    required this.slug,
    required this.imageId,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.status,
    required this.gallery,
    required this.lft,
    required this.rgt,
    required this.parentId,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.originId,
    required this.lang,
    required this.createdAt,
    required this.updatedAt,
    required this.bannerImageId,
    required this.tripIdeas,
    required this.image,
    required this.bannerImage,
  });

  final int id;
  final String name;
  final String content;
  final String slug;
  final int imageId;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final String status;
  final dynamic gallery;
  final int lft;
  final int rgt;
  final dynamic parentId;
  final int createUser;
  final dynamic updateUser;
  final dynamic deletedAt;
  final dynamic originId;
  final dynamic lang;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int bannerImageId;
  final String tripIdeas;
  final String image;
  final String bannerImage;

  factory HotelLocation.fromJson(Map<String, dynamic> json){
    return HotelLocation(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      content: json["content"] ?? "",
      slug: json["slug"] ?? "",
      imageId: json["image_id"] ?? 0,
      mapLat: json["map_lat"] ?? "",
      mapLng: json["map_lng"] ?? "",
      mapZoom: json["map_zoom"] ?? 0,
      status: json["status"] ?? "",
      gallery: json["gallery"],
      lft: json["_lft"] ?? 0,
      rgt: json["_rgt"] ?? 0,
      parentId: json["parent_id"],
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"],
      deletedAt: json["deleted_at"],
      originId: json["origin_id"],
      lang: json["lang"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      bannerImageId: json["banner_image_id"] ?? 0,
      tripIdeas: json["trip_ideas"] ?? "",
      image: json["image"] ?? "",
      bannerImage: json["banner_image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "content": content,
    "slug": slug,
    "image_id": imageId,
    "map_lat": mapLat,
    "map_lng": mapLng,
    "map_zoom": mapZoom,
    "status": status,
    "gallery": gallery,
    "_lft": lft,
    "_rgt": rgt,
    "parent_id": parentId,
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "origin_id": originId,
    "lang": lang,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "banner_image_id": bannerImageId,
    "trip_ideas": tripIdeas,
    "image": image,
    "banner_image": bannerImage,
  };

}
