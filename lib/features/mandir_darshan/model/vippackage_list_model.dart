class VipPackageModel {
  VipPackageModel({
    required this.vipBookingPackage,
  });

  final List<VipBookingPackage> vipBookingPackage;

  factory VipPackageModel.fromJson(Map<String, dynamic> json) {
    return VipPackageModel(
      vipBookingPackage: json["vip_booking_package"] == null
          ? []
          : List<VipBookingPackage>.from(json["vip_booking_package"]!
              .map((x) => VipBookingPackage.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "vip_booking_package":
            vipBookingPackage.map((x) => x.toJson()).toList(),
      };
}

class VipBookingPackage {
  VipBookingPackage({
    required this.id,
    required this.price,
    required this.package,
    required this.name,
  });

  final int id;
  final String price;
  final String package;
  final String name;

  factory VipBookingPackage.fromJson(Map<String, dynamic> json) {
    return VipBookingPackage(
      id: json["id"] ?? 0,
      price: json["price"] ?? "",
      package: json["package"] ?? "",
      name: json["name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "package": package,
        "name": name,
      };
}
