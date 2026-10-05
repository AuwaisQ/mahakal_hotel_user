class ParkingOrderModel {
  bool? status;
  String? message;
  List<ParkingOrder>? data;

  ParkingOrderModel({this.status, this.message, this.data});

  ParkingOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ParkingOrder>[];
      json['data'].forEach((v) {
        data!.add(ParkingOrder.fromJson(v));
      });
    }
  }
}

class ParkingOrder {
  int? id;
  String? cabName;
  String? cabRegisterNumber;
  String? color;
  int? durationHours;
  String? arrivalTime;
  String? depatureTime;
  String? amount;
  String? status;
  String? parkingName;
  String? createdAt;

  ParkingOrder({
    this.id,
    this.cabName,
    this.cabRegisterNumber,
    this.color,
    this.durationHours,
    this.arrivalTime,
    this.depatureTime,
    this.amount,
    this.status,
    this.parkingName,
    this.createdAt,
  });

  ParkingOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cabName = json['cab_name'];
    cabRegisterNumber = json['cab_register_number'];
    color = json['color'];
    durationHours = json['duration_hours'];
    arrivalTime = json['arrival_time'];
    depatureTime = json['depature_time'] ?? json['departure_time'];
    amount = json['amount'];
    status = json['status'];
    parkingName = json['parking_name'];
    createdAt = json['created_at'];
  }
}

class ParkingOrderDetailsModel {
  bool? status;
  String? message;
  ParkingOrderDetails? data;

  ParkingOrderDetailsModel({this.status, this.message, this.data});

  ParkingOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ParkingOrderDetails.fromJson(json['data']) : null;
  }
}

class ParkingOrderDetails {
  int? id;
  int? vendorId;
  int? addressId;
  int? userId;
  String? qrcode;
  String? cabName;
  String? cabRegisterNumber;
  String? color;
  String? userName;
  String? userPhone;
  String? aadhar;
  int? durationHours;
  String? arrivalTime;
  String? depatureTime;
  String? inTime;
  String? outTime;
  String? amount;
  String? platform;
  String? status;
  String? parkingName;
  String? parkingAddress;
  String? parkingLat;
  String? parkingLong;
  String? createdAt;

  ParkingOrderDetails({
    this.id,
    this.vendorId,
    this.addressId,
    this.userId,
    this.qrcode,
    this.cabName,
    this.cabRegisterNumber,
    this.color,
    this.userName,
    this.userPhone,
    this.aadhar,
    this.durationHours,
    this.arrivalTime,
    this.depatureTime,
    this.inTime,
    this.outTime,
    this.amount,
    this.platform,
    this.status,
    this.parkingName,
    this.parkingAddress,
    this.parkingLat,
    this.parkingLong,
    this.createdAt,
  });

  ParkingOrderDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    addressId = json['address_id'];
    userId = json['user_id'];
    qrcode = json['qrcode'];
    cabName = json['cab_name'];
    cabRegisterNumber = json['cab_register_number'];
    color = json['color'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    aadhar = json['aadhar'];
    durationHours = json['duration_hours'];
    arrivalTime = json['arrival_time'];
    depatureTime = json['depature_time'] ?? json['departure_time'];
    inTime = json['in_time'];
    outTime = json['out_time'];
    amount = json['amount'];
    platform = json['platform'];
    status = json['status'];
    parkingName = json['parking_name'];
    parkingAddress = json['parking_address'];
    parkingLat = json['parking_lat'];
    parkingLong = json['parking_long'];
    createdAt = json['created_at'];
  }
}
