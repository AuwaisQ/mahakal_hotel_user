// To parse this JSON data, do
//
//     final eventPackageModel = eventPackageModelFromJson(jsonString);

import 'dart:convert';

EventPackageModel eventPackageModelFromJson(String str) => EventPackageModel.fromJson(json.decode(str));

String eventPackageModelToJson(EventPackageModel data) => json.encode(data.toJson());

class EventPackageModel {
  int status;
  String message;
  Data data;

  EventPackageModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EventPackageModel.fromJson(Map<String, dynamic> json) => EventPackageModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<Date> date;
  int requiredAadharStatus;
  int auditorium;

  Data({
    required this.date,
    required this.requiredAadharStatus,
    required this.auditorium,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: List<Date>.from(json["date"].map((x) => Date.fromJson(x))),
    requiredAadharStatus: json["required_aadhar_status"],
    auditorium: json["auditorium"],
  );

  Map<String, dynamic> toJson() => {
    "date": List<dynamic>.from(date.map((x) => x.toJson())),
    "required_aadhar_status": requiredAadharStatus,
    "auditorium": auditorium,
  };
}

class Date {
  int id;
  DateTime date;
  String startTime;
  String endTime;
  String eventDuration;
  List<EventPackageList> packageList;

  Date({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.eventDuration,
    required this.packageList,
  });

  factory Date.fromJson(Map<String, dynamic> json) => Date(
    id: json["id"],
    date: DateTime.parse(json["date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    eventDuration: json["event_duration"],
    packageList: List<EventPackageList>.from(json["package_list"].map((x) => EventPackageList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "event_duration": eventDuration,
    "package_list": List<dynamic>.from(packageList.map((x) => x.toJson())),
  };
}

class EventPackageList {
  String packageId;
  String enPackageName;
  String hiPackageName;
  String enDescription;
  String hiDescription;
  String seatsNo;
  String price;
  String available;
  String sold;

  EventPackageList({
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.enDescription,
    required this.hiDescription,
    required this.seatsNo,
    required this.price,
    required this.available,
    required this.sold,
  });

  factory EventPackageList.fromJson(Map<String, dynamic> json) => EventPackageList(
    packageId: json["package_id"],
    enPackageName: json["en_package_name"],
    hiPackageName: json["hi_package_name"],
    enDescription: json["en_description"],
    hiDescription: json["hi_description"],
    seatsNo: json["seats_no"],
    price: json["price"],
    available: json["available"],
    sold: json["sold"],
  );

  Map<String, dynamic> toJson() => {
    "package_id": packageId,
    "en_package_name": enPackageName,
    "hi_package_name": hiPackageName,
    "en_description": enDescription,
    "hi_description": hiDescription,
    "seats_no": seatsNo,
    "price": price,
    "available": available,
    "sold": sold,
  };
}
