class CouponModel {
  CouponModel({
    required this.status,
    required this.list,
  });

  final bool status;
  final List<Couponlist> list;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      status: json["status"] ?? false,
      list: json["list"] == null
          ? []
          : List<Couponlist>.from(
              json["list"]!.map((x) => Couponlist.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "list": list.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $list, ";
  }
}

class Couponlist {
  Couponlist({
    required this.id,
    required this.addedBy,
    required this.couponType,
    required this.couponBearer,
    required this.sellerId,
    required this.customerId,
    required this.title,
    required this.code,
    required this.startDate,
    required this.expireDate,
    required this.minPurchase,
    required this.maxDiscount,
    required this.discount,
    required this.discountType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.limit,
  });

  final int id;
  final String addedBy;
  final String couponType;
  final String couponBearer;
  final int sellerId;
  final int customerId;
  final String title;
  final String code;
  final DateTime? startDate;
  final DateTime? expireDate;
  final int minPurchase;
  final int maxDiscount;
  final int discount;
  final String discountType;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int limit;

  factory Couponlist.fromJson(Map<String, dynamic> json) {
    return Couponlist(
      id: json["id"] ?? 0,
      addedBy: json["added_by"] ?? "",
      couponType: json["coupon_type"] ?? "",
      couponBearer: json["coupon_bearer"] ?? "",
      sellerId: json["seller_id"] ?? 0,
      customerId: json["customer_id"] ?? 0,
      title: json["title"] ?? "",
      code: json["code"] ?? "",
      startDate: DateTime.tryParse(json["start_date"] ?? ""),
      expireDate: DateTime.tryParse(json["expire_date"] ?? ""),
      minPurchase: json["min_purchase"] ?? 0,
      maxDiscount: json["max_discount"] ?? 0,
      discount: json["discount"] ?? 0,
      discountType: json["discount_type"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      limit: json["limit"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "added_by": addedBy,
        "coupon_type": couponType,
        "coupon_bearer": couponBearer,
        "seller_id": sellerId,
        "customer_id": customerId,
        "title": title,
        "code": code,
        "start_date": startDate?.toIso8601String(),
        "expire_date": expireDate?.toIso8601String(),
        "min_purchase": minPurchase,
        "max_discount": maxDiscount,
        "discount": discount,
        "discount_type": discountType,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "limit": limit,
      };

  @override
  String toString() {
    return "$id, $addedBy, $couponType, $couponBearer, $sellerId, $customerId, $title, $code, $startDate, $expireDate, $minPurchase, $maxDiscount, $discount, $discountType, $status, $createdAt, $updatedAt, $limit, ";
  }
}
