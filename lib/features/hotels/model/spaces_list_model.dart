class SpacesListModel {
  SpacesListModel({
    required this.success,
    required this.data,
  });

  final bool success;
  final Data? data;

  factory SpacesListModel.fromJson(Map<String, dynamic> json){
    return SpacesListModel(
      success: json["success"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.layout,
    required this.map,
    required this.spaces,
    required this.pagination,
    required this.markers,
    required this.filters,
    required this.seo,
    required this.ui,
  });

  final String layout;
  final bool map;
  final List<Space> spaces;
  final Pagination? pagination;
  final List<dynamic> markers;
  final Filters? filters;
  final Seo? seo;
  final Ui? ui;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      layout: json["layout"] ?? "",
      map: json["map"] ?? false,
      spaces: json["spaces"] == null ? [] : List<Space>.from(json["spaces"]!.map((x) => Space.fromJson(x))),
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      markers: json["markers"] == null ? [] : List<dynamic>.from(json["markers"]!.map((x) => x)),
      filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
      seo: json["seo"] == null ? null : Seo.fromJson(json["seo"]),
      ui: json["ui"] == null ? null : Ui.fromJson(json["ui"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "layout": layout,
    "map": map,
    "spaces": spaces.map((x) => x?.toJson()).toList(),
    "pagination": pagination?.toJson(),
    "markers": markers.map((x) => x).toList(),
    "filters": filters?.toJson(),
    "seo": seo?.toJson(),
    "ui": ui?.toJson(),
  };

}

class Filters {
  Filters({
    required this.locations,
    required this.attributes,
    required this.priceRange,
  });

  final List<Location> locations;
  final List<Attribute> attributes;
  final List<String> priceRange;

  factory Filters.fromJson(Map<String, dynamic> json){
    return Filters(
      locations: json["locations"] == null ? [] : List<Location>.from(json["locations"]!.map((x) => Location.fromJson(x))),
      attributes: json["attributes"] == null ? [] : List<Attribute>.from(json["attributes"]!.map((x) => Attribute.fromJson(x))),
      priceRange: json["price_range"] == null ? [] : List<String>.from(json["price_range"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "locations": locations.map((x) => x?.toJson()).toList(),
    "attributes": attributes.map((x) => x?.toJson()).toList(),
    "price_range": priceRange.map((x) => x).toList(),
  };

}

class Attribute {
  Attribute({
    required this.id,
    required this.name,
    required this.slug,
    required this.service,
    required this.hideInFilterSearch,
    required this.position,
    required this.displayType,
    required this.hideInSingle,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.terms,
    required this.translation,
  });

  final int id;
  final String name;
  final String slug;
  final String service;
  final dynamic hideInFilterSearch;
  final dynamic position;
  final dynamic displayType;
  final dynamic hideInSingle;
  final dynamic createUser;
  final dynamic updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Term> terms;
  final dynamic translation;

  factory Attribute.fromJson(Map<String, dynamic> json){
    return Attribute(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      service: json["service"] ?? "",
      hideInFilterSearch: json["hide_in_filter_search"],
      position: json["position"],
      displayType: json["display_type"],
      hideInSingle: json["hide_in_single"],
      createUser: json["create_user"],
      updateUser: json["update_user"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      terms: json["terms"] == null ? [] : List<Term>.from(json["terms"]!.map((x) => Term.fromJson(x))),
      translation: json["translation"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "service": service,
    "hide_in_filter_search": hideInFilterSearch,
    "position": position,
    "display_type": displayType,
    "hide_in_single": hideInSingle,
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "terms": terms.map((x) => x?.toJson()).toList(),
    "translation": translation,
  };

}

class Term {
  Term({
    required this.id,
    required this.name,
    required this.content,
    required this.attrId,
    required this.slug,
    required this.createUser,
    required this.updateUser,
    required this.imageId,
    required this.icon,
    required this.originId,
    required this.lang,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.spaceCount,
    required this.translation,
  });

  final int id;
  final String name;
  final dynamic content;
  final int attrId;
  final String slug;
  final dynamic createUser;
  final dynamic updateUser;
  final int imageId;
  final dynamic icon;
  final dynamic originId;
  final dynamic lang;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int spaceCount;
  final dynamic translation;

  factory Term.fromJson(Map<String, dynamic> json){
    return Term(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      content: json["content"],
      attrId: json["attr_id"] ?? 0,
      slug: json["slug"] ?? "",
      createUser: json["create_user"],
      updateUser: json["update_user"],
      imageId: json["image_id"] ?? 0,
      icon: json["icon"],
      originId: json["origin_id"],
      lang: json["lang"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      spaceCount: json["space_count"] ?? 0,
      translation: json["translation"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "content": content,
    "attr_id": attrId,
    "slug": slug,
    "create_user": createUser,
    "update_user": updateUser,
    "image_id": imageId,
    "icon": icon,
    "origin_id": originId,
    "lang": lang,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "space_count": spaceCount,
    "translation": translation,
  };

}

class Location {
  Location({
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
    required this.translation,
    required this.children,
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
  final dynamic translation;
  final List<dynamic> children;

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
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
      translation: json["translation"],
      children: json["children"] == null ? [] : List<dynamic>.from(json["children"]!.map((x) => x)),
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
    "translation": translation,
    "children": children.map((x) => x).toList(),
  };

}

class Pagination {
  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  factory Pagination.fromJson(Map<String, dynamic> json){
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      perPage: json["per_page"] ?? 0,
      total: json["total"] ?? 0,
      from: json["from"] ?? 0,
      to: json["to"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "from": from,
    "to": to,
  };

}

class Seo {
  Seo({
    required this.seoTitle,
    required this.seoImage,
    required this.seoDesc,
    required this.seoShare,
    required this.fullUrl,
  });

  final String seoTitle;
  final String seoImage;
  final String seoDesc;
  final String seoShare;
  final String fullUrl;

  factory Seo.fromJson(Map<String, dynamic> json){
    return Seo(
      seoTitle: json["seo_title"] ?? "",
      seoImage: json["seo_image"] ?? "",
      seoDesc: json["seo_desc"] ?? "",
      seoShare: json["seo_share"] ?? "",
      fullUrl: json["full_url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "seo_title": seoTitle,
    "seo_image": seoImage,
    "seo_desc": seoDesc,
    "seo_share": seoShare,
    "full_url": fullUrl,
  };

}

class Space {
  Space({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.imageId,
    required this.bannerImageId,
    required this.locationId,
    required this.address,
    required this.mapLat,
    required this.mapLng,
    required this.mapZoom,
    required this.isFeatured,
    required this.video,
    required this.faqs,
    required this.price,
    required this.salePrice,
    required this.isInstant,
    required this.allowChildren,
    required this.allowInfant,
    required this.maxGuests,
    required this.bed,
    required this.bathroom,
    required this.square,
    required this.enableExtraPrice,
    required this.extraPrice,
    required this.discountByDays,
    required this.status,
    required this.defaultState,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewScore,
    required this.icalImportUrl,
    required this.enableServiceFee,
    required this.serviceFee,
    required this.surrounding,
    required this.authorId,
    required this.minDayBeforeBooking,
    required this.minDayStays,
    required this.location,
    required this.hasWishList,
    required this.translation,
    required this.image,
    required this.bannerImage,
  });

  final int id;
  final String title;
  final String slug;
  final String content;
  final int imageId;
  final int bannerImageId;
  final int locationId;
  final String address;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final int isFeatured;
  final String video;
  final List<Faq> faqs;
  final String price;
  final String salePrice;
  final int isInstant;
  final int allowChildren;
  final int allowInfant;
  final int maxGuests;
  final int bed;
  final int bathroom;
  final int square;
  final int enableExtraPrice;
  final List<ExtraPrice> extraPrice;
  final dynamic discountByDays;
  final String status;
  final int defaultState;
  final int createUser;
  final dynamic updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String reviewScore;
  final dynamic icalImportUrl;
  final dynamic enableServiceFee;
  final dynamic serviceFee;
  final dynamic surrounding;
  final int authorId;
  final dynamic minDayBeforeBooking;
  final dynamic minDayStays;
  final Location? location;
  final dynamic hasWishList;
  final dynamic translation;
  final String image;
  final String bannerImage;

  factory Space.fromJson(Map<String, dynamic> json){
    return Space(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      slug: json["slug"] ?? "",
      content: json["content"] ?? "",
      imageId: json["image_id"] ?? 0,
      bannerImageId: json["banner_image_id"] ?? 0,
      locationId: json["location_id"] ?? 0,
      address: json["address"] ?? "",
      mapLat: json["map_lat"] ?? "",
      mapLng: json["map_lng"] ?? "",
      mapZoom: json["map_zoom"] ?? 0,
      isFeatured: json["is_featured"] ?? 0,
      video: json["video"] ?? "",
      faqs: json["faqs"] == null ? [] : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
      price: json["price"] ?? "",
      salePrice: json["sale_price"] ?? "",
      isInstant: json["is_instant"] ?? 0,
      allowChildren: json["allow_children"] ?? 0,
      allowInfant: json["allow_infant"] ?? 0,
      maxGuests: json["max_guests"] ?? 0,
      bed: json["bed"] ?? 0,
      bathroom: json["bathroom"] ?? 0,
      square: json["square"] ?? 0,
      enableExtraPrice: json["enable_extra_price"] ?? 0,
      extraPrice: json["extra_price"] == null ? [] : List<ExtraPrice>.from(json["extra_price"]!.map((x) => ExtraPrice.fromJson(x))),
      discountByDays: json["discount_by_days"],
      status: json["status"] ?? "",
      defaultState: json["default_state"] ?? 0,
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      reviewScore: json["review_score"] ?? "",
      icalImportUrl: json["ical_import_url"],
      enableServiceFee: json["enable_service_fee"],
      serviceFee: json["service_fee"],
      surrounding: json["surrounding"],
      authorId: json["author_id"] ?? 0,
      minDayBeforeBooking: json["min_day_before_booking"],
      minDayStays: json["min_day_stays"],
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      hasWishList: json["has_wish_list"],
      translation: json["translation"],
      image: json["image"] ?? "",
      bannerImage: json["banner_image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "content": content,
    "image_id": imageId,
    "banner_image_id": bannerImageId,
    "location_id": locationId,
    "address": address,
    "map_lat": mapLat,
    "map_lng": mapLng,
    "map_zoom": mapZoom,
    "is_featured": isFeatured,
    "video": video,
    "faqs": faqs.map((x) => x?.toJson()).toList(),
    "price": price,
    "sale_price": salePrice,
    "is_instant": isInstant,
    "allow_children": allowChildren,
    "allow_infant": allowInfant,
    "max_guests": maxGuests,
    "bed": bed,
    "bathroom": bathroom,
    "square": square,
    "enable_extra_price": enableExtraPrice,
    "extra_price": extraPrice.map((x) => x?.toJson()).toList(),
    "discount_by_days": discountByDays,
    "status": status,
    "default_state": defaultState,
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "review_score": reviewScore,
    "ical_import_url": icalImportUrl,
    "enable_service_fee": enableServiceFee,
    "service_fee": serviceFee,
    "surrounding": surrounding,
    "author_id": authorId,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "location": location?.toJson(),
    "has_wish_list": hasWishList,
    "translation": translation,
    "image": image,
    "banner_image": bannerImage,
  };

}

class ExtraPrice {
  ExtraPrice({
    required this.name,
    required this.price,
    required this.type,
  });

  final String name;
  final String price;
  final String type;

  factory ExtraPrice.fromJson(Map<String, dynamic> json){
    return ExtraPrice(
      name: json["name"] ?? "",
      price: json["price"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "type": type,
  };

}

class Faq {
  Faq({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory Faq.fromJson(Map<String, dynamic> json){
    return Faq(
      title: json["title"] ?? "",
      content: json["content"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
  };

}

class Ui {
  Ui({
    required this.openInNewTab,
  });

  final bool openInNewTab;

  factory Ui.fromJson(Map<String, dynamic> json){
    return Ui(
      openInNewTab: json["open_in_new_tab"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "open_in_new_tab": openInNewTab,
  };

}
