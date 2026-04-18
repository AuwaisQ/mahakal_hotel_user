// features_hotel_model.dart

class FeaturesHotelModel {
  final bool status;
  final HotelData? data;
  final String message;

  FeaturesHotelModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory FeaturesHotelModel.fromJson(Map<String, dynamic> json) {
    return FeaturesHotelModel(
      status: json['status'] == true,
      data: json['data'] != null ? HotelData.fromJson(json['data']) : null,
      message: json['message']?.toString() ?? '',
    );
  }
}

class HotelData {
  final List<Hotel> hotels;

  HotelData({required this.hotels});

  factory HotelData.fromJson(Map<String, dynamic> json) {
    return HotelData(
      hotels: json['hotels'] == null
          ? []
          : List<Hotel>.from(
        json['hotels'].map((x) => Hotel.fromJson(x)),
      ),
    );
  }
}

class Hotel {
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
  final dynamic updateUser;
  final dynamic vendorId;
  final dynamic deletedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String reviewScore;
  final dynamic icalImportUrl;

  final int enableExtraPrice;
  final List<ExtraPrice> extraPrice;

  final dynamic enableServiceFee;
  final dynamic serviceFee;
  final dynamic surrounding;

  final int authorId;
  final dynamic minDayBeforeBooking;
  final dynamic minDayStays;

  final String image;
  final String bannerImage;

  Hotel({
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
    required this.image,
    required this.bannerImage,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      content: json['content']?.toString() ?? '',

      imageId: json['image_id'] ?? 0,
      bannerImageId: json['banner_image_id'] ?? 0,
      locationId: json['location_id'] ?? 0,
      address: json['address']?.toString() ?? '',

      mapLat: json['map_lat']?.toString() ?? '',
      mapLng: json['map_lng']?.toString() ?? '',
      mapZoom: json['map_zoom'] ?? 0,
      isFeatured: json['is_featured'] ?? 0,

      gallery: json['gallery'] == null
          ? []
          : List<String>.from(
        json['gallery'].map((x) => x.toString()),
      ),

      video: json['video']?.toString() ?? '',

      policy: json['policy'] == null
          ? []
          : List<Policy>.from(
        json['policy'].map((x) => Policy.fromJson(x)),
      ),

      starRate: json['star_rate'] ?? 0,

      // price can be Map / String / int
      price: json['price'] is Map
          ? json['price']['main_price']?.toString() ?? ''
          : json['price']?.toString() ?? '',

      checkInTime: json['check_in_time']?.toString() ?? '',
      checkOutTime: json['check_out_time']?.toString() ?? '',

      allowFullDay: json['allow_full_day'],
      salePrice: json['sale_price'],
      relatedIds: json['related_ids'],

      status: json['status']?.toString() ?? '',
      createUser: json['create_user'] ?? 0,
      updateUser: json['update_user'],
      vendorId: json['vendor_id'],
      deletedAt: json['deleted_at'],

      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),

      reviewScore: json['review_score']?.toString() ?? '',
      icalImportUrl: json['ical_import_url'],

      enableExtraPrice: json['enable_extra_price'] ?? 0,

      extraPrice: json['extra_price'] == null
          ? []
          : List<ExtraPrice>.from(
        json['extra_price'].map((x) => ExtraPrice.fromJson(x)),
      ),

      enableServiceFee: json['enable_service_fee'],
      serviceFee: json['service_fee'],
      surrounding: json['surrounding'],

      authorId: json['author_id'] ?? 0,
      minDayBeforeBooking: json['min_day_before_booking'],
      minDayStays: json['min_day_stays'],

      // image & banner_image can be Map or String
      image: json['image'] is Map
          ? json['image']['url']?.toString() ?? ''
          : json['image']?.toString() ?? '',

      bannerImage: json['banner_image'] is Map
          ? json['banner_image']['url']?.toString() ?? ''
          : json['banner_image']?.toString() ?? '',
    );
  }
}

class ExtraPrice {
  final String name;
  final String price;
  final String type;

  ExtraPrice({
    required this.name,
    required this.price,
    required this.type,
  });

  factory ExtraPrice.fromJson(Map<String, dynamic> json) {
    return ExtraPrice(
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class Policy {
  final String title;
  final String content;

  Policy({
    required this.title,
    required this.content,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}
