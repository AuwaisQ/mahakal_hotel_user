class HotelOrderListModel {
  HotelOrderListModel({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool success;
  final Data? data;
  final String message;

  factory HotelOrderListModel.fromJson(Map<String, dynamic> json){
    return HotelOrderListModel(
      success: json["success"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };

}

class Data {
  Data({
    required this.bookings,
    required this.statuses,
  });

  final Bookings? bookings;
  final List<String> statuses;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      bookings: json["bookings"] == null ? null : Bookings.fromJson(json["bookings"]),
      statuses: json["statuses"] == null ? [] : List<String>.from(json["statuses"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "bookings": bookings?.toJson(),
    "statuses": statuses.map((x) => x).toList(),
  };

}

class Bookings {
  Bookings({
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
  final List<HotelOrders> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final dynamic prevPageUrl;
  final int to;
  final int total;

  factory Bookings.fromJson(Map<String, dynamic> json){
    return Bookings(
      currentPage: json["current_page"] ?? 0,
      data: json["data"] == null ? [] : List<HotelOrders>.from(json["data"]!.map((x) => HotelOrders.fromJson(x))),
      firstPageUrl: json["first_page_url"] ?? "",
      from: json["from"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      lastPageUrl: json["last_page_url"] ?? "",
      links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
      nextPageUrl: json["next_page_url"] ?? "",
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

class HotelOrders {
  HotelOrders({
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
    required this.vendorServiceFeeAmount,
    required this.vendorServiceFee,
    required this.createUser,
    required this.updateUser,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
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
  });

  final int id;
  final String code;
  final int vendorId;
  final int customerId;
  final dynamic paymentId;
  final String gateway;
  final int objectId;
  final String objectModel;
  final DateTime? startDate;
  final DateTime? endDate;
  final String total;
  final int totalGuests;
  final dynamic currency;
  final String status;
  final dynamic deposit;
  final dynamic depositType;
  final dynamic commission;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final dynamic address2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String customerNotes;
  final String vendorServiceFeeAmount;
  final dynamic vendorServiceFee;
  final int createUser;
  final int updateUser;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String totalBeforeFees;
  final dynamic paidVendor;
  final dynamic objectChildId;
  final dynamic number;
  final String paid;
  final String payNow;
  final int walletCreditUsed;
  final dynamic walletTotalUsed;
  final dynamic walletTransactionId;
  final dynamic isRefundWallet;
  final dynamic isPaid;
  final String totalBeforeDiscount;
  final String couponAmount;

  factory HotelOrders.fromJson(Map<String, dynamic> json){
    return HotelOrders(
      id: json["id"] ?? 0,
      code: json["code"] ?? "",
      vendorId: json["vendor_id"] ?? 0,
      customerId: json["customer_id"] ?? 0,
      paymentId: json["payment_id"],
      gateway: json["gateway"] ?? "",
      objectId: json["object_id"] ?? 0,
      objectModel: json["object_model"] ?? "",
      startDate: DateTime.tryParse(json["start_date"] ?? ""),
      endDate: DateTime.tryParse(json["end_date"] ?? ""),
      total: json["total"] ?? "",
      totalGuests: json["total_guests"] ?? 0,
      currency: json["currency"],
      status: json["status"] ?? "",
      deposit: json["deposit"],
      depositType: json["deposit_type"],
      commission: json["commission"] ?? 0,
      email: json["email"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      address2: json["address2"],
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      zipCode: json["zip_code"] ?? "",
      country: json["country"] ?? "",
      customerNotes: json["customer_notes"] ?? "",
      vendorServiceFeeAmount: json["vendor_service_fee_amount"] ?? "",
      vendorServiceFee: json["vendor_service_fee"],
      createUser: json["create_user"] ?? 0,
      updateUser: json["update_user"] ?? 0,
      deletedAt: json["deleted_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      totalBeforeFees: json["total_before_fees"] ?? "",
      paidVendor: json["paid_vendor"],
      objectChildId: json["object_child_id"],
      number: json["number"],
      paid: json["paid"] ?? "",
      payNow: json["pay_now"] ?? "",
      walletCreditUsed: json["wallet_credit_used"] ?? 0,
      walletTotalUsed: json["wallet_total_used"],
      walletTransactionId: json["wallet_transaction_id"],
      isRefundWallet: json["is_refund_wallet"],
      isPaid: json["is_paid"],
      totalBeforeDiscount: json["total_before_discount"] ?? "",
      couponAmount: json["coupon_amount"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "vendor_id": vendorId,
    "customer_id": customerId,
    "payment_id": paymentId,
    "gateway": gateway,
    "object_id": objectId,
    "object_model": objectModel,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "total": total,
    "total_guests": totalGuests,
    "currency": currency,
    "status": status,
    "deposit": deposit,
    "deposit_type": depositType,
    "commission": commission,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "address": address,
    "address2": address2,
    "city": city,
    "state": state,
    "zip_code": zipCode,
    "country": country,
    "customer_notes": customerNotes,
    "vendor_service_fee_amount": vendorServiceFeeAmount,
    "vendor_service_fee": vendorServiceFee,
    "create_user": createUser,
    "update_user": updateUser,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "total_before_fees": totalBeforeFees,
    "paid_vendor": paidVendor,
    "object_child_id": objectChildId,
    "number": number,
    "paid": paid,
    "pay_now": payNow,
    "wallet_credit_used": walletCreditUsed,
    "wallet_total_used": walletTotalUsed,
    "wallet_transaction_id": walletTransactionId,
    "is_refund_wallet": isRefundWallet,
    "is_paid": isPaid,
    "total_before_discount": totalBeforeDiscount,
    "coupon_amount": couponAmount,
  };

}

class VendorServiceFeeElement {
  VendorServiceFeeElement({
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

  factory VendorServiceFeeElement.fromJson(Map<String, dynamic> json){
    return VendorServiceFeeElement(
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
