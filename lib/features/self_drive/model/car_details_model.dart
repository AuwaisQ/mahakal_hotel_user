// To parse this JSON data, do
//
//     final carDetailsModel = carDetailsModelFromJson(jsonString);

import 'dart:convert';

CarDetailsModel carDetailsModelFromJson(String str) => CarDetailsModel.fromJson(json.decode(str));

String carDetailsModelToJson(CarDetailsModel data) => json.encode(data.toJson());

class CarDetailsModel {
  int? status;
  String? message;
  CarDetail? carDetail;

  CarDetailsModel({
    this.status,
    this.message,
    this.carDetail,
  });

  factory CarDetailsModel.fromJson(Map<String, dynamic> json) => CarDetailsModel(
    status: json['status'],
    message: json['message'],
    carDetail: json['data'] == null ? null : CarDetail.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'carDetail': carDetail?.toJson(),
  };
}

class CarDetail {
  int? id;
  String? slug;
  String? carType;
  String? fuelType;
  dynamic securityAmount;
  int? hourStatus;
  int? hourBasicPriceWithAc;
  int? hourBasicPriceNonAc;
  int? hourMinimum;
  int? hourExtraChargesKm;
  int? hourExtraChargesHour;
  int? kmStatus;
  int? kmBasicPriceWithAc;
  int? kmBasicPriceNonAc;
  int? kmMinimum;
  int? kmExtraChargesKm;
  int? kmExtraChargesHour;
  int? driverLocalPrice;
  int? driverOutsidePrice;
  int? driverNightExtraPrice;
  int? driverNightIncludePrice;
  String? inclusion;
  String? exclusion;
  String? thumbnail;
  List<String>? images;
  dynamic enDriversAgeDetails;
  String? hiDriversAgeDetails;
  dynamic enTipForDriving;
  String? hiTipForDriving;
  String? enNotLocalResident;
  String? hiNotLocalResident;
  String? enLocalResident;
  String? hiLocalResident;
  String? enCabName;
  String? hiCabName;
  int? cabSeats;
  String? enCategoryName;
  String? hiCategoryName;
  String? categoryType;
  String? hiCategoryType;
  String? travellerName;
  String? travellerCompanyName;
  String? travellerImage;
  String? travellerBanner;
  List<CabAbout>? cabAbout;
  List<DrivingPolicy>? drivingPolicy;
  List<CancelPolicy>? cancelPolicy;

  CarDetail({
    this.id,
    this.slug,
    this.carType,
    this.fuelType,
    this.securityAmount,
    this.hourStatus,
    this.hourBasicPriceWithAc,
    this.hourBasicPriceNonAc,
    this.hourMinimum,
    this.hourExtraChargesKm,
    this.hourExtraChargesHour,
    this.kmStatus,
    this.kmBasicPriceWithAc,
    this.kmBasicPriceNonAc,
    this.kmMinimum,
    this.kmExtraChargesKm,
    this.kmExtraChargesHour,
    this.driverLocalPrice,
    this.driverOutsidePrice,
    this.driverNightExtraPrice,
    this.driverNightIncludePrice,
    this.inclusion,
    this.exclusion,
    this.thumbnail,
    this.images,
    this.enDriversAgeDetails,
    this.hiDriversAgeDetails,
    this.enTipForDriving,
    this.hiTipForDriving,
    this.enNotLocalResident,
    this.hiNotLocalResident,
    this.enLocalResident,
    this.hiLocalResident,
    this.enCabName,
    this.hiCabName,
    this.cabSeats,
    this.enCategoryName,
    this.hiCategoryName,
    this.categoryType,
    this.hiCategoryType,
    this.travellerName,
    this.travellerCompanyName,
    this.travellerImage,
    this.travellerBanner,
    this.cabAbout,
    this.drivingPolicy,
    this.cancelPolicy,
  });

