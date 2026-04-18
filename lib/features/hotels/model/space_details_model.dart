class SpaceDetailsModel {
  SpaceDetailsModel({
    required this.success,
    required this.data,
  });

  final bool success;
  final Data? data;

  factory SpaceDetailsModel.fromJson(Map<String, dynamic> json){
    return SpaceDetailsModel(
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
    required this.space,
    required this.reviews,
    required this.relatedSpaces,
    required this.locationCategories,
    required this.wishlist,
    required this.admin,
  });

  final Space? space;
  final Reviews? reviews;
  final List<dynamic> relatedSpaces;
  final List<LocationCategory> locationCategories;
  final Wishlist? wishlist;
  final Admin? admin;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      space: json["space"] == null ? null : Space.fromJson(json["space"]),
      reviews: json["reviews"] == null ? null : Reviews.fromJson(json["reviews"]),
      relatedSpaces: json["related_spaces"] == null ? [] : List<dynamic>.from(json["related_spaces"]!.map((x) => x)),
      locationCategories: json["location_categories"] == null ? [] : List<LocationCategory>.from(json["location_categories"]!.map((x) => LocationCategory.fromJson(x))),
      wishlist: json["wishlist"] == null ? null : Wishlist.fromJson(json["wishlist"]),
      admin: json["admin"] == null ? null : Admin.fromJson(json["admin"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "space": space?.toJson(),
    "reviews": reviews?.toJson(),
    "related_spaces": relatedSpaces.map((x) => x).toList(),
    "location_categories": locationCategories.map((x) => x?.toJson()).toList(),
    "wishlist": wishlist?.toJson(),
    "admin": admin?.toJson(),
  };

}

class Admin {
  Admin({
    required this.buttons,
  });

  final List<dynamic> buttons;

  factory Admin.fromJson(Map<String, dynamic> json){
    return Admin(
      buttons: json["buttons"] == null ? [] : List<dynamic>.from(json["buttons"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "buttons": buttons.map((x) => x).toList(),
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
    required this.locationCategoryTranslations,
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
  final LocationCategoryTranslations? locationCategoryTranslations;

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
      locationCategoryTranslations: json["location_category_translations"] == null ? null : LocationCategoryTranslations.fromJson(json["location_category_translations"]),
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
    "location_category_translations": locationCategoryTranslations?.toJson(),
  };

}

class LocationCategoryTranslations {
  LocationCategoryTranslations({
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

  factory LocationCategoryTranslations.fromJson(Map<String, dynamic> json){
    return LocationCategoryTranslations(
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
  final List<SpaceReviewsList> data;
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
      data: json["data"] == null ? [] : List<SpaceReviewsList>.from(json["data"]!.map((x) => SpaceReviewsList.fromJson(x))),
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

class SpaceReviewsList {
  SpaceReviewsList({
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

  factory SpaceReviewsList.fromJson(Map<String, dynamic> json){
    return SpaceReviewsList(
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
    required this.gallery,
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
    required this.image,
    required this.bannerImage,
    required this.termsData,
    required this.location,
    required this.hasWishList,
    required this.terms,
    required this.translation,
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
  final List<DiscountByDay> discountByDays;
  final String status;
  final int defaultState;
  final int createUser;
  final int updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String reviewScore;
  final dynamic icalImportUrl;
  final int enableServiceFee;
  final List<ServiceFee> serviceFee;
  final List<Surrounding> surrounding;
  final int authorId;
  final int minDayBeforeBooking;
  final int minDayStays;
  final String image;
  final String bannerImage;
  final List<TermsDatum> termsData;
  final Location? location;
  final dynamic hasWishList;
  final List<Term> terms;
  final Translation? translation;

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
      gallery: json["gallery"] == null
          ? []
          : List<String>.from(
        json["gallery"]
            .where((x) => x != null)
            .map((x) => x as String),
      ),
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
      discountByDays: json["discount_by_days"] == null ? [] : List<DiscountByDay>.from(json["discount_by_days"]!.map((x) => DiscountByDay.fromJson(x))),
      status: json["status"] ?? "",
      defaultState: json["default_state"] ?? 0,
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      reviewScore: json["review_score"] ?? "",
      icalImportUrl: json["ical_import_url"],
      enableServiceFee: json["enable_service_fee"] ?? 0,
      serviceFee: json["service_fee"] == null ? [] : List<ServiceFee>.from(json["service_fee"]!.map((x) => ServiceFee.fromJson(x))),
      surrounding: json["surrounding"] == null ? [] : List<Surrounding>.from(json["surrounding"]!.map((x) => Surrounding.fromJson(x))),
      authorId: json["author_id"] ?? 0,
      minDayBeforeBooking: json["min_day_before_booking"] ?? 0,
      minDayStays: json["min_day_stays"] ?? 0,
      image: json["image"] ?? "",
      bannerImage: json["banner_image"] ?? "",
      termsData: json["terms_data"] == null ? [] : List<TermsDatum>.from(json["terms_data"]!.map((x) => TermsDatum.fromJson(x))),
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      hasWishList: json["has_wish_list"],
      terms: json["terms"] == null ? [] : List<Term>.from(json["terms"]!.map((x) => Term.fromJson(x))),
      translation: json["translation"] == null ? null : Translation.fromJson(json["translation"]),
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
    "discount_by_days": discountByDays.map((x) => x?.toJson()).toList(),
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
    "service_fee": serviceFee.map((x) => x?.toJson()).toList(),
    "surrounding": surrounding.map((x) => x?.toJson()).toList(),
    "author_id": authorId,
    "min_day_before_booking": minDayBeforeBooking,
    "min_day_stays": minDayStays,
    "image": image,
    "banner_image": bannerImage,
    "terms_data": termsData.map((x) => x?.toJson()).toList(),
    "location": location?.toJson(),
    "has_wish_list": hasWishList,
    "terms": terms.map((x) => x?.toJson()).toList(),
    "translation": translation?.toJson(),
  };

}

class DiscountByDay {
  DiscountByDay({
    required this.from,
    required this.to,
    required this.amount,
    required this.type,
  });

  final String from;
  final String to;
  final String amount;
  final String type;

  factory DiscountByDay.fromJson(Map<String, dynamic> json){
    return DiscountByDay(
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      amount: json["amount"] ?? "",
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "amount": amount,
    "type": type,
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
  final int updateUser;
  final dynamic deletedAt;
  final dynamic originId;
  final dynamic lang;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic bannerImageId;
  final dynamic tripIdeas;
  final LocationCategoryTranslations? translation;

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
      parentId: json["parent_id"],
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      originId: json["origin_id"],
      lang: json["lang"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      bannerImageId: json["banner_image_id"],
      tripIdeas: json["trip_ideas"],
      translation: json["translation"] == null ? null : LocationCategoryTranslations.fromJson(json["translation"]),
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

class Term {
  Term({
    required this.id,
    required this.termId,
    required this.targetId,
    required this.createUser,
    required this.updateUser,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int termId;
  final int targetId;
  final dynamic createUser;
  final dynamic updateUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Term.fromJson(Map<String, dynamic> json){
    return Term(
      id: json["id"] ?? 0,
      termId: json["term_id"] ?? 0,
      targetId: json["target_id"] ?? 0,
      createUser: json["create_user"],
      updateUser: json["update_user"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "term_id": termId,
    "target_id": targetId,
    "create_user": createUser,
    "update_user": updateUser,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

}

class TermsDatum {
  TermsDatum({
    required this.parent,
    required this.child,
  });

  final Parent? parent;
  final List<Child> child;

  factory TermsDatum.fromJson(Map<String, dynamic> json){
    return TermsDatum(
      parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
      child: json["child"] == null ? [] : List<Child>.from(json["child"]!.map((x) => Child.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "parent": parent?.toJson(),
    "child": child.map((x) => x?.toJson()).toList(),
  };

}

class Child {
  Child({
    required this.id,
    required this.title,
    required this.content,
    required this.imageId,
    required this.icon,
    required this.attrId,
    required this.slug,
  });

  final int id;
  final String title;
  final dynamic content;
  final String imageId;
  final dynamic icon;
  final int attrId;
  final String slug;

  factory Child.fromJson(Map<String, dynamic> json){
    return Child(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      content: json["content"],
      imageId: json["image_id"] ?? "",
      icon: json["icon"],
      attrId: json["attr_id"] ?? 0,
      slug: json["slug"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "image_id": imageId,
    "icon": icon,
    "attr_id": attrId,
    "slug": slug,
  };

}

class Parent {
  Parent({
    required this.id,
    required this.title,
    required this.slug,
    required this.service,
    required this.displayType,
    required this.hideInSingle,
  });

  final int id;
  final String title;
  final String slug;
  final String service;
  final dynamic displayType;
  final dynamic hideInSingle;

  factory Parent.fromJson(Map<String, dynamic> json){
    return Parent(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      slug: json["slug"] ?? "",
      service: json["service"] ?? "",
      displayType: json["display_type"],
      hideInSingle: json["hide_in_single"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "service": service,
    "display_type": displayType,
    "hide_in_single": hideInSingle,
  };

}

class Translation {
  Translation({
    required this.id,
    required this.originId,
    required this.locale,
    required this.title,
    required this.content,
    required this.faqs,
    required this.address,
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
  final List<Faq> faqs;
  final String address;
  final int createUser;
  final int updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, List<Surrounding>> surrounding;

  factory Translation.fromJson(Map<String, dynamic> json){
    return Translation(
      id: json["id"] ?? 0,
      originId: json["origin_id"] ?? 0,
      locale: json["locale"] ?? "",
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      faqs: json["faqs"] == null ? [] : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
      address: json["address"] ?? "",
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      surrounding: Map.from(json["surrounding"]).map((k, v) => MapEntry<String, List<Surrounding>>(k, v == null ? [] : List<Surrounding>.from(v!.map((x) => Surrounding.fromJson(x))))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "origin_id": originId,
    "locale": locale,
    "title": title,
    "content": content,
    "faqs": faqs.map((x) => x?.toJson()).toList(),
    "address": address,
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "surrounding": Map.from(surrounding).map((k, v) => MapEntry<String, dynamic>(k, v.map((x) => x?.toJson()).toList())),
  };

}

class Wishlist {
  Wishlist({
    required this.isWishlisted,
  });

  final bool isWishlisted;

  factory Wishlist.fromJson(Map<String, dynamic> json){
    return Wishlist(
      isWishlisted: json["is_wishlisted"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "is_wishlisted": isWishlisted,
  };

}
