class FormSubmissionModel {
  FormSubmissionModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final Data? data;

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json){
    return FormSubmissionModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.bookingId,
    required this.status,
    required this.detailUrl,
  });

  final int bookingId;
  final String status;
  final String detailUrl;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      bookingId: json["booking_id"] ?? 0,
      status: json["status"] ?? "",
      detailUrl: json["detail_url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "booking_id": bookingId,
    "status": status,
    "detail_url": detailUrl,
  };

}
