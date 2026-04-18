// To parse this JSON data, do
//
//     final productsModel = productsModelFromJson(jsonString);

import 'dart:convert';

List<ProductsModel> productsModelFromJson(String str) =>
    List<ProductsModel>.from(
        json.decode(str).map((x) => ProductsModel.fromJson(x)));

String productsModelToJson(List<ProductsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductsModel {
  ProductsModel({
    required this.productId,
    required this.enName,
    required this.hiName,
    required this.enDetails,
    required this.hiDetails,
    required this.price,
    required this.thumbnail,
    required this.images,
  });

  final String productId;
  final String enName;
  final String hiName;
  final String enDetails;
  final String hiDetails;
  final int price;
  final String thumbnail;
  final String images;

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
      productId: json["product_id"] ?? "",
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enDetails: json["en_details"] ?? "",
      hiDetails: json["hi_details"] ?? "",
      price: json["price"] ?? 0,
      thumbnail: json["thumbnail"] ?? "",
      images: json["images"] ?? "",
    );
  }

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

  @override
  String toString() {
    return "$productId, $enName, $hiName, $enDetails, $hiDetails, $price, $thumbnail, $images, ";
  }
}
