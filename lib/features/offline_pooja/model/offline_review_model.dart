// import 'dart:convert';
//
// OfflineujaReviewModel offlineujaReviewModelFromJson(String str) => OfflineujaReviewModel.fromJson(json.decode(str));
//
// String offlineujaReviewModelToJson(OfflineujaReviewModel data) => json.encode(data.toJson());
//
// class OfflineujaReviewModel {
//   bool? status;
//   List<Offlinereview>? review;
//
//   OfflineujaReviewModel({
//     this.status,
//     this.review,
//   });
//
//   factory OfflineujaReviewModel.fromJson(Map<String, dynamic> json) => OfflineujaReviewModel(
//     status: json["status"],
//     review: json["review"] == null ? [] : List<Offlinereview>.from(json["review"]!.map((x) => Offlinereview.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "review": review == null ? [] : List<dynamic>.from(review!.map((x) => x.toJson())),
//   };
// }
//
// class Offlinereview {
//   dynamic id;
//   dynamic orderId;
//   dynamic astroId;
//   dynamic userId;
//   dynamic serviceId;
//   dynamic comment;
//   dynamic serviceType;
//   dynamic rating;
//   dynamic isEdited;
//   dynamic status;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   UserData? userData;
//
//   Offlinereview({
//     this.id,
//     this.orderId,
//     this.astroId,
//     this.userId,
//     this.serviceId,
//     this.comment,
//     this.serviceType,
//     this.rating,
//     this.isEdited,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.userData,
//   });
//
//   factory Offlinereview.fromJson(Map<String, dynamic> json) => Offlinereview(
//     id: json["id"],
//     orderId: json["order_id"],
//     astroId: json["astro_id"],
//     userId: json["user_id"],
//     serviceId: json["service_id"],
//     comment: json["comment"],
//     serviceType: json["service_type"],
//     rating: json["rating"],
//     isEdited: json["is_edited"],
//     status: json["status"],
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
//     "is_edited": isEdited,
//     "status": status,
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
//   bool? isActive;
//   dynamic paymentCardLastFour;
//   dynamic paymentCardBrand;
//   dynamic paymentCardFawryToken;
//   dynamic loginMedium;
//   dynamic socialId;
//   bool? isPhoneVerified;
//   dynamic temporaryToken;
//   bool? isEmailVerified;
//   double? walletBalance;
//   dynamic loyaltyPoint;
//   int? loginHitCount;
//   bool? isTempBlocked;
//   dynamic tempBlockTime;
//   dynamic referralCode;
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

class OfflineujaReviewModel {
  OfflineujaReviewModel({
    required this.status,
    required this.review,
  });

  final bool status;
  final List<Offlinereview> review;

