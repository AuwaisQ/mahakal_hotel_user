// // To parse this JSON data, do
// //
// //     final poojaReviewModel = poojaReviewModelFromJson(jsonString);
//
// import 'dart:convert';
//
// PoojaReviewModel poojaReviewModelFromJson(String str) => PoojaReviewModel.fromJson(json.decode(str));
//
// String poojaReviewModelToJson(PoojaReviewModel data) => json.encode(data.toJson());
//
// class PoojaReviewModel {
//   bool? success;
//   ReviewSummary? reviewSummary;
//   int? totalReviews;
//
//   PoojaReviewModel({
//     this.success,
//     this.reviewSummary,
//     this.totalReviews,
//   });
//
//   factory PoojaReviewModel.fromJson(Map<String, dynamic> json) => PoojaReviewModel(
//     success: json["success"],
//     reviewSummary: json["review_summary"] == null ? null : ReviewSummary.fromJson(json["review_summary"]),
//     totalReviews: json["total_reviews"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "review_summary": reviewSummary?.toJson(),
//     "total_reviews": totalReviews,
//   };
// }
//
// class ReviewSummary {
//   int? excellent;
//   int? good;
//   int? average;
//   int? belowAverage;
//   int? poor;
//   int? averageStar;
//   List<Poojareviewlist>? list;
//
//   ReviewSummary({
//     this.excellent,
//     this.good,
//     this.average,
//     this.belowAverage,
//     this.poor,
//     this.averageStar,
//     this.list,
//   });
//
//   factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
//     excellent: json["excellent"],
//     good: json["good"],
//     average: json["average"],
//     belowAverage: json["below_average"],
//     poor: json["poor"],
//     averageStar: json["averageStar"],
//     list: json["list"] == null ? [] : List<Poojareviewlist>.from(json["list"]!.map((x) => Poojareviewlist.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "excellent": excellent,
//     "good": good,
//     "average": average,
//     "below_average": belowAverage,
//     "poor": poor,
//     "averageStar": averageStar,
//     "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
//   };
// }
//
// class Poojareviewlist {
//   dynamic id;
//   dynamic orderId;
//   dynamic astroId;
//   dynamic userId;
//   dynamic serviceId;
//   dynamic comment;
//   dynamic serviceType;
//   dynamic rating;
//   dynamic status;
//   dynamic isEdited;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   UserData? userData;
//
//   Poojareviewlist({
//     this.id,
//     this.orderId,
//     this.astroId,
//     this.userId,
//     this.serviceId,
//     this.comment,
//     this.serviceType,
//     this.rating,
//     this.status,
//     this.isEdited,
//     this.createdAt,
//     this.updatedAt,
//     this.userData,
//   });
//
//   factory Poojareviewlist.fromJson(Map<String, dynamic> json) => Poojareviewlist(
//     id: json["id"],
//     orderId: json["order_id"],
//     astroId: json["astro_id"],
//     userId: json["user_id"],
//     serviceId: json["service_id"],
//     comment: json["comment"],
//     serviceType: json["service_type"],
//     rating: json["rating"],
//     status: json["status"],
//     isEdited: json["is_edited"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     userData: json["user_data"] == null ? null : UserData.fromJson(json["user_data"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "order_id": orderId,
//     "astro_id": astroId,
//     "user_id": userId,
//     "service_id": serviceId,
//     "comment": comment,
//     "service_type": serviceType,
//     "rating": rating,
//     "status": status,
//     "is_edited": isEdited,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "user_data": userData?.toJson(),
//   };
// }
//
// class UserData {
//   int? id;
//   String? name;
//   String? fName;
//   String? lName;
//   String? phone;
//   String? image;
//   String? email;
//   dynamic emailVerifiedAt;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic streetAddress;
//   dynamic country;
//   dynamic city;
//   dynamic zip;
//   dynamic houseNo;
//   dynamic apartmentNo;
//   String? cmFirebaseToken;
//   int? isActive;
//   dynamic paymentCardLastFour;
//   dynamic paymentCardBrand;
//   dynamic paymentCardFawryToken;
//   dynamic loginMedium;
//   dynamic socialId;
//   int? isPhoneVerified;
//   String? temporaryToken;
//   int? isEmailVerified;
//   double? walletBalance;
//   dynamic loyaltyPoint;
//   int? loginHitCount;
//   int? isTempBlocked;
//   dynamic tempBlockTime;
//   String? referralCode;
//   dynamic referredBy;
//   String? appLanguage;
//   int? checked;
//
//   UserData({
//     this.id,
//     this.name,
//     this.fName,
//     this.lName,
//     this.phone,
//     this.image,
//     this.email,
//     this.emailVerifiedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.streetAddress,
//     this.country,
//     this.city,
//     this.zip,
//     this.houseNo,
//     this.apartmentNo,
//     this.cmFirebaseToken,
//     this.isActive,
//     this.paymentCardLastFour,
//     this.paymentCardBrand,
//     this.paymentCardFawryToken,
//     this.loginMedium,
//     this.socialId,
//     this.isPhoneVerified,
//     this.temporaryToken,
//     this.isEmailVerified,
//     this.walletBalance,
//     this.loyaltyPoint,
//     this.loginHitCount,
//     this.isTempBlocked,
//     this.tempBlockTime,
//     this.referralCode,
//     this.referredBy,
//     this.appLanguage,
//     this.checked,
//   });
//
//   factory UserData.fromJson(Map<String, dynamic> json) => UserData(
//     id: json["id"],
//     name: json["name"],
//     fName: json["f_name"],
//     lName: json["l_name"],
//     phone: json["phone"],
//     image: json["image"],
//     email: json["email"],
//     emailVerifiedAt: json["email_verified_at"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     streetAddress: json["street_address"],
//     country: json["country"],
//     city: json["city"],
//     zip: json["zip"],
//     houseNo: json["house_no"],
//     apartmentNo: json["apartment_no"],
//     cmFirebaseToken: json["cm_firebase_token"],
//     isActive: json["is_active"],
//     paymentCardLastFour: json["payment_card_last_four"],
//     paymentCardBrand: json["payment_card_brand"],
//     paymentCardFawryToken: json["payment_card_fawry_token"],
//     loginMedium: json["login_medium"],
//     socialId: json["social_id"],
//     isPhoneVerified: json["is_phone_verified"],
//     temporaryToken: json["temporary_token"],
//     isEmailVerified: json["is_email_verified"],
//     walletBalance: json["wallet_balance"]?.toDouble(),
//     loyaltyPoint: json["loyalty_point"],
//     loginHitCount: json["login_hit_count"],
//     isTempBlocked: json["is_temp_blocked"],
//     tempBlockTime: json["temp_block_time"],
//     referralCode: json["referral_code"],
//     referredBy: json["referred_by"],
//     appLanguage: json["app_language"],
//     checked: json["checked"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "f_name": fName,
//     "l_name": lName,
//     "phone": phone,
//     "image": image,
//     "email": email,
//     "email_verified_at": emailVerifiedAt,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//     "street_address": streetAddress,
//     "country": country,
//     "city": city,
//     "zip": zip,
//     "house_no": houseNo,
//     "apartment_no": apartmentNo,
//     "cm_firebase_token": cmFirebaseToken,
//     "is_active": isActive,
//     "payment_card_last_four": paymentCardLastFour,
//     "payment_card_brand": paymentCardBrand,
//     "payment_card_fawry_token": paymentCardFawryToken,
//     "login_medium": loginMedium,
//     "social_id": socialId,
//     "is_phone_verified": isPhoneVerified,
//     "temporary_token": temporaryToken,
//     "is_email_verified": isEmailVerified,
//     "wallet_balance": walletBalance,
//     "loyalty_point": loyaltyPoint,
//     "login_hit_count": loginHitCount,
//     "is_temp_blocked": isTempBlocked,
//     "temp_block_time": tempBlockTime,
//     "referral_code": referralCode,
//     "referred_by": referredBy,
//     "app_language": appLanguage,
//     "checked": checked,
//   };
// }

