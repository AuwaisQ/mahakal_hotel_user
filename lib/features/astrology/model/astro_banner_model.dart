// To parse this JSON data, do
//
//     final astroBannerModel = astroBannerModelFromJson(jsonString);

import 'dart:convert';

List<AstroBannerModel> astroBannerModelFromJson(String str) =>
    List<AstroBannerModel>.from(
        json.decode(str).map((x) => AstroBannerModel.fromJson(x)));

String astroBannerModelToJson(List<AstroBannerModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AstroBannerModel {
  int id;
  String photo;
  String bannerType;
  String themetype;
  int published;
  DateTime createdAt;
  DateTime updatedAt;
  String? url;
  String resourceType;
  int? resourceId;
  dynamic imageType;
  dynamic appSectionResourceType;
  dynamic appSectionResourceId;
  dynamic title;
  dynamic subTitle;
  dynamic buttonText;
  dynamic backgroundColor;
  DateTime? startDate;
  DateTime? endDate;
  Product? product;

  AstroBannerModel({
    required this.id,
    required this.photo,
    required this.bannerType,
    required this.themetype,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    required this.resourceType,
    required this.resourceId,
    required this.imageType,
    required this.appSectionResourceType,
    required this.appSectionResourceId,
    required this.title,
    required this.subTitle,
    required this.buttonText,
    required this.backgroundColor,
    required this.startDate,
    required this.endDate,
    this.product,
  });

  factory AstroBannerModel.fromJson(Map<String, dynamic> json) =>
      AstroBannerModel(
        id: json['id'],
        photo: json['photo'],
        bannerType: json['banner_type'],
        themetype: json['theme'],
        published: json['published'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        url: json['url'],
        resourceType: json['resource_type'],
        resourceId: json['resource_id'],
        imageType: json['image_type'],
        appSectionResourceType: json['app_section_resource_type'],
        appSectionResourceId: json['app_section_resource_id'],
        title: json['title'],
        subTitle: json['sub_title'],
        buttonText: json['button_text'],
        backgroundColor: json['background_color'],
        startDate: json['start_date'] == null
            ? null
            : DateTime.parse(json['start_date']),
        endDate:
            json['end_date'] == null ? null : DateTime.parse(json['end_date']),
        product:
            json['product'] == null ? null : Product.fromJson(json['product']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'photo': photo,
        'banner_type': bannerType,
        'theme': themetype,
        'published': published,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'url': url,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'image_type': imageType,
        'app_section_resource_type': appSectionResourceType,
        'app_section_resource_id': appSectionResourceId,
        'title': title,
        'sub_title': subTitle,
        'button_text': buttonText,
        'background_color': backgroundColor,
        'start_date':
            "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        'end_date':
            "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        'product': product?.toJson(),
      };
}

class Product {
  int id;
  String addedBy;
  int userId;
  String name;
  String slug;
  String productType;
  List<CategoryId> categoryIds;
  int categoryId;
  int? subCategoryId;
  dynamic subSubCategoryId;
  int brandId;
  String unit;
  int minQty;
  int refundable;
  dynamic digitalProductType;
  String? digitalFileReady;
  List<String> images;
  List<dynamic> colorImage;
  String thumbnail;
  int? featured;
  dynamic flashDeal;
  String videoProvider;
  dynamic videoUrl;
  List<dynamic> colors;
  int variantProduct;
  List<dynamic> attributes;
  List<dynamic> choiceOptions;
  List<dynamic> variation;
  int published;
  int unitPrice;
  int purchasePrice;
  int tax;
  String? taxType;
  String taxModel;
  int discount;
  String discountType;
  int currentStock;
  int minimumOrderQty;
  String details;
  int freeShipping;
  String? attachment;
  String? createdAt;
  DateTime updatedAt;
  int status;
  int featuredStatus;
  String? metaTitle;
  String? metaDescription;
  String? metaImage;
  int requestStatus;
  String? deniedNote;
  int shippingCost;
  int multiplyQty;
  int? tempShippingCost;
  int? isShippingCostUpdated;
  String code;
  List<dynamic> colorsFormatted;
  List<dynamic> translations;
  List<Review> reviews;

  Product({
    required this.id,
    required this.addedBy,
    required this.userId,
    required this.name,
    required this.slug,
    required this.productType,
    required this.categoryIds,
    required this.categoryId,
    required this.subCategoryId,
    required this.subSubCategoryId,
    required this.brandId,
    required this.unit,
    required this.minQty,
    required this.refundable,
    required this.digitalProductType,
    required this.digitalFileReady,
    required this.images,
    required this.colorImage,
    required this.thumbnail,
    required this.featured,
    required this.flashDeal,
    required this.videoProvider,
    required this.videoUrl,
    required this.colors,
    required this.variantProduct,
    required this.attributes,
    required this.choiceOptions,
    required this.variation,
    required this.published,
    required this.unitPrice,
    required this.purchasePrice,
    required this.tax,
    required this.taxType,
    required this.taxModel,
    required this.discount,
    required this.discountType,
    required this.currentStock,
    required this.minimumOrderQty,
    required this.details,
    required this.freeShipping,
    required this.attachment,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.featuredStatus,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaImage,
    required this.requestStatus,
    required this.deniedNote,
    required this.shippingCost,
    required this.multiplyQty,
    required this.tempShippingCost,
    required this.isShippingCostUpdated,
    required this.code,
    required this.colorsFormatted,
    required this.translations,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        addedBy: json['added_by'],
        userId: json['user_id'],
        name: json['name'],
        slug: json['slug'],
        productType: json['product_type'],
        categoryIds: List<CategoryId>.from(
            json['category_ids'].map((x) => CategoryId.fromJson(x))),
        categoryId: json['category_id'],
        subCategoryId: json['sub_category_id'],
        subSubCategoryId: json['sub_sub_category_id'],
        brandId: json['brand_id'],
        unit: json['unit'],
        minQty: json['min_qty'],
        refundable: json['refundable'],
        digitalProductType: json['digital_product_type'],
        digitalFileReady: json['digital_file_ready'],
        images: List<String>.from(json['images'].map((x) => x)),
        colorImage: List<dynamic>.from(json['color_image'].map((x) => x)),
        thumbnail: json['thumbnail'],
        featured: json['featured'],
        flashDeal: json['flash_deal'],
        videoProvider: json['video_provider'],
        videoUrl: json['video_url'],
        colors: List<dynamic>.from(json['colors'].map((x) => x)),
        variantProduct: json['variant_product'],
        attributes: List<dynamic>.from(json['attributes'].map((x) => x)),
        choiceOptions: List<dynamic>.from(json['choice_options'].map((x) => x)),
        variation: List<dynamic>.from(json['variation'].map((x) => x)),
        published: json['published'],
        unitPrice: json['unit_price'],
        purchasePrice: json['purchase_price'],
        tax: json['tax'],
        taxType: json['tax_type'],
        taxModel: json['tax_model'],
        discount: json['discount'],
        discountType: json['discount_type'],
        currentStock: json['current_stock'],
        minimumOrderQty: json['minimum_order_qty'],
        details: json['details'],
        freeShipping: json['free_shipping'],
        attachment: json['attachment'],
        createdAt: json['created_at'],
        updatedAt: DateTime.parse(json['updated_at']),
        status: json['status'],
        featuredStatus: json['featured_status'],
        metaTitle: json['meta_title'],
        metaDescription: json['meta_description'],
        metaImage: json['meta_image'],
        requestStatus: json['request_status'],
        deniedNote: json['denied_note'],
        shippingCost: json['shipping_cost'],
        multiplyQty: json['multiply_qty'],
        tempShippingCost: json['temp_shipping_cost'],
        isShippingCostUpdated: json['is_shipping_cost_updated'],
        code: json['code'],
        colorsFormatted:
            List<dynamic>.from(json['colors_formatted'].map((x) => x)),
        translations: List<dynamic>.from(json['translations'].map((x) => x)),
        reviews:
            List<Review>.from(json['reviews'].map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'added_by': addedBy,
        'user_id': userId,
        'name': name,
        'slug': slug,
        'product_type': productType,
        'category_ids': List<dynamic>.from(categoryIds.map((x) => x.toJson())),
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'sub_sub_category_id': subSubCategoryId,
        'brand_id': brandId,
        'unit': unit,
        'min_qty': minQty,
        'refundable': refundable,
        'digital_product_type': digitalProductType,
        'digital_file_ready': digitalFileReady,
        'images': List<dynamic>.from(images.map((x) => x)),
        'color_image': List<dynamic>.from(colorImage.map((x) => x)),
        'thumbnail': thumbnail,
        'featured': featured,
        'flash_deal': flashDeal,
        'video_provider': videoProvider,
        'video_url': videoUrl,
        'colors': List<dynamic>.from(colors.map((x) => x)),
        'variant_product': variantProduct,
        'attributes': List<dynamic>.from(attributes.map((x) => x)),
        'choice_options': List<dynamic>.from(choiceOptions.map((x) => x)),
        'variation': List<dynamic>.from(variation.map((x) => x)),
        'published': published,
        'unit_price': unitPrice,
        'purchase_price': purchasePrice,
        'tax': tax,
        'tax_type': taxType,
        'tax_model': taxModel,
        'discount': discount,
        'discount_type': discountType,
        'current_stock': currentStock,
        'minimum_order_qty': minimumOrderQty,
        'details': details,
        'free_shipping': freeShipping,
        'attachment': attachment,
        'created_at': createdAt,
        'updated_at': updatedAt.toIso8601String(),
        'status': status,
        'featured_status': featuredStatus,
        'meta_title': metaTitle,
        'meta_description': metaDescription,
        'meta_image': metaImage,
        'request_status': requestStatus,
        'denied_note': deniedNote,
        'shipping_cost': shippingCost,
        'multiply_qty': multiplyQty,
        'temp_shipping_cost': tempShippingCost,
        'is_shipping_cost_updated': isShippingCostUpdated,
        'code': code,
        'colors_formatted': List<dynamic>.from(colorsFormatted.map((x) => x)),
        'translations': List<dynamic>.from(translations.map((x) => x)),
        'reviews': List<dynamic>.from(reviews.map((x) => x.toJson())),
      };
}

class CategoryId {
  String id;
  int position;

  CategoryId({
    required this.id,
    required this.position,
  });

  factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
        id: json['id'],
        position: json['position'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
      };
}

class Review {
  int id;
  int productId;
  int customerId;
  dynamic deliveryManId;
  int orderId;
  String? comment;
  String? attachment;
  int rating;
  int status;
  bool isSaved;
  DateTime createdAt;
  DateTime updatedAt;

  Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.deliveryManId,
    required this.orderId,
    required this.comment,
    required this.attachment,
    required this.rating,
    required this.status,
    required this.isSaved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        productId: json['product_id'],
        customerId: json['customer_id'],
        deliveryManId: json['delivery_man_id'],
        orderId: json['order_id'],
        comment: json['comment'],
        attachment: json['attachment'],
        rating: json['rating'],
        status: json['status'],
        isSaved: json['is_saved'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'customer_id': customerId,
        'delivery_man_id': deliveryManId,
        'order_id': orderId,
        'comment': comment,
        'attachment': attachment,
        'rating': rating,
        'status': status,
        'is_saved': isSaved,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
