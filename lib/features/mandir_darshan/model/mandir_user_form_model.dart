// To parse this JSON data, do
//
//     final userFormModel = userFormModelFromJson(jsonString);

import 'dart:convert';

UserFormModel userFormModelFromJson(String str) => UserFormModel.fromJson(json.decode(str));

String userFormModelToJson(UserFormModel data) => json.encode(data.toJson());

class UserFormModel {
  int status;
  String message;
  Data data;

  UserFormModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserFormModel.fromJson(Map<String, dynamic> json) => UserFormModel(
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
  List<String> service;
  List<Bhojan> darshan;
  List<Bhojan> puja;
  List<Bhojan> bhojan;
  List<Bhojan> locker;
  List<Purohit> purohit;
  List<UserAadhar> userAadhar;
  int id;
  String enTempleName;
  String hiTempleName;
  String enShortDescription;
  String hiShortDescription;
  String enDetails;
  String hiDetails;
  int aadhaarVerifyStatus;
  String image;

  Data({
    required this.service,
    required this.darshan,
    required this.puja,
    required this.bhojan,
    required this.locker,
    required this.purohit,
    required this.userAadhar,
    required this.id,
    required this.enTempleName,
    required this.hiTempleName,
    required this.enShortDescription,
    required this.hiShortDescription,
    required this.enDetails,
    required this.hiDetails,
    required this.aadhaarVerifyStatus,
    required this.image,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    service: List<String>.from(json["service"].map((x) => x)),
    darshan: List<Bhojan>.from(json["darshan"].map((x) => Bhojan.fromJson(x))),
    puja: List<Bhojan>.from(json["puja"].map((x) => Bhojan.fromJson(x))),
    bhojan: List<Bhojan>.from(json["bhojan"].map((x) => Bhojan.fromJson(x))),
    locker: List<Bhojan>.from(json["locker"].map((x) => Bhojan.fromJson(x))),
    purohit: List<Purohit>.from(json["purohit"].map((x) => Purohit.fromJson(x))),
    userAadhar: List<UserAadhar>.from(json["user_aadhar"].map((x) => UserAadhar.fromJson(x))),
    id: json["id"],
    enTempleName: json["en_temple_name"],
    hiTempleName: json["hi_temple_name"],
    enShortDescription: json["en_short_description"],
    hiShortDescription: json["hi_short_description"],
    enDetails: json["en_details"],
    hiDetails: json["hi_details"],
    aadhaarVerifyStatus: json["aadhaar_verify_status"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "service": List<dynamic>.from(service.map((x) => x)),
    "darshan": List<dynamic>.from(darshan.map((x) => x.toJson())),
    "puja": List<dynamic>.from(puja.map((x) => x.toJson())),
    "bhojan": List<dynamic>.from(bhojan.map((x) => x.toJson())),
    "locker": List<dynamic>.from(locker.map((x) => x.toJson())),
    "purohit": List<dynamic>.from(purohit.map((x) => x.toJson())),
    "user_aadhar": List<dynamic>.from(userAadhar.map((x) => x.toJson())),
    "id": id,
    "en_temple_name": enTempleName,
    "hi_temple_name": hiTempleName,
    "en_short_description": enShortDescription,
    "hi_short_description": hiShortDescription,
    "en_details": enDetails,
    "hi_details": hiDetails,
    "aadhaar_verify_status": aadhaarVerifyStatus,
    "image": image,
  };
}

class Bhojan {
  String varientName;
  String basePrice;
  int dailySlotsLimit;
  int id;
  String platformFeePercentage;
  String receiptFeePercentage;
  String gstRate;

  Bhojan({
    required this.varientName,
    required this.basePrice,
    required this.dailySlotsLimit,
    required this.id,
    required this.platformFeePercentage,
    required this.receiptFeePercentage,
    required this.gstRate,
  });

  factory Bhojan.fromJson(Map<String, dynamic> json) => Bhojan(
    varientName: json["varient_name"],
    basePrice: json["base_price"],
    dailySlotsLimit: json["daily_slots_limit"],
    id: json["id"],
    platformFeePercentage: json["platform_fee_percentage"],
    receiptFeePercentage: json["receipt_fee_percentage"],
    gstRate: json["gst_rate"],
  );

  Map<String, dynamic> toJson() => {
    "varient_name": varientName,
    "base_price": basePrice,
    "daily_slots_limit": dailySlotsLimit,
    "id": id,
    "platform_fee_percentage": platformFeePercentage,
    "receipt_fee_percentage": receiptFeePercentage,
    "gst_rate": gstRate,
  };
}

class Purohit {
  String name;
  int id;

  Purohit({
    required this.name,
    required this.id,
  });

  factory Purohit.fromJson(Map<String, dynamic> json) => Purohit(
    name: json["name"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
  };
}

class UserAadhar {
  String name;
  String phone;
  String aadhar;

  UserAadhar({
    required this.name,
    required this.phone,
    required this.aadhar,
  });

  factory UserAadhar.fromJson(Map<String, dynamic> json) => UserAadhar(
    name: json["name"],
    phone: json["phone"],
    aadhar: json["aadhar"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "aadhar": aadhar,
  };
}


class Slote {
  String startTime;
  String endTime;
  String dayOfWeek;
  int slotsLimiCapacity;
  int id;

  Slote({
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.slotsLimiCapacity,
    required this.id,
  });

  factory Slote.fromJson(Map<String, dynamic> json) => Slote(
    startTime: json['start_time'],
    endTime: json['end_time'],
    dayOfWeek: json['day_of_week'],
    slotsLimiCapacity: json['slots_limi_capacity'],
    id: json['id'],
  );

  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'end_time': endTime,
    'day_of_week': dayOfWeek,
    'slots_limi_capacity': slotsLimiCapacity,
    'id': id,
  };
}