import 'dart:convert';

PoojaReviewModel poojaReviewModelFromJson(String str) =>
    PoojaReviewModel.fromJson(json.decode(str));

String poojaReviewModelToJson(PoojaReviewModel data) =>
    json.encode(data.toJson());

class PoojaReviewModel {
  PoojaReviewModel({
    required this.success,
    required this.reviewSummary,
    required this.totalReviews,
  });

  final bool success;
  final ReviewSummary? reviewSummary;
  final int totalReviews;

  factory PoojaReviewModel.fromJson(Map<String, dynamic> json) {
    return PoojaReviewModel(
      success: json["success"] ?? false,
      reviewSummary: json["review_summary"] == null
          ? null
          : ReviewSummary.fromJson(json["review_summary"]),
      totalReviews: json["total_reviews"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "review_summary": reviewSummary?.toJson(),
        "total_reviews": totalReviews,
      };

  @override
  String toString() {
    return "$success, $reviewSummary, $totalReviews, ";
  }
}

class ReviewSummary {
  ReviewSummary({
    required this.excellent,
    required this.good,
    required this.average,
    required this.belowAverage,
    required this.poor,
    required this.averageStar,
    required this.list,
  });

  final int excellent;
  final int good;
  final int average;
  final int belowAverage;
  final int poor;
  final dynamic averageStar;
  final List<dynamic> list;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      excellent: json["excellent"] ?? 0,
      good: json["good"] ?? 0,
      average: json["average"] ?? 0,
      belowAverage: json["below_average"] ?? 0,
      poor: json["poor"] ?? 0,
      averageStar: json["averageStar"],
      list: json["list"] == null
          ? []
          : List<dynamic>.from(json["list"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "excellent": excellent,
        "good": good,
        "average": average,
        "below_average": belowAverage,
        "poor": poor,
        "averageStar": averageStar,
        "list": list.map((x) => x).toList(),
      };

  @override
  String toString() {
    return "$excellent, $good, $average, $belowAverage, $poor, $averageStar, $list, ";
  }
}

class Poojareviewlist {
  dynamic id;
  dynamic orderId;
  dynamic astroId;
  dynamic userId;
  dynamic serviceId;
  dynamic comment;
  dynamic serviceType;
  dynamic rating;
  dynamic status;
  dynamic isEdited;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserData? userData;

  Poojareviewlist({
    this.id,
    this.orderId,
    this.astroId,
    this.userId,
    this.serviceId,
    this.comment,
    this.serviceType,
    this.rating,
    this.status,
    this.isEdited,
    this.createdAt,
    this.updatedAt,
    this.userData,
  });

  factory Poojareviewlist.fromJson(Map<String, dynamic> json) =>
      Poojareviewlist(
        id: json["id"],
        orderId: json["order_id"],
        astroId: json["astro_id"],
        userId: json["user_id"],
        serviceId: json["service_id"],
        comment: json["comment"],
        serviceType: json["service_type"],
        rating: json["rating"],
        status: json["status"],
        isEdited: json["is_edited"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        userData: json["user_data"] == null
            ? null
            : UserData.fromJson(json["user_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "astro_id": astroId,
        "user_id": userId,
        "service_id": serviceId,
        "comment": comment,
        "service_type": serviceType,
        "rating": rating,
        "status": status,
        "is_edited": isEdited,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user_data": userData?.toJson(),
      };
}

class UserData {
  int? id;
  String? name;
  String? fName;
  String? lName;
  String? phone;
  String? image;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic streetAddress;
  dynamic country;
  dynamic city;
  dynamic zip;
  dynamic houseNo;
  dynamic apartmentNo;
  String? cmFirebaseToken;
  int? isActive;
  dynamic paymentCardLastFour;
  dynamic paymentCardBrand;
  dynamic paymentCardFawryToken;
  dynamic loginMedium;
  dynamic socialId;
  int? isPhoneVerified;
  String? temporaryToken;
  int? isEmailVerified;
  double? walletBalance;
  dynamic loyaltyPoint;
  int? loginHitCount;
  int? isTempBlocked;
  dynamic tempBlockTime;
  String? referralCode;
  dynamic referredBy;
  String? appLanguage;
  int? checked;

  UserData({
    this.id,
    this.name,
    this.fName,
    this.lName,
    this.phone,
    this.image,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.streetAddress,
    this.country,
    this.city,
    this.zip,
    this.houseNo,
    this.apartmentNo,
    this.cmFirebaseToken,
    this.isActive,
    this.paymentCardLastFour,
    this.paymentCardBrand,
    this.paymentCardFawryToken,
    this.loginMedium,
    this.socialId,
    this.isPhoneVerified,
    this.temporaryToken,
    this.isEmailVerified,
    this.walletBalance,
    this.loyaltyPoint,
    this.loginHitCount,
    this.isTempBlocked,
    this.tempBlockTime,
    this.referralCode,
    this.referredBy,
    this.appLanguage,
    this.checked,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["name"],
        fName: json["f_name"],
        lName: json["l_name"],
        phone: json["phone"],
        image: json["image"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        streetAddress: json["street_address"],
        country: json["country"],
        city: json["city"],
        zip: json["zip"],
        houseNo: json["house_no"],
        apartmentNo: json["apartment_no"],
        cmFirebaseToken: json["cm_firebase_token"],
        isActive: json["is_active"],
        paymentCardLastFour: json["payment_card_last_four"],
        paymentCardBrand: json["payment_card_brand"],
        paymentCardFawryToken: json["payment_card_fawry_token"],
        loginMedium: json["login_medium"],
        socialId: json["social_id"],
        isPhoneVerified: json["is_phone_verified"],
        temporaryToken: json["temporary_token"],
        isEmailVerified: json["is_email_verified"],
        walletBalance: json["wallet_balance"]?.toDouble(),
        loyaltyPoint: json["loyalty_point"],
        loginHitCount: json["login_hit_count"],
        isTempBlocked: json["is_temp_blocked"],
        tempBlockTime: json["temp_block_time"],
        referralCode: json["referral_code"],
        referredBy: json["referred_by"],
        appLanguage: json["app_language"],
        checked: json["checked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "f_name": fName,
        "l_name": lName,
        "phone": phone,
        "image": image,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "street_address": streetAddress,
        "country": country,
        "city": city,
        "zip": zip,
        "house_no": houseNo,
        "apartment_no": apartmentNo,
        "cm_firebase_token": cmFirebaseToken,
        "is_active": isActive,
        "payment_card_last_four": paymentCardLastFour,
        "payment_card_brand": paymentCardBrand,
        "payment_card_fawry_token": paymentCardFawryToken,
        "login_medium": loginMedium,
        "social_id": socialId,
        "is_phone_verified": isPhoneVerified,
        "temporary_token": temporaryToken,
        "is_email_verified": isEmailVerified,
        "wallet_balance": walletBalance,
        "loyalty_point": loyaltyPoint,
        "login_hit_count": loginHitCount,
        "is_temp_blocked": isTempBlocked,
        "temp_block_time": tempBlockTime,
        "referral_code": referralCode,
        "referred_by": referredBy,
        "app_language": appLanguage,
        "checked": checked,
      };
}
