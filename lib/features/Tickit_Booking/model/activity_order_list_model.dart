class ActivitiesOrderListModel {
  ActivitiesOrderListModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<ActivitiesOrders> data;

  factory ActivitiesOrderListModel.fromJson(Map<String, dynamic> json){
    return ActivitiesOrderListModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? [] : List<ActivitiesOrders>.from(json["data"]!.map((x) => ActivitiesOrders.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data.map((x) => x?.toJson()).toList(),
  };

}

class ActivitiesOrders {
  ActivitiesOrders({
    required this.id,
    required this.orderNo,
    required this.amount,
    required this.totalSeats,
    required this.amountStatus,
    required this.enEventName,
    required this.hiEventName,
    required this.eventImage,
    required this.eventBookingDate,
  });

  final int id;
  final String orderNo;
  final int amount;
  final int totalSeats;
  final int amountStatus;
  final String enEventName;
  final String hiEventName;
  final String eventImage;
  final String eventBookingDate;

  factory ActivitiesOrders.fromJson(Map<String, dynamic> json){
    return ActivitiesOrders(
      id: json["id"] ?? 0,
      orderNo: json["order_no"] ?? "",
      amount: json["amount"] ?? 0,
      totalSeats: json["total_seats"] ?? 0,
      amountStatus: json["amount_status"] ?? 0,
      enEventName: json["en_event_name"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      eventImage: json["event_image"] ?? "",
      eventBookingDate: json["event_booking_date"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_no": orderNo,
    "amount": amount,
    "total_seats": totalSeats,
    "amount_status": amountStatus,
    "en_event_name": enEventName,
    "hi_event_name": hiEventName,
    "event_image": eventImage,
    "event_booking_date": eventBookingDate,
  };

}
