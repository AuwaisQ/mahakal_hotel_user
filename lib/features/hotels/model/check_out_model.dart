class CheckOutModel {
  CheckOutModel({
    required this.url,
    required this.bookingCode,
    required this.status,
    required this.message,
  });

  final String url;
  final String bookingCode;
  final int status;
  final String message;

  factory CheckOutModel.fromJson(Map<String, dynamic> json){
    return CheckOutModel(
      url: json["url"] ?? "",
      bookingCode: json["booking_code"] ?? "",
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "booking_code": bookingCode,
    "status": status,
    "message": message,
  };

}
