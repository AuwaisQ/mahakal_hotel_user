class ViewAllHotelModel {
  ViewAllHotelModel({
    required this.status,
    required this.data,
    required this.message,
  });

  final bool status;
  final Data? data;
  final String message;

  factory ViewAllHotelModel.fromJson(Map<String, dynamic> json){
    return ViewAllHotelModel(
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
    required this.hotels,
    required this.pagination,
    required this.markers,
    required this.layout,
    required this.filters,
    required this.seo,
  });

  final List<AllHotel> hotels;
  final Pagination? pagination;
  final List<dynamic> markers;
  final String layout;
  final Filters? filters;
  final Seo? seo;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      hotels: json["hotels"] == null ? [] : List<AllHotel>.from(json["hotels"]!.map((x) => AllHotel.fromJson(x))),
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      markers: json["markers"] == null ? [] : List<dynamic>.from(json["markers"]!.map((x) => x)),
      layout: json["layout"] ?? "",
      filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
      seo: json["seo"] == null ? null : Seo.fromJson(json["seo"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "hotels": hotels.map((x) => x?.toJson()).toList(),
    "pagination": pagination?.toJson(),
    "markers": markers.map((x) => x).toList(),
    "layout": layout,
    "filters": filters?.toJson(),
    "seo": seo?.toJson(),
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
    required this.hotelCount,
    required this.translation,
    required this.laravelThroughKey,
  });

  final int id;
  final String name;
  final dynamic content;
  final int attrId;
  final String slug;
  final dynamic createUser;
  final dynamic updateUser;
  final dynamic imageId;
  final String icon;
  final dynamic originId;
  final dynamic lang;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int hotelCount;
  final dynamic translation;
  final int laravelThroughKey;

  factory Term.fromJson(Map<String, dynamic> json){
    return Term(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      content: json["content"],
      attrId: json["attr_id"] ?? 0,
      slug: json["slug"] ?? "",
      createUser: json["create_user"],
      updateUser: json["update_user"],
      imageId: json["image_id"],
      icon: json["icon"] ?? "",
      originId: json["origin_id"],
      lang: json["lang"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      hotelCount: json["hotel_count"] ?? 0,
      translation: json["translation"],
      laravelThroughKey: json["laravel_through_key"] ?? 0,
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
    "hotel_count": hotelCount,
    "translation": translation,
    "laravel_through_key": laravelThroughKey,
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
  final dynamic content;
  final String slug;
  final int imageId;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final String status;
  final dynamic gallery;
  final int lft;
  final int rgt;
  final int parentId;
  final int createUser;
  final int updateUser;
  final dynamic deletedAt;
  final dynamic originId;
  final dynamic lang;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic bannerImageId;
  final dynamic tripIdeas;
  final LocationTranslation? translation;
  final List<Location> children;

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      content: json["content"],
      slug: json["slug"] ?? "",
      imageId: json["image_id"] ?? 0,
      mapLat: json["map_lat"] ?? "",
      mapLng: json["map_lng"] ?? "",
      mapZoom: json["map_zoom"] ?? 0,
      status: json["status"] ?? "",
      gallery: json["gallery"],
      lft: json["_lft"] ?? 0,
      rgt: json["_rgt"] ?? 0,
      parentId: json["parent_id"] ?? 0,
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      originId: json["origin_id"],
      lang: json["lang"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      bannerImageId: json["banner_image_id"],
      tripIdeas: json["trip_ideas"],
      translation: json["translation"] == null ? null : LocationTranslation.fromJson(json["translation"]),
      children: json["children"] == null ? [] : List<Location>.from(json["children"]!.map((x) => Location.fromJson(x))),
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
    "translation": translation?.toJson(),
    "children": children.map((x) => x?.toJson()).toList(),
  };

}

class LocationTranslation {
  LocationTranslation({
    required this.id,
    required this.originId,
    required this.locale,
    required this.name,
    required this.content,
    required this.createUser,
    required this.updateUser,
    required this.createdAt,
    required this.updatedAt,
    required this.tripIdeas,
  });

  final int id;
  final int originId;
  final String locale;
  final String name;
  final dynamic content;
  final int createUser;
  final int updateUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic tripIdeas;

  factory LocationTranslation.fromJson(Map<String, dynamic> json){
    return LocationTranslation(
      id: json["id"] ?? 0,
      originId: json["origin_id"] ?? 0,
      locale: json["locale"] ?? "",
      name: json["name"] ?? "",
      content: json["content"],
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      tripIdeas: json["trip_ideas"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "origin_id": originId,
    "locale": locale,
    "name": name,
    "content": content,
    "create_user": createUser,
    "update_user": updateUser,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "trip_ideas": tripIdeas,
  };

}

class AllHotel {
  AllHotel({
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
    required this.gallery,
    required this.video,
    required this.policy,
    required this.starRate,
    required this.price,
    required this.checkInTime,
    required this.checkOutTime,
    required this.allowFullDay,
    required this.salePrice,
    required this.relatedIds,
    required this.status,
    required this.createUser,
    required this.updateUser,
    required this.vendorId,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewScore,
    required this.icalImportUrl,
    required this.enableExtraPrice,
    required this.extraPrice,
    required this.enableServiceFee,
    required this.serviceFee,
    required this.surrounding,
    required this.authorId,
    required this.minDayBeforeBooking,
    required this.minDayStays,
    required this.location,
    required this.hasWishList,
    required this.translation,
    required this.termsByAttributeInListingPage,
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
  final List<String> gallery;
  final String video;
  final List<Policy> policy;
  final int starRate;
  final String price;
  final String checkInTime;
  final String checkOutTime;
  final dynamic allowFullDay;
  final dynamic salePrice;
  final dynamic relatedIds;
  final String status;
  final int createUser;
  final int updateUser;
  final dynamic vendorId;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String reviewScore;
  final dynamic icalImportUrl;
  final int enableExtraPrice;
  final List<ExtraPrice> extraPrice;
  final int enableServiceFee;
  final List<ServiceFee> serviceFee;
  final dynamic surrounding;
  final int authorId;
  final int minDayBeforeBooking;
  final int minDayStays;
  final Location? location;
  final dynamic hasWishList;
  final HotelTranslation? translation;
  final List<Term> termsByAttributeInListingPage;
  final String image;
  final String bannerImage;

  factory AllHotel.fromJson(Map<String, dynamic> json){
    return AllHotel(
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
      gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x ?? "")),
      video: json["video"] ?? "",
      policy: json["policy"] == null ? [] : List<Policy>.from(json["policy"]!.map((x) => Policy.fromJson(x))),
      starRate: json["star_rate"] ?? 0,
      price: json["price"] ?? "",
      checkInTime: json["check_in_time"] ?? "",
      checkOutTime: json["check_out_time"] ?? "",
      allowFullDay: json["allow_full_day"],
      salePrice: json["sale_price"],
      relatedIds: json["related_ids"],
      status: json["status"] ?? "",
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      vendorId: json["vendor_id"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      reviewScore: json["review_score"] ?? "",
      icalImportUrl: json["ical_import_url"],
      enableExtraPrice: json["enable_extra_price"] ?? 0,
      extraPrice: json["extra_price"] == null ? [] : List<ExtraPrice>.from(json["extra_price"]!.map((x) => ExtraPrice.fromJson(x))),
      enableServiceFee: json["enable_service_fee"] ?? 0,
      serviceFee: json["service_fee"] == null ? [] : List<ServiceFee>.from(json["service_fee"]!.map((x) => ServiceFee.fromJson(x))),
      surrounding: json["surrounding"],
      authorId: json["author_id"] ?? 0,
      minDayBeforeBooking: json["min_day_before_booking"] ?? 0,
      minDayStays: json["min_day_stays"] ?? 0,
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      hasWishList: json["has_wish_list"],
      translation: json["translation"] == null ? null : HotelTranslation.fromJson(json["translation"]),
      termsByAttributeInListingPage: json["terms_by_attribute_in_listing_page"] == null ? [] : List<Term>.from(json["terms_by_attribute_in_listing_page"]!.map((x) => Term.fromJson(x))),
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
    "gallery": gallery.map((x) => x).toList(),
    "video": video,
    "policy": policy.map((x) => x?.toJson()).toList(),
    "star_rate": starRate,
    "price": price,
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "allow_full_day": allowFullDay,
    "sale_price": salePrice,
    "related_ids": relatedIds,
    "status": status,
    "create_user": createUser,
    "update_user": updateUser,
    "vendor_id": vendorId,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "review_score": reviewScore,
    "ical_import_url": icalImportUrl,
    "enable_extra_price": enableExtraPrice,
    "extra_price": extraPrice.map((x) => x?.toJson()).toList(),
    "enable_service_fee": enableServiceFee,
    "service_fee": serviceFee.map((x) => x?.toJson()).toList(),
    "surrounding": surrounding,
    "author_id": authorId,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "location": location?.toJson(),
    "has_wish_list": hasWishList,
    "translation": translation?.toJson(),
    "terms_by_attribute_in_listing_page": termsByAttributeInListingPage.map((x) => x?.toJson()).toList(),
    "image": image,
    "banner_image": bannerImage,
  };

}

class ExtraPrice {
  ExtraPrice({
    required this.name,
    required this.nameJa,
    required this.nameEgy,
    required this.nameHi,
    required this.price,
    required this.type,
  });

  final String name;
  final dynamic nameJa;
  final dynamic nameEgy;
  final dynamic nameHi;
  final String price;
  final String type;

  factory ExtraPrice.fromJson(Map<String, dynamic> json){
    return ExtraPrice(
      name: json["name"] ?? "",
      nameJa: json["name_ja"],
      nameEgy: json["name_egy"],
      nameHi: json["name_hi"],
      price: json["price"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "name_ja": nameJa,
    "name_egy": nameEgy,
    "name_hi": nameHi,
    "price": price,
    "type": type,
  };

}

class Policy {
  Policy({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory Policy.fromJson(Map<String, dynamic> json){
    return Policy(
      title: json["title"] ?? "",
      content: json["content"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
  };

}

class ServiceFee {
  ServiceFee({
    required this.name,
    required this.desc,
    required this.nameJa,
    required this.descJa,
    required this.nameEgy,
    required this.descEgy,
    required this.nameHi,
    required this.descHi,
    required this.price,
    required this.unit,
    required this.type,
  });

  final String name;
  final dynamic desc;
  final dynamic nameJa;
  final dynamic descJa;
  final dynamic nameEgy;
  final dynamic descEgy;
  final dynamic nameHi;
  final dynamic descHi;
  final String price;
  final String unit;
  final String type;

  factory ServiceFee.fromJson(Map<String, dynamic> json){
    return ServiceFee(
      name: json["name"] ?? "",
      desc: json["desc"],
      nameJa: json["name_ja"],
      descJa: json["desc_ja"],
      nameEgy: json["name_egy"],
      descEgy: json["desc_egy"],
      nameHi: json["name_hi"],
      descHi: json["desc_hi"],
      price: json["price"] ?? "",
      unit: json["unit"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "desc": desc,
    "name_ja": nameJa,
    "desc_ja": descJa,
    "name_egy": nameEgy,
    "desc_egy": descEgy,
    "name_hi": nameHi,
    "desc_hi": descHi,
    "price": price,
    "unit": unit,
    "type": type,
  };

}

class HotelTranslation {
  HotelTranslation({
    required this.id,
    required this.originId,
    required this.locale,
    required this.title,
    required this.content,
    required this.address,
    required this.policy,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.surrounding,
  });

  final int id;
  final int originId;
  final String locale;
  final String title;
  final String content;
  final String address;
  final List<Policy> policy;
  final int createUser;
  final int updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic surrounding;

  factory HotelTranslation.fromJson(Map<String, dynamic> json){
    return HotelTranslation(
      id: json["id"] ?? 0,
      originId: json["origin_id"] ?? 0,
      locale: json["locale"] ?? "",
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      address: json["address"] ?? "",
      policy: json["policy"] == null ? [] : List<Policy>.from(json["policy"]!.map((x) => Policy.fromJson(x))),
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      surrounding: json["surrounding"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "origin_id": originId,
    "locale": locale,
    "title": title,
    "content": content,
    "address": address,
    "policy": policy.map((x) => x?.toJson()).toList(),
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "surrounding": surrounding,
  };

}

class Pagination {
  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;

  factory Pagination.fromJson(Map<String, dynamic> json){
    return Pagination(
      total: json["total"] ?? 0,
      perPage: json["per_page"] ?? 0,
      currentPage: json["current_page"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      from: json["from"] ?? 0,
      to: json["to"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "current_page": currentPage,
    "last_page": lastPage,
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