  factory CarDetail.fromJson(Map<String, dynamic> json) => CarDetail(
    id: json['id'],
    slug: json['slug'],
    carType: json['car_type'],
    fuelType: json['fuel_type'],
    securityAmount: json['security_amount'],
    hourStatus: json['hour_status'],
    hourBasicPriceWithAc: json['hour_basic_price_with_ac'],
    hourBasicPriceNonAc: json['hour_basic_price_non_ac'],
    hourMinimum: json['hour_minimum'],
    hourExtraChargesKm: json['hour_extra_charges_km'],
    hourExtraChargesHour: json['hour_extra_charges_hour'],
    kmStatus: json['km_status'],
    kmBasicPriceWithAc: json['km_basic_price_with_ac'],
    kmBasicPriceNonAc: json['km_basic_price_non_ac'],
    kmMinimum: json['km_minimum'],
    kmExtraChargesKm: json['km_extra_charges_km'],
    kmExtraChargesHour: json['km_extra_charges_hour'],
    driverLocalPrice: json['driver_local_price'],
    driverOutsidePrice: json['driver_outside_price'],
    driverNightExtraPrice: json['driver_night_extra_price'],
    driverNightIncludePrice: json['driver_night_include_price'],
    inclusion: json['inclusion'],
    exclusion: json['exclusion'],
    thumbnail: json['thumbnail'],
    images: json['images'] == null ? [] : List<String>.from(json['images']!.map((x) => x)),
    enDriversAgeDetails: json['en_drivers_age_details'],
    hiDriversAgeDetails: json['hi_drivers_age_details'],
    enTipForDriving: json['en_tip_for_driving'],
    hiTipForDriving: json['hi_tip_for_driving'],
    enNotLocalResident: json['en_not_local_resident'],
    hiNotLocalResident: json['hi_not_local_resident'],
    enLocalResident: json['en_local_resident'],
    hiLocalResident: json['hi_local_resident'],
    enCabName: json['en_cab_name'],
    hiCabName: json['hi_cab_name'],
    cabSeats: json['cab_seats'],
    enCategoryName: json['en_category_name'],
    hiCategoryName: json['hi_category_name'],
    categoryType: json['category_type'],
    hiCategoryType: json['hi_category_type'],
    travellerName: json['traveller_name'],
    travellerCompanyName: json['traveller_company_name'],
    travellerImage: json['traveller_image'],
    travellerBanner: json['traveller_banner'],
    cabAbout: json['cab_about'] == null ? [] : List<CabAbout>.from(json['cab_about']!.map((x) => CabAbout.fromJson(x))),
    drivingPolicy: json['driving_policy'] == null ? [] : List<DrivingPolicy>.from(json['driving_policy']!.map((x) => DrivingPolicy.fromJson(x))),
    cancelPolicy: json['cancel_policy'] == null ? [] : List<CancelPolicy>.from(json['cancel_policy']!.map((x) => CancelPolicy.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'car_type': carType,
    'fuel_type': fuelType,
    'security_amount': securityAmount,
    'hour_status': hourStatus,
    'hour_basic_price_with_ac': hourBasicPriceWithAc,
    'hour_basic_price_non_ac': hourBasicPriceNonAc,
    'hour_minimum': hourMinimum,
    'hour_extra_charges_km': hourExtraChargesKm,
    'hour_extra_charges_hour': hourExtraChargesHour,
    'km_status': kmStatus,
    'km_basic_price_with_ac': kmBasicPriceWithAc,
    'km_basic_price_non_ac': kmBasicPriceNonAc,
    'km_minimum': kmMinimum,
    'km_extra_charges_km': kmExtraChargesKm,
    'km_extra_charges_hour': kmExtraChargesHour,
    'driver_local_price': driverLocalPrice,
    'driver_outside_price': driverOutsidePrice,
    'driver_night_extra_price': driverNightExtraPrice,
    'driver_night_include_price': driverNightIncludePrice,
    'inclusion': inclusion,
    'exclusion': exclusion,
    'thumbnail': thumbnail,
    'images': images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    'en_drivers_age_details': enDriversAgeDetails,
    'hi_drivers_age_details': hiDriversAgeDetails,
    'en_tip_for_driving': enTipForDriving,
    'hi_tip_for_driving': hiTipForDriving,
    'en_not_local_resident': enNotLocalResident,
    'hi_not_local_resident': hiNotLocalResident,
    'en_local_resident': enLocalResident,
    'hi_local_resident': hiLocalResident,
    'en_cab_name': enCabName,
    'hi_cab_name': hiCabName,
    'cab_seats': cabSeats,
    'en_category_name': enCategoryName,
    'hi_category_name': hiCategoryName,
    'category_type': categoryType,
    'hi_category_type': hiCategoryType,
    'traveller_name': travellerName,
    'traveller_company_name': travellerCompanyName,
    'traveller_image': travellerImage,
    'traveller_banner': travellerBanner,
    'cab_about': cabAbout == null ? [] : List<dynamic>.from(cabAbout!.map((x) => x.toJson())),
    'driving_policy': drivingPolicy == null ? [] : List<dynamic>.from(drivingPolicy!.map((x) => x.toJson())),
    'cancel_policy': cancelPolicy == null ? [] : List<dynamic>.from(cancelPolicy!.map((x) => x.toJson())),
  };
}

class CabAbout {
  int? id;
  String? enName;
  String? enDetails;
  String? hiName;
  String? hiDetails;

  CabAbout({
    this.id,
    this.enName,
    this.enDetails,
    this.hiName,
    this.hiDetails,
  });

  factory CabAbout.fromJson(Map<String, dynamic> json) => CabAbout(
    id: json['id'],
    enName: json['en_name'],
    enDetails: json['en_details'],
    hiName: json['hi_name'],
    hiDetails: json['hi_details'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'en_name': enName,
    'en_details': enDetails,
    'hi_name': hiName,
    'hi_details': hiDetails,
  };
}

class CancelPolicy {
  String? enTitle;
  String? enMessage;

  CancelPolicy({
    this.enTitle,
    this.enMessage,
  });

  factory CancelPolicy.fromJson(Map<String, dynamic> json) => CancelPolicy(
    enTitle: json['en_title'],
    enMessage: json['en_message'],
  );

  Map<String, dynamic> toJson() => {
    'en_title': enTitle,
    'en_message': enMessage,
  };
}

class DrivingPolicy {
  String? enTitle;
  String? enMessage;
  String? enPolicyName;

  DrivingPolicy({
    this.enTitle,
    this.enMessage,
    this.enPolicyName,
  });

  factory DrivingPolicy.fromJson(Map<String, dynamic> json) => DrivingPolicy(
    enTitle: json['en_title'],
    enMessage: json['en_message'],
    enPolicyName: json['en_policy_name'],
  );

  Map<String, dynamic> toJson() => {
    'en_title': enTitle,
    'en_message': enMessage,
    'en_policy_name': enPolicyName,
  };
}
