// To parse this JSON data, do
//
//     final cabBookingModel = cabBookingModelFromJson(jsonString);

import 'dart:convert';

CabBookingModel cabBookingModelFromJson(String str) => CabBookingModel.fromJson(json.decode(str));

String cabBookingModelToJson(CabBookingModel data) => json.encode(data.toJson());

class CabBookingModel {
  int? status;
  String? message;
  Data? data;

  CabBookingModel({
    this.status,
    this.message,
    this.data,
  });

  factory CabBookingModel.fromJson(Map<String, dynamic> json) => CabBookingModel(
    status: json['status'],
    message: json['message'],
    data: json['data'] == null ? null : Data.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class Data {
  int? id;
  String? orderId;
  String? serviceName;
  String? thumbnail;
  String? cabName;
  String? orderStatus;
  String? pickupAddress;
  String? pickupDate;
  dynamic dropAddress;
  String? returnAddress;
  String? returnDate;
  String? userName;
  String? age;
  String? phoneNumber;
  String? email;
  String? exTime;
  int? exChange;
  int? pickupOtp;
  int? pickupStatus;
  int? dropOtp;
  int? dropStatus;
  String? bookingPickKm;
  String? bookingReturnKm;
  String? bookingCabAc;
  int? orderAmount;
  int? subAmount;
  int? couponAmount;
  int? taxAmount;
  int? tax;
  int? securityAmount;
  int? securityDeposit;
  int? finalAmount;
  String? invoiceLink;

  Data({
    this.id,
    this.orderId,
    this.serviceName,
    this.thumbnail,
    this.cabName,
    this.orderStatus,
    this.pickupAddress,
    this.pickupDate,
    this.dropAddress,
    this.returnAddress,
    this.returnDate,
    this.userName,
    this.age,
    this.phoneNumber,
    this.email,
    this.exTime,
    this.exChange,
    this.pickupOtp,
    this.pickupStatus,
    this.dropOtp,
    this.dropStatus,
    this.bookingPickKm,
    this.bookingReturnKm,
    this.bookingCabAc,
    this.orderAmount,
    this.subAmount,
    this.couponAmount,
    this.taxAmount,
    this.tax,
    this.securityAmount,
    this.securityDeposit,
    this.finalAmount,
    this.invoiceLink,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json['id'],
    orderId: json['order_id'],
    serviceName: json['service_name'],
    thumbnail: json['thumbnail'],
    cabName: json['cab_name'],
    orderStatus: json['order_status'],
    pickupAddress: json['pickup_address'],
    pickupDate: json['pickup_date'],
    dropAddress: json['drop_address'],
    returnAddress: json['return_address'],
    returnDate: json['return_date'],
    userName: json['user_name'],
    age: json['age'],
    phoneNumber: json['phone_number'],
    email: json['email'],
    exTime: json['ex_time'],
    exChange: json['ex_change'],
    pickupOtp: json['pickup_otp'],
    pickupStatus: json['pickup_status'],
    dropOtp: json['drop_otp'],
    dropStatus: json['drop_status'],
    bookingPickKm: json['booking_pick_km'],
    bookingReturnKm: json['booking_return_km'],
    bookingCabAc: json['booking_cab_ac'],
    orderAmount: json['order_amount'],
    subAmount: json['sub_amount'],
    couponAmount: json['coupon_amount'],
    taxAmount: json['tax_amount'],
    tax: json['tax'],
    securityAmount: json['security_amount'],
    securityDeposit: json['security_deposit'],
    finalAmount: json['final_amount'],
    invoiceLink: json['invoice_link'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'service_name': serviceName,
    'thumbnail': thumbnail,
    'cab_name': cabName,
    'order_status': orderStatus,
    'pickup_address': pickupAddress,
    'pickup_date': pickupDate,
    'drop_address': dropAddress,
    'return_address': returnAddress,
    'return_date': returnDate,
    'user_name': userName,
    'age': age,
    'phone_number': phoneNumber,
    'email': email,
    'ex_time': exTime,
    'ex_change': exChange,
    'pickup_otp': pickupOtp,
    'pickup_status': pickupStatus,
    'drop_otp': dropOtp,
    'drop_status': dropStatus,
    'booking_pick_km': bookingPickKm,
    'booking_return_km': bookingReturnKm,
    'booking_cab_ac': bookingCabAc,
    'order_amount': orderAmount,
    'sub_amount': subAmount,
    'coupon_amount': couponAmount,
    'tax_amount': taxAmount,
    'tax': tax,
    'security_amount': securityAmount,
    'security_deposit': securityDeposit,
    'final_amount': finalAmount,
    'invoice_link': invoiceLink,
  };
}
