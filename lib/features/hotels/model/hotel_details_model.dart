class HotelDetailsModel {
  HotelDetailsModel({
    required this.status,
    required this.data,
  });

  final bool status;
  final Data? data;

  factory HotelDetailsModel.fromJson(Map<String, dynamic> json){
    return HotelDetailsModel(
      status: json["status"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.hotel,
    required this.relatedHotels,
    required this.locationCategories,
    required this.reviews,
    required this.adminbarButtons,
  });

  final DetailsHotel? hotel;
  final List<RelatedHotel> relatedHotels;
  final List<LocationCategory> locationCategories;
  final Reviews? reviews;
  final List<dynamic> adminbarButtons;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      hotel: json["hotel"] == null ? null : DetailsHotel.fromJson(json["hotel"]),
      relatedHotels: json["related_hotels"] == null ? [] : List<RelatedHotel>.from(json["related_hotels"]!.map((x) => RelatedHotel.fromJson(x))),
      locationCategories: json["location_categories"] == null ? [] : List<LocationCategory>.from(json["location_categories"]!.map((x) => LocationCategory.fromJson(x))),
      reviews: json["reviews"] == null ? null : Reviews.fromJson(json["reviews"]),
      adminbarButtons: json["adminbar_buttons"] == null ? [] : List<dynamic>.from(json["adminbar_buttons"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "hotel": hotel?.toJson(),
    "related_hotels": relatedHotels.map((x) => x?.toJson()).toList(),
    "location_categories": locationCategories.map((x) => x?.toJson()).toList(),
    "reviews": reviews?.toJson(),
    "adminbar_buttons": adminbarButtons.map((x) => x).toList(),
  };

}

class DetailsHotel {
  DetailsHotel({
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
  final dynamic isFeatured;
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
  final List<Surrounding> surrounding;
  final dynamic authorId;
  final int minDayBeforeBooking;
  final int minDayStays;
  final Location? location;
  final dynamic hasWishList;
  final List<TermsByAttributeInListingPage> termsByAttributeInListingPage;
  final String image;
  final String bannerImage;

  factory DetailsHotel.fromJson(Map<String, dynamic> json){
    return DetailsHotel(
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
      isFeatured: json["is_featured"],
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
      surrounding: json["surrounding"] == null ? [] : List<Surrounding>.from(json["surrounding"]!.map((x) => Surrounding.fromJson(x))),
      authorId: json["author_id"],
      minDayBeforeBooking: json["min_day_before_booking"] ?? 0,
      minDayStays: json["min_day_stays"] ?? 0,
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      hasWishList: json["has_wish_list"],
      termsByAttributeInListingPage: json["terms_by_attribute_in_listing_page"] == null ? [] : List<TermsByAttributeInListingPage>.from(json["terms_by_attribute_in_listing_page"]!.map((x) => TermsByAttributeInListingPage.fromJson(x))),
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
    "surrounding": surrounding.map((x) => x?.toJson()).toList(),
    "author_id": authorId,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "location": location?.toJson(),
    "has_wish_list": hasWishList,
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
    required this.perPerson,
  });

  final String name;
  final dynamic nameJa;
  final dynamic nameEgy;
  final dynamic nameHi;
  final String price;
  final String type;
  final String perPerson;

  factory ExtraPrice.fromJson(Map<String, dynamic> json){
    return ExtraPrice(
      name: json["name"] ?? "",
      nameJa: json["name_ja"],
      nameEgy: json["name_egy"],
      nameHi: json["name_hi"],
      price: json["price"] ?? "",
      type: json["type"] ?? "",
      perPerson: json["per_person"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "name_ja": nameJa,
    "name_egy": nameEgy,
    "name_hi": nameHi,
    "price": price,
    "type": type,
    "per_person": perPerson,
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
  });

  final int id;
  final String name;
  final dynamic content;
  final String slug;
  final dynamic imageId;
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

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      content: json["content"],
      slug: json["slug"] ?? "",
      imageId: json["image_id"],
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
    required this.perPerson,
  });

  final String name;
  final String desc;
  final String nameJa;
  final String descJa;
  final String nameEgy;
  final String descEgy;
  final String nameHi;
  final String descHi;
  final String price;
  final String unit;
  final String type;
  final String perPerson;

  factory ServiceFee.fromJson(Map<String, dynamic> json){
    return ServiceFee(
      name: json["name"] ?? "",
      desc: json["desc"] ?? "",
      nameJa: json["name_ja"] ?? "",
      descJa: json["desc_ja"] ?? "",
      nameEgy: json["name_egy"] ?? "",
      descEgy: json["desc_egy"] ?? "",
      nameHi: json["name_hi"] ?? "",
      descHi: json["desc_hi"] ?? "",
      price: json["price"] ?? "",
      unit: json["unit"] ?? "",
      type: json["type"] ?? "",
      perPerson: json["per_person"] ?? "",
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
    "per_person": perPerson,
  };

}

class Surrounding {
  Surrounding({
    required this.name,
    required this.content,
    required this.value,
    required this.type,
  });

  final String name;
  final String content;
  final String value;
  final String type;

  factory Surrounding.fromJson(Map<String, dynamic> json){
    return Surrounding(
      name: json["name"] ?? "",
      content: json["content"] ?? "",
      value: json["value"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "content": content,
    "value": value,
    "type": type,
  };

}

class TermsByAttributeInListingPage {
  TermsByAttributeInListingPage({
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
    required this.laravelThroughKey,
    required this.translation,
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
  final int laravelThroughKey;
  final dynamic translation;

  factory TermsByAttributeInListingPage.fromJson(Map<String, dynamic> json){
    return TermsByAttributeInListingPage(
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
      laravelThroughKey: json["laravel_through_key"] ?? 0,
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
    "laravel_through_key": laravelThroughKey,
    "translation": translation,
  };

}

class LocationCategory {
  LocationCategory({
    required this.id,
    required this.name,
    required this.iconClass,
    required this.content,
    required this.slug,
    required this.status,
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
  });

  final int id;
  final String name;
  final String iconClass;
  final dynamic content;
  final String slug;
  final String status;
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

  factory LocationCategory.fromJson(Map<String, dynamic> json){
    return LocationCategory(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      iconClass: json["icon_class"] ?? "",
      content: json["content"],
      slug: json["slug"] ?? "",
      status: json["status"] ?? "",
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
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon_class": iconClass,
    "content": content,
    "slug": slug,
    "status": status,
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
  };

}

class RelatedHotel {
  RelatedHotel({
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
    required this.authorId,
    required this.minDayBeforeBooking,
    required this.minDayStays,
    required this.location,
    required this.hasWishList,
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
  final dynamic isFeatured;
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
  final dynamic enableExtraPrice;
  final List<ExtraPrice> extraPrice;
  final dynamic enableServiceFee;
  final dynamic serviceFee;
  final int authorId;
  final int minDayBeforeBooking;
  final int minDayStays;
  final Location? location;
  final dynamic hasWishList;
  final String image;
  final String bannerImage;

  factory RelatedHotel.fromJson(Map<String, dynamic> json){
    return RelatedHotel(
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
      isFeatured: json["is_featured"],
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
      enableExtraPrice: json["enable_extra_price"],
      extraPrice: json["extra_price"] == null ? [] : List<ExtraPrice>.from(json["extra_price"]!.map((x) => ExtraPrice.fromJson(x))),
      enableServiceFee: json["enable_service_fee"],
      serviceFee: json["service_fee"],
      authorId: json["author_id"] ?? 0,
      minDayBeforeBooking: json["min_day_before_booking"] ?? 0,
      minDayStays: json["min_day_stays"] ?? 0,
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      hasWishList: json["has_wish_list"],
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
    "service_fee": serviceFee,
    "author_id": authorId,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "location": location?.toJson(),
    "has_wish_list": hasWishList,
    "image": image,
    "banner_image": bannerImage,
  };

}

class Reviews {
  Reviews({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  final int currentPage;
  final List<ReviewsDatum> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final dynamic nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final int to;
  final int total;

  factory Reviews.fromJson(Map<String, dynamic> json){
    return Reviews(
      currentPage: json["current_page"] ?? 0,
      data: json["data"] == null ? [] : List<ReviewsDatum>.from(json["data"]!.map((x) => ReviewsDatum.fromJson(x))),
      firstPageUrl: json["first_page_url"] ?? "",
      from: json["from"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      lastPageUrl: json["last_page_url"] ?? "",
      links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
      nextPageUrl: json["next_page_url"],
      path: json["path"] ?? "",
      perPage: json["per_page"] ?? 0,
      prevPageUrl: json["prev_page_url"],
      to: json["to"] ?? 0,
      total: json["total"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": data.map((x) => x?.toJson()).toList(),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links.map((x) => x?.toJson()).toList(),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };

}

class ReviewsDatum {
  ReviewsDatum({
    required this.id,
    required this.title,
    required this.content,
    required this.rateNumber,
    required this.authorIp,
    required this.status,
    required this.createdAt,
    required this.objectAuthorId,
    required this.authorId,
    required this.author,
  });

  final int id;
  final String title;
  final String content;
  final int rateNumber;
  final String authorIp;
  final String status;
  final DateTime? createdAt;
  final int objectAuthorId;
  final int authorId;
  final Author? author;

  factory ReviewsDatum.fromJson(Map<String, dynamic> json){
    return ReviewsDatum(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      rateNumber: json["rate_number"] ?? 0,
      authorIp: json["author_ip"] ?? "",
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      objectAuthorId: json["object_author_id"] ?? 0,
      authorId: json["author_id"] ?? 0,
      author: json["author"] == null ? null : Author.fromJson(json["author"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "rate_number": rateNumber,
    "author_ip": authorIp,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "object_author_id": objectAuthorId,
    "author_id": authorId,
    "author": author?.toJson(),
  };

}

class Author {
  Author({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.avatarId,
  });

  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final dynamic avatarId;

  factory Author.fromJson(Map<String, dynamic> json){
    return Author(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      avatarId: json["avatar_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "first_name": firstName,
    "last_name": lastName,
    "avatar_id": avatarId,
  };

}

class Link {
  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  final String url;
  final String label;
  final bool active;

  factory Link.fromJson(Map<String, dynamic> json){
    return Link(
      url: json["url"] ?? "",
      label: json["label"] ?? "",
      active: json["active"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };

}
