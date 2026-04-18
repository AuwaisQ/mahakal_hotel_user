class TourAvailibilityModel {
  TourAvailibilityModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final Data? data;

  factory TourAvailibilityModel.fromJson(Map<String, dynamic> json){
    return TourAvailibilityModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.availableSeatsByDate,
    required this.totalSeats,
  });

  final Map<String, int> availableSeatsByDate;
  final int totalSeats;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      availableSeatsByDate: Map.from(json["available_seats_by_date"]).map((k, v) => MapEntry<String, int>(k, v)),
      totalSeats: json["total_seats"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "available_seats_by_date": Map.from(availableSeatsByDate).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "total_seats": totalSeats,
  };

}
