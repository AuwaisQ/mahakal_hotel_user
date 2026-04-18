class HotelOrderDetailModel {
  HotelOrderDetailModel({
    required this.booking,
    required this.gateway,
    required this.status,
  });

  final HotelBooking? booking;
  final Gateway? gateway;
  final int? status;

  factory HotelOrderDetailModel.fromJson(Map<String, dynamic> json){
    return HotelOrderDetailModel(
      booking: json["booking"] == null ? null : HotelBooking.fromJson(json["booking"]),
      gateway: json["gateway"] == null ? null : Gateway.fromJson(json["gateway"]),
      status: json["status"],
    );
  }

}

class HotelBooking {
  HotelBooking({
    required this.id,
    required this.code,
    required this.vendorId,
    required this.customerId,
    required this.paymentId,
    required this.gateway,
    required this.objectId,
    required this.objectModel,
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.totalGuests,
    required this.currency,
    required this.status,
    required this.deposit,
    required this.depositType,
    required this.commission,
    required this.commissionType,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.address2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.customerNotes,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.buyerFees,
    required this.totalBeforeFees,
    required this.paidVendor,
    required this.objectChildId,
    required this.number,
    required this.paid,
    required this.payNow,
    required this.walletCreditUsed,
    required this.walletTotalUsed,
    required this.walletTransactionId,
    required this.isRefundWallet,
    required this.isPaid,
    required this.totalBeforeDiscount,
    required this.couponAmount,
    required this.service,
    required this.roomBooking,
  });

  final int? id;
  final String? code;
  final dynamic vendorId;
  final int? customerId;
  final dynamic paymentId;
  final String? gateway;
  final int? objectId;
  final String? objectModel;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? total;
  final int? totalGuests;
  final dynamic currency;
  final String? status;
  final dynamic deposit;
  final dynamic depositType;
  final dynamic commission;
  final String? commissionType;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final dynamic address2;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final dynamic customerNotes;
  final int? createUser;
  final int? updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? buyerFees;
  final String? totalBeforeFees;
  final dynamic paidVendor;
  final dynamic objectChildId;
  final dynamic number;
  final String? paid;
  final String? payNow;
  final int? walletCreditUsed;
  final dynamic walletTotalUsed;
  final dynamic walletTransactionId;
  final dynamic isRefundWallet;
  final dynamic isPaid;
  final String? totalBeforeDiscount;
  final String? couponAmount;
  final HotelService? service;
  final RoomBooking? roomBooking;

  factory HotelBooking.fromJson(Map<String, dynamic> json){
    return HotelBooking(
      id: json["id"],
      code: json["code"],
      vendorId: json["vendor_id"],
      customerId: json["customer_id"],
      paymentId: json["payment_id"],
      gateway: json["gateway"],
      objectId: json["object_id"],
      objectModel: json["object_model"],
      startDate: DateTime.tryParse(json["start_date"] ?? ""),
      endDate: DateTime.tryParse(json["end_date"] ?? ""),
      total: json["total"],
      totalGuests: json["total_guests"],
      currency: json["currency"],
      status: json["status"],
      deposit: json["deposit"],
      depositType: json["deposit_type"],
      commission: json["commission"],
      commissionType: json["commission_type"],
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      phone: json["phone"],
      address: json["address"],
      address2: json["address2"],
      city: json["city"],
      state: json["state"],
      zipCode: json["zip_code"],
      country: json["country"],
      customerNotes: json["customer_notes"],
      createUser: json["create_user"],
      updateUser: json["update_user"],
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      buyerFees: json["buyer_fees"],
      totalBeforeFees: json["total_before_fees"],
      paidVendor: json["paid_vendor"],
      objectChildId: json["object_child_id"],
      number: json["number"],
      paid: json["paid"],
      payNow: json["pay_now"],
      walletCreditUsed: json["wallet_credit_used"],
      walletTotalUsed: json["wallet_total_used"],
      walletTransactionId: json["wallet_transaction_id"],
      isRefundWallet: json["is_refund_wallet"],
      isPaid: json["is_paid"],
      totalBeforeDiscount: json["total_before_discount"],
      couponAmount: json["coupon_amount"],
      service: json["service"] == null ? null : HotelService.fromJson(json["service"]),
      roomBooking: json["room_booking"] == null ? null : RoomBooking.fromJson(json["room_booking"]),
    );
  }

}

