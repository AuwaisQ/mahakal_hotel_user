class AllVendorsTour {
  AllVendorsTour({
    required this.status,
    required this.message,
    required this.vendor,
    required this.data,
  });

  final int status;
  final String message;
  final Vendor? vendor;
  final List<AllTourData> data;

  factory AllVendorsTour.fromJson(Map<String, dynamic> json) {
    return AllVendorsTour(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
      data: json["data"] == null
          ? []
          : List<AllTourData>.from(
              json["data"]!.map((x) => AllTourData.fromJson(x))),
    );
  }
}

class AllTourData {
  AllTourData({
    required this.id,
    required this.enTourName,
    required this.numberOfDay,
    required this.numberOfNight,
    required this.isPersonUse,
    required this.isIncludedPackage,
    required this.percentageOff,
    required this.planTypeName,
    required this.tourImage,
    required this.useDate,
    required this.tourOrderReviewCount,
    required this.reviewAvgStar,
    required this.hiTourName,
    required this.offTotalPrice,
    required this.minTotalPrice,
    required this.planTypeColor,
  });

  final int id;
  final String enTourName;
  final dynamic numberOfDay;
  final dynamic numberOfNight;
  final dynamic isPersonUse;
  final List<String> isIncludedPackage;
  final dynamic percentageOff;
  final String planTypeName;
  final String tourImage;
  final dynamic useDate;
  final dynamic tourOrderReviewCount;
  final dynamic reviewAvgStar;
  final String hiTourName;
  final dynamic offTotalPrice;
  final dynamic minTotalPrice;
  final String planTypeColor;

  factory AllTourData.fromJson(Map<String, dynamic> json) {
    return AllTourData(
      id: json["id"] ?? 0,
      enTourName: json["en_tour_name"] ?? "",
      numberOfDay: json["number_of_day"] ?? "",
      numberOfNight: json["number_of_night"] ?? 0,
      isPersonUse: json["is_person_use"] ?? 0,
      isIncludedPackage: json["is_included_package"] == null
          ? []
          : List<String>.from(json["is_included_package"]!.map((x) => x)),
      percentageOff: json["percentage_off"] ?? 0,
      planTypeName: json["plan_type_name"] ?? "",
      tourImage: json["tour_image"] ?? "",
      useDate: json["use_date"] ?? 0,
      tourOrderReviewCount: json["tour_order_review_count"] ?? 0,
      reviewAvgStar: json["review_avg_star"] ?? "",
      hiTourName: json["hi_tour_name"] ?? "",
      offTotalPrice: json["off_total_price"] ?? 0,
      minTotalPrice: json["min_total_price"] ?? 0,
      planTypeColor: json["plan_type_color"] ?? "",
    );
  }
}

class Vendor {
  Vendor({
    required this.sellerId,
    required this.companyName,
    required this.image,
    required this.banner,
    required this.tourId,
    required this.tourCount,
    required this.reviewCount,
    required this.reviewSum,
    required this.avgRating,
  });

  final dynamic sellerId;
  final String companyName;
  final String image;
  final String banner;
  final dynamic tourId;
  final dynamic tourCount;
  final dynamic reviewCount;
  final dynamic reviewSum;
  final dynamic avgRating;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      sellerId: json["seller_id"] ?? 0,
      companyName: json["company_name"] ?? "",
      image: json["image"] ?? "",
      banner: json["banner"] ?? "",
      tourId: json["tour_id"] ?? 0,
      tourCount: json["tour_count"] ?? 0,
      reviewCount: json["review_count"] ?? 0,
      reviewSum: json["review_sum"] ?? "",
      avgRating: json["avg_rating"] ?? "",
    );
  }
}