  factory OfflineujaReviewModel.fromJson(Map<String, dynamic> json) {
    return OfflineujaReviewModel(
      status: json["status"] ?? false,
      review: json["review"] == null
          ? []
          : List<Offlinereview>.from(
              json["review"]!.map((x) => Offlinereview.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "review": review.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $review, ";
  }
}

class Offlinereview {
  Offlinereview({
    required this.id,
    required this.orderId,
    required this.astroId,
    required this.userId,
    required this.serviceId,
    required this.comment,
    required this.serviceType,
    required this.rating,
    required this.isEdited,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userData,
  });

  final int id;
  final String orderId;
  final int astroId;
  final int userId;
  final int serviceId;
  final String comment;
  final String serviceType;
  final int rating;
  final int isEdited;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserData? userData;

  factory Offlinereview.fromJson(Map<String, dynamic> json) {
    return Offlinereview(
      id: json["id"] ?? 0,
      orderId: json["order_id"] ?? "",
      astroId: json["astro_id"] ?? 0,
      userId: json["user_id"] ?? 0,
      serviceId: json["service_id"] ?? 0,
      comment: json["comment"] ?? "",
      serviceType: json["service_type"] ?? "",
      rating: json["rating"] ?? 0,
      isEdited: json["is_edited"] ?? 0,
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      userData: json["user_data"] == null
          ? null
          : UserData.fromJson(json["user_data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "astro_id": astroId,
        "user_id": userId,
        "service_id": serviceId,
        "comment": comment,
        "service_type": serviceType,
        "rating": rating,
        "is_edited": isEdited,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user_data": userData?.toJson(),
      };

  @override
  String toString() {
    return "$id, $orderId, $astroId, $userId, $serviceId, $comment, $serviceType, $rating, $isEdited, $status, $createdAt, $updatedAt, $userData, ";
  }
}

class UserData {
  UserData({
    required this.id,
    required this.name,
    required this.fName,
    required this.lName,
    required this.phone,
    required this.image,
    required this.email,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.streetAddress,
    required this.country,
    required this.city,
    required this.zip,
    required this.houseNo,
    required this.apartmentNo,
    required this.cmFirebaseToken,
    required this.isActive,
    required this.paymentCardLastFour,
    required this.paymentCardBrand,
    required this.paymentCardFawryToken,
    required this.loginMedium,
    required this.socialId,
    required this.isPhoneVerified,
    required this.temporaryToken,
    required this.isEmailVerified,
    required this.walletBalance,
    required this.loyaltyPoint,
    required this.loginHitCount,
    required this.isTempBlocked,
    required this.tempBlockTime,
    required this.referralCode,
    required this.referredBy,
    required this.appLanguage,
    required this.checked,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String fName;
  final String lName;
  final String phone;
  final String image;
  final String email;
  final dynamic emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String streetAddress;
  final dynamic country;
  final String city;
  final String zip;
  final String houseNo;
  final dynamic apartmentNo;
  final String cmFirebaseToken;
  final bool isActive;
  final dynamic paymentCardLastFour;
  final dynamic paymentCardBrand;
  final dynamic paymentCardFawryToken;
  final dynamic loginMedium;
  final dynamic socialId;
  final bool isPhoneVerified;
  final String temporaryToken;
  final bool isEmailVerified;
  final int walletBalance;
  final dynamic loyaltyPoint;
  final int loginHitCount;
  final bool isTempBlocked;
  final dynamic tempBlockTime;
  final String referralCode;
  final dynamic referredBy;
  final String appLanguage;
  final int checked;
  final String imageUrl;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      fName: json["f_name"] ?? "",
      lName: json["l_name"] ?? "",
      phone: json["phone"] ?? "",
      image: json["image"] ?? "",
      email: json["email"] ?? "",
      emailVerifiedAt: json["email_verified_at"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      streetAddress: json["street_address"] ?? "",
      country: json["country"],
      city: json["city"] ?? "",
      zip: json["zip"] ?? "",
      houseNo: json["house_no"] ?? "",
      apartmentNo: json["apartment_no"],
      cmFirebaseToken: json["cm_firebase_token"] ?? "",
      isActive: json["is_active"] ?? false,
      paymentCardLastFour: json["payment_card_last_four"],
      paymentCardBrand: json["payment_card_brand"],
      paymentCardFawryToken: json["payment_card_fawry_token"],
      loginMedium: json["login_medium"],
      socialId: json["social_id"],
      isPhoneVerified: json["is_phone_verified"] ?? false,
      temporaryToken: json["temporary_token"] ?? "",
      isEmailVerified: json["is_email_verified"] ?? false,
      walletBalance: json["wallet_balance"] ?? 0,
      loyaltyPoint: json["loyalty_point"],
      loginHitCount: json["login_hit_count"] ?? 0,
      isTempBlocked: json["is_temp_blocked"] ?? false,
      tempBlockTime: json["temp_block_time"],
      referralCode: json["referral_code"] ?? "",
      referredBy: json["referred_by"],
      appLanguage: json["app_language"] ?? "",
      checked: json["checked"] ?? 0,
      imageUrl: json["image_url"] ?? "",
    );
  }

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
        "image_url": imageUrl,
      };

  @override
  String toString() {
    return "$id, $name, $fName, $lName, $phone, $image, $email, $emailVerifiedAt, $createdAt, $updatedAt, $streetAddress, $country, $city, $zip, $houseNo, $apartmentNo, $cmFirebaseToken, $isActive, $paymentCardLastFour, $paymentCardBrand, $paymentCardFawryToken, $loginMedium, $socialId, $isPhoneVerified, $temporaryToken, $isEmailVerified, $walletBalance, $loyaltyPoint, $loginHitCount, $isTempBlocked, $tempBlockTime, $referralCode, $referredBy, $appLanguage, $checked, $imageUrl, ";
  }
}
