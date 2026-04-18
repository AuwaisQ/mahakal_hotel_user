class ChadhavaModel {
  ChadhavaModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<Chadhavadetail> data;

  factory ChadhavaModel.fromJson(Map<String, dynamic> json) {
    return ChadhavaModel(
      status: json['status'] ?? 0,
      data: json['data'] == null
          ? []
          : List<Chadhavadetail>.from(
              json['data']!.map((x) => Chadhavadetail.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return '$status, $data, ';
  }
}

class Chadhavadetail {
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

  final int id;
  final String enName;
  final String hiName;
  final String enPoojaHeading;
  final String hiPoojaHeading;
  final String slug;
  final String image;
  final int status;
  final int userId;
  final String addedBy;
  final String enShortDetails;
  final String hiShortDetails;
  final dynamic productType;
  final String enDetails;
  final String hiDetails;
  final String productId;
  final String enChadhavaVenue;
  final String hiChadhavaVenue;
  final String chadhavaWeek;
  final int isVideo;
  final String thumbnail;
  final dynamic digitalFileReady;
  final String enMetaTitle;
  final dynamic hiMetaTitle;
  final String metaDescription;
  final String metaImage;
  final List<Product> products;
  final DateTime? nextChadhavaDate;
  final String chadhavaTypeText;

  factory Chadhavadetail.fromJson(Map<String, dynamic> json) {
    return Chadhavadetail(
      id: json['id'] ?? 0,
      enName: json['en_name'] ?? '',
      hiName: json['hi_name'] ?? '',
      enPoojaHeading: json['en_pooja_heading'] ?? '',
      hiPoojaHeading: json['hi_pooja_heading'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 0,
      userId: json['user_id'] ?? 0,
      addedBy: json['added_by'] ?? '',
      enShortDetails: json['en_short_details'] ?? '',
      hiShortDetails: json['hi_short_details'] ?? '',
      productType: json['product_type'],
      enDetails: json['en_details'] ?? '',
      hiDetails: json['hi_details'] ?? '',
      productId: json['product_id'] ?? '',
      enChadhavaVenue: json['en_chadhava_venue'] ?? '',
      hiChadhavaVenue: json['hi_chadhava_venue'] ?? '',
      chadhavaWeek: json['chadhava_week'] ?? '',
      isVideo: json['is_video'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      digitalFileReady: json['digital_file_ready'],
      enMetaTitle: json['en_meta_title'] ?? '',
      hiMetaTitle: json['hi_meta_title'],
      metaDescription: json['meta_description'] ?? '',
      metaImage: json['meta_image'] ?? '',
      products: json['products'] == null
          ? []
          : List<Product>.from(
              json['products']!.map((x) => Product.fromJson(x))),
      nextChadhavaDate: DateTime.tryParse(json['next_chadhava_date'] ?? ''),
      chadhavaTypeText: json['chadhava_type_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'en_name': enName,
        'hi_name': hiName,
        'en_pooja_heading': enPoojaHeading,
        'hi_pooja_heading': hiPoojaHeading,
        'slug': slug,
        'image': image,
        'status': status,
        'user_id': userId,
        'added_by': addedBy,
        'en_short_details': enShortDetails,
        'hi_short_details': hiShortDetails,
        'product_type': productType,
        'en_details': enDetails,
        'hi_details': hiDetails,
        'product_id': productId,
        'en_chadhava_venue': enChadhavaVenue,
        'hi_chadhava_venue': hiChadhavaVenue,
        'chadhava_week': chadhavaWeek,
        'is_video': isVideo,
        'thumbnail': thumbnail,
        'digital_file_ready': digitalFileReady,
        'en_meta_title': enMetaTitle,
        'hi_meta_title': hiMetaTitle,
        'meta_description': metaDescription,
        'meta_image': metaImage,
        'products': products.map((x) => x.toJson()).toList(),
        'next_chadhava_date': nextChadhavaDate?.toIso8601String(),
        'chadhava_type_text': chadhavaTypeText,
      };

  @override
  String toString() {
    return '$id, $enName, $hiName, $enPoojaHeading, $hiPoojaHeading, $slug, $image, $status, $userId, $addedBy, $enShortDetails, $hiShortDetails, $productType, $enDetails, $hiDetails, $productId, $enChadhavaVenue, $hiChadhavaVenue, $chadhavaWeek, $isVideo, $thumbnail, $digitalFileReady, $enMetaTitle, $hiMetaTitle, $metaDescription, $metaImage, $products, $nextChadhavaDate, $chadhavaTypeText, ';
  }
}

class Product {
  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? '',
      enName: json['en_name'] ?? '',
      hiName: json['hi_name'] ?? '',
      enDetails: json['en_details'] ?? '',
      hiDetails: json['hi_details'] ?? '',
      price: json['price'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      images: json['images'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'en_name': enName,
        'hi_name': hiName,
        'en_details': enDetails,
        'hi_details': hiDetails,
        'price': price,
        'thumbnail': thumbnail,
        'images': images,
      };

  @override
  String toString() {
    return '$productId, $enName, $hiName, $enDetails, $hiDetails, $price, $thumbnail, $images, ';
  }
}