class HotelService {
  HotelService({
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
  });

  final int id;
  final String title;
  final String slug;
  final String content;
  final int imageId;
  final int bannerImageId;
  final int locationId;
  final dynamic address;
  final String mapLat;
  final String mapLng;
  final int mapZoom;
  final int isFeatured;
  final String gallery;
  final String video;
  final List<HotelPolicy> policy;
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
  final dynamic enableServiceFee;
  final List<ServicePrice> serviceFee;
  final dynamic surrounding;
  final int authorId;
  final dynamic minDayBeforeBooking;
  final dynamic minDayStays;

  factory HotelService.fromJson(Map<String, dynamic> json){
    return HotelService(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      slug: json["slug"] ?? "",
      content: json["content"] ?? "",
      imageId: json["image_id"] ?? 0,
      bannerImageId: json["banner_image_id"] ?? 0,
      locationId: json["location_id"] ?? 0,
      address: json["address"],
      mapLat: json["map_lat"] ?? "",
      mapLng: json["map_lng"] ?? "",
      mapZoom: json["map_zoom"] ?? 0,
      isFeatured: json["is_featured"] ?? 0,
      gallery: json["gallery"] ?? "",
      video: json["video"] ?? "",
      policy: json["policy"] == null ? [] : List<HotelPolicy>.from(json["policy"]!.map((x) => HotelPolicy.fromJson(x))),
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
      enableServiceFee: json["enable_service_fee"],
      serviceFee: json["service_fee"] == null ? [] : List<ServicePrice>.from(json["service_fee"]!.map((x) => ServicePrice.fromJson(x))),
      surrounding: json["surrounding"],
      authorId: json["author_id"] ?? 0,
      minDayBeforeBooking: json["min_day_before_booking"],
      minDayStays: json["min_day_stays"],
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
    "gallery": gallery,
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

class ServicePrice {
  ServicePrice({
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

  factory ServicePrice.fromJson(Map<String, dynamic> json){
    return ServicePrice(
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

class HotelPolicy {
  HotelPolicy({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  factory HotelPolicy.fromJson(Map<String, dynamic> json){
    return HotelPolicy(
      title: json["title"] ?? "",
      content: json["content"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
  };

}

class Gateway {
  Gateway({
    required this.name,
    required this.isOffline,
  });

  final String name;
  final bool isOffline;

  factory Gateway.fromJson(Map<String, dynamic> json){
    return Gateway(
      name: json["name"] ?? "",
      isOffline: json["is_offline"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "is_offline": isOffline,
  };

}

class RoomBooking {
  RoomBooking({
    required this.id,
    required this.roomId,
    required this.parentId,
    required this.bookingId,
    required this.startDate,
    required this.endDate,
    required this.number,
    required this.price,
    required this.createUser,
    required this.updateUser,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? roomId;
  final int? parentId;
  final int? bookingId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? number;
  final String? price;
  final int? createUser;
  final dynamic updateUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RoomBooking.fromJson(Map<String, dynamic> json){
    return RoomBooking(
      id: json["id"],
      roomId: json["room_id"],
      parentId: json["parent_id"],
      bookingId: json["booking_id"],
      startDate: DateTime.tryParse(json["start_date"] ?? ""),
      endDate: DateTime.tryParse(json["end_date"] ?? ""),
      number: json["number"],
      price: json["price"],
      createUser: json["create_user"],
      updateUser: json["update_user"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

}

class Surrounding {
  Surrounding({
    required this.name,
    required this.content,
    required this.value,
    required this.type,
  });

  final String? name;
  final String? content;
  final String? value;
  final String? type;

  factory Surrounding.fromJson(Map<String, dynamic> json){
    return Surrounding(
      name: json["name"],
      content: json["content"],
      value: json["value"],
      type: json["type"],
    );
  }

}

