// To parse this JSON data, do
//
//     final chadhavaModel = chadhavaModelFromJson(jsonString);

import 'dart:convert';

ChadhavaModel chadhavaModelFromJson(String str) =>
    ChadhavaModel.fromJson(json.decode(str));

String chadhavaModelToJson(ChadhavaModel data) => json.encode(data.toJson());

class ChadhavaModel {
  int status;
  List<Chadhavadetail> chadhavadetail;

  ChadhavaModel({
    required this.status,
    required this.chadhavadetail,
  });

  factory ChadhavaModel.fromJson(Map<String, dynamic> json) => ChadhavaModel(
        status: json["status"],
        chadhavadetail: List<Chadhavadetail>.from(
            json["chadhavadetail"].map((x) => Chadhavadetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "chadhavadetail":
            List<dynamic>.from(chadhavadetail.map((x) => x.toJson())),
      };
}

class Chadhavadetail {
  int? id;
  String? enName;
  String? hiName;
  String? enPoojaHeading;
  String? hiPoojaHeading;
  String? slug;
  String? image;
  int? status;
  int? userId;
  String? addedBy;
  String? enShortDetails;
  String? hiShortDetails;
  dynamic productType;
  String? enDetails;
  String? hiDetails;
  String? productId;
  String? enChadhavaVenue;
  String? hiChadhavaVenue;
  String? chadhavaWeek;
  int? isVideo;
  String? thumbnail;
  dynamic digitalFileReady;
  String? enMetaTitle;
  dynamic hiMetaTitle;
  String? metaDescription;
  String? metaImage;
  List<ChadhavaProduct> products;
  String? nextChadhavaDate;
  String? chadhavaTypeText;

  Chadhavadetail({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.enPoojaHeading,
    required this.hiPoojaHeading,
    required this.slug,
    required this.image,
    required this.status,
    required this.userId,
    required this.addedBy,
    required this.enShortDetails,
    required this.hiShortDetails,
    required this.productType,
    required this.enDetails,
    required this.hiDetails,
    required this.productId,
    required this.enChadhavaVenue,
    required this.hiChadhavaVenue,
    required this.chadhavaWeek,
    required this.isVideo,
    required this.thumbnail,
    required this.digitalFileReady,
    required this.enMetaTitle,
    required this.hiMetaTitle,
    required this.metaDescription,
    required this.metaImage,
    required this.products,
    required this.nextChadhavaDate,
    required this.chadhavaTypeText,
  });

  factory Chadhavadetail.fromJson(Map<String, dynamic> json) => Chadhavadetail(
        id: json["id"],
        enName: json["en_name"],
        hiName: json["hi_name"],
        enPoojaHeading: json["en_pooja_heading"],
        hiPoojaHeading: json["hi_pooja_heading"],
        slug: json["slug"],
        image: json["image"],
        status: json["status"],
        userId: json["user_id"],
        addedBy: json["added_by"],
        enShortDetails: json["en_short_details"],
        hiShortDetails: json["hi_short_details"],
        productType: json["product_type"],
        enDetails: json["en_details"],
        hiDetails: json["hi_details"],
        productId: json["product_id"],
        enChadhavaVenue: json["en_chadhava_venue"],
        hiChadhavaVenue: json["hi_chadhava_venue"],
        chadhavaWeek: json["chadhava_week"],
        isVideo: json["is_video"],
        thumbnail: json["thumbnail"],
        digitalFileReady: json["digital_file_ready"],
        enMetaTitle: json["en_meta_title"],
        hiMetaTitle: json["hi_meta_title"],
        metaDescription: json["meta_description"],
        metaImage: json["meta_image"],
        products: List<ChadhavaProduct>.from(
            json["products"].map((x) => ChadhavaProduct.fromJson(x))),
        nextChadhavaDate: json["next_chadhava_date"],
        chadhavaTypeText: json["chadhava_type_text"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "en_pooja_heading": enPoojaHeading,
        "hi_pooja_heading": hiPoojaHeading,
        "slug": slug,
        "image": image,
        "status": status,
        "user_id": userId,
        "added_by": addedBy,
        "en_short_details": enShortDetails,
        "hi_short_details": hiShortDetails,
        "product_type": productType,
        "en_details": enDetails,
        "hi_details": hiDetails,
        "product_id": productId,
        "en_chadhava_venue": enChadhavaVenue,
        "hi_chadhava_venue": hiChadhavaVenue,
        "chadhava_week": chadhavaWeek,
        "is_video": isVideo,
        "thumbnail": thumbnail,
        "digital_file_ready": digitalFileReady,
        "en_meta_title": enMetaTitle,
        "hi_meta_title": hiMetaTitle,
        "meta_description": metaDescription,
        "meta_image": metaImage,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "next_chadhava_date": nextChadhavaDate,
        "chadhava_type_text": chadhavaTypeText,
      };
}

class ChadhavaProduct {
  String? productId;
  String? enName;
  String? hiName;
  String? enDetails;
  String? hiDetails;
  int? price;
  String? thumbnail;
  String? images;

  ChadhavaProduct({
    required this.productId,
    required this.enName,
    required this.hiName,
    required this.enDetails,
    required this.hiDetails,
    required this.price,
    required this.thumbnail,
    required this.images,
  });

  factory ChadhavaProduct.fromJson(Map<String, dynamic> json) =>
      ChadhavaProduct(
        productId: json["product_id"],
        enName: json["en_name"],
        hiName: json["hi_name"],
        enDetails: json["en_details"],
        hiDetails: json["hi_details"],
        price: json["price"],
        thumbnail: json["thumbnail"],
        images: json["images"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "en_name": enName,
        "hi_name": hiName,
        "en_details": enDetails,
        "hi_details": hiDetails,
        "price": price,
        "thumbnail": thumbnail,
        "images": images,
      };
}
