class ActivitiesOrderDetailModel {
  ActivitiesOrderDetailModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final Data? data;

  factory ActivitiesOrderDetailModel.fromJson(Map<String, dynamic> json){
    return ActivitiesOrderDetailModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.id,
    required this.orderNo,
    required this.eventId,
    required this.enEventName,
    required this.hiEventName,
    required this.organizerId,
    required this.enOrganizerName,
    required this.hiOrganizerName,
    required this.organizerImage,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.totalSeats,
    required this.subAmount,
    required this.taxAmount,
    required this.couponAmount,
    required this.totalAmount,
    required this.amountStatus,
    required this.categoryId,
    required this.enCategoryName,
    required this.hiCategoryName,
    required this.categoryImage,
    required this.eventImage,
    required this.enEventVenue,
    required this.hiEventVenue,
    required this.eventDate,
    required this.eventBookingDate,
    required this.reviewStatus,
  });

  final int id;
  final String orderNo;
  final int eventId;
  final String enEventName;
  final String hiEventName;
  final int organizerId;
  final String enOrganizerName;
  final String hiOrganizerName;
  final String organizerImage;
  final String userName;
  final String userPhone;
  final String userEmail;
  final int packageId;
  final String enPackageName;
  final String hiPackageName;
  final int totalSeats;
  final dynamic subAmount;
  final dynamic taxAmount;
  final dynamic couponAmount;
  final dynamic totalAmount;
  final int amountStatus;
  final int categoryId;
  final String enCategoryName;
  final String hiCategoryName;
  final String categoryImage;
  final String eventImage;
  final String enEventVenue;
  final String hiEventVenue;
  final String eventDate;
  final String eventBookingDate;
  final int reviewStatus;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["id"] ?? 0,
      orderNo: json["order_no"] ?? "",
      eventId: json["event_id"] ?? 0,
      enEventName: json["en_event_name"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      organizerId: json["organizer_id"] ?? 0,
      enOrganizerName: json["en_organizer_name"] ?? "",
      hiOrganizerName: json["hi_organizer_name"] ?? "",
      organizerImage: json["organizer_image"] ?? "",
      userName: json["user_name"] ?? "",
      userPhone: json["user_phone"] ?? "",
      userEmail: json["user_email"] ?? "",
      packageId: json["package_id"] ?? 0,
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      totalSeats: json["total_seats"] ?? 0,
      subAmount: json["sub_amount"] ?? 0.0,
      taxAmount: json["tax_amount"] ?? 0.0,
      couponAmount: json["coupon_amount"] ?? 0,
      totalAmount: json["total_amount"] ?? 0,
      amountStatus: json["amount_status"] ?? 0,
      categoryId: json["category_id"] ?? 0,
      enCategoryName: json["en_category_name"] ?? "",
      hiCategoryName: json["hi_category_name"] ?? "",
      categoryImage: json["category_image"] ?? "",
      eventImage: json["event_image"] ?? "",
      enEventVenue: json["en_event_venue"] ?? "",
      hiEventVenue: json["hi_event_venue"] ?? "",
      eventDate: json["event_date"] ?? "",
      eventBookingDate: json["event_booking_date"] ?? "",
      reviewStatus: json["review_status"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_no": orderNo,
    "event_id": eventId,
    "en_event_name": enEventName,
    "hi_event_name": hiEventName,
    "organizer_id": organizerId,
    "en_organizer_name": enOrganizerName,
    "hi_organizer_name": hiOrganizerName,
    "organizer_image": organizerImage,
    "user_name": userName,
    "user_phone": userPhone,
    "user_email": userEmail,
    "package_id": packageId,
    "en_package_name": enPackageName,
    "hi_package_name": hiPackageName,
    "total_seats": totalSeats,
    "sub_amount": subAmount,
    "tax_amount": taxAmount,
    "coupon_amount": couponAmount,
    "total_amount": totalAmount,
    "amount_status": amountStatus,
    "category_id": categoryId,
    "en_category_name": enCategoryName,
    "hi_category_name": hiCategoryName,
    "category_image": categoryImage,
    "event_image": eventImage,
    "en_event_venue": enEventVenue,
    "hi_event_venue": hiEventVenue,
    "event_date": eventDate,
    "event_booking_date": eventBookingDate,
    "review_status": reviewStatus,
  };

}
