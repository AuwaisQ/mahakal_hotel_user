class AllVendoresModel {
  AllVendoresModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final List<VendoresData> data;

  factory AllVendoresModel.fromJson(Map<String, dynamic> json) {
    return AllVendoresModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<VendoresData>.from(
              json["data"]!.map((x) => VendoresData.fromJson(x))),
    );
  }
}

class VendoresData {
  VendoresData({
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

  final int sellerId;
  final String companyName;
  final String image;
  final String banner;
  final int tourId;
  final int tourCount;
  final int reviewCount;
  final String reviewSum;
  final String avgRating;

  factory VendoresData.fromJson(Map<String, dynamic> json) {
    return VendoresData(
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
