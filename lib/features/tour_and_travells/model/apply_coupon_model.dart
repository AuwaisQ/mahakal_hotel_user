// To parse this JSON data, do
//
//     final tourApplyCouponModel = tourApplyCouponModelFromJson(jsonString);

import 'dart:convert';

TourApplyCouponModel tourApplyCouponModelFromJson(String str) =>
    TourApplyCouponModel.fromJson(json.decode(str));

String tourApplyCouponModelToJson(TourApplyCouponModel data) =>
    json.encode(data.toJson());

class TourApplyCouponModel {
  int? status;
  String? message;
  int? recode;
  ApplyCouponData? data;

  TourApplyCouponModel({
    this.status,
    this.message,
    this.recode,
    this.data,
  });

  factory TourApplyCouponModel.fromJson(Map<String, dynamic> json) =>
      TourApplyCouponModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        data: json["data"] == null
            ? null
            : ApplyCouponData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data?.toJson(),
      };
}

class ApplyCouponData {
  int? couponId;
  double? couponAmount;
  double? finalAmount;

  ApplyCouponData({
    this.couponId,
    this.couponAmount,
    this.finalAmount,
  });

  factory ApplyCouponData.fromJson(Map<String, dynamic> json) =>
      ApplyCouponData(
        couponId: json["coupon_id"],
        couponAmount: json["coupon_amount"],
        finalAmount: json["final_amount"],
      );

  Map<String, dynamic> toJson() => {
        "coupon_id": couponId,
        "coupon_amount": couponAmount,
        "final_amount": finalAmount,
      };
}
