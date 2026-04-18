class TickitSummeryModel {
  TickitSummeryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final TickitData? data;

  factory TickitSummeryModel.fromJson(Map<String, dynamic> json){
    return TickitSummeryModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : TickitData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

}

class TickitData {
  TickitData({
    required this.date,
    required this.weekly,
    required this.requiredAadharStatus,
    required this.auditorium,
  });

  final List<Date> date;
  final List<String> weekly;
  final int requiredAadharStatus;
  final int auditorium;

  factory TickitData.fromJson(Map<String, dynamic> json){
    return TickitData(
      date: json["date"] == null ? [] : List<Date>.from(json["date"]!.map((x) => Date.fromJson(x))),
      weekly: json["weekly"] == null ? [] : List<String>.from(json["weekly"]!.map((x) => x)),
      requiredAadharStatus: json["required_aadhar_status"] ?? 0,
      auditorium: json["auditorium"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "date": date.map((x) => x?.toJson()).toList(),
    "weekly": weekly.map((x) => x).toList(),
    "required_aadhar_status": requiredAadharStatus,
    "auditorium": auditorium,
  };

}

class Date {
  Date({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.eventDuration,
  });

  final int id;
  final String startTime;
  final String endTime;
  final String eventDuration;

  factory Date.fromJson(Map<String, dynamic> json){
    return Date(
      id: json["id"] ?? 0,
      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
      eventDuration: json["event_duration"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_time": startTime,
    "end_time": endTime,
    "event_duration": eventDuration,
  };

}
