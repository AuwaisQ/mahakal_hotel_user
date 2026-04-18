// // To parse this JSON data, do
// //
// //     final anushthanModel = anushthanModelFromJson(jsonString);
//
// import 'dart:convert';
//
// AnushthanModel anushthanModelFromJson(String str) => AnushthanModel.fromJson(json.decode(str));
//
// String anushthanModelToJson(AnushthanModel data) => json.encode(data.toJson());
//
// class AnushthanModel {
//   int status;
//   Anushthan anushthan;
//
//   AnushthanModel({
//     required this.status,
//     required this.anushthan,
//   });
//
//   factory AnushthanModel.fromJson(Map<String, dynamic> json) => AnushthanModel(
//     status: json["status"],
//     anushthan: Anushthan.fromJson(json["anushthan"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "anushthan": anushthan.toJson(),
//   };
// }
//
// class Anushthan {
//   int id;
//   String enName;
//   String hiName;
//   String slug;
//   String image;
//   int status;
//   int userId;
//   String addedBy;
//   dynamic enShortBenefits;
//   dynamic hiShortBenefits;
//   String enDetails;
//   dynamic hiDetails;
//   String enBenefits;
//   String hiBenefits;
//   String enProcess;
//   String hiProcess;
//   String enTempleDetails;
//   String hiTempleDetails;
//   int isAnushthan;
//   String productId;
//   String packagesId;
//   String videoProvider;
//   String videoUrl;
//   String thumbnail;
//   dynamic digitalFileReady;
//   String enMetaTitle;
//   dynamic hiMetaTitle;
//   String metaDescription;
//   String metaImage;
//   List<Package> packages;
//   List<Product> products;
//
//   Anushthan({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.slug,
//     required this.image,
//     required this.status,
//     required this.userId,
//     required this.addedBy,
//     required this.enShortBenefits,
//     required this.hiShortBenefits,
//     required this.enDetails,
//     required this.hiDetails,
//     required this.enBenefits,
//     required this.hiBenefits,
//     required this.enProcess,
//     required this.hiProcess,
//     required this.enTempleDetails,
//     required this.hiTempleDetails,
//     required this.isAnushthan,
//     required this.productId,
//     required this.packagesId,
//     required this.videoProvider,
//     required this.videoUrl,
//     required this.thumbnail,
//     required this.digitalFileReady,
//     required this.enMetaTitle,
//     required this.hiMetaTitle,
//     required this.metaDescription,
//     required this.metaImage,
//     required this.packages,
//     required this.products,
//   });
//
//   factory Anushthan.fromJson(Map<String, dynamic> json) => Anushthan(
//     id: json["id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     slug: json["slug"],
//     image: json["image"],
//     status: json["status"],
//     userId: json["user_id"],
//     addedBy: json["added_by"],
//     enShortBenefits: json["en_short_benefits"],
//     hiShortBenefits: json["hi_short_benefits"],
//     enDetails: json["en_details"],
//     hiDetails: json["hi_details"],
//     enBenefits: json["en_benefits"],
//     hiBenefits: json["hi_benefits"],
//     enProcess: json["en_process"],
//     hiProcess: json["hi_process"],
//     enTempleDetails: json["en_temple_details"],
//     hiTempleDetails: json["hi_temple_details"],
//     isAnushthan: json["is_anushthan"],
//     productId: json["product_id"],
//     packagesId: json["packages_id"],
//     videoProvider: json["video_provider"],
//     videoUrl: json["video_url"],
//     thumbnail: json["thumbnail"],
//     digitalFileReady: json["digital_file_ready"],
//     enMetaTitle: json["en_meta_title"],
//     hiMetaTitle: json["hi_meta_title"],
//     metaDescription: json["meta_description"],
//     metaImage: json["meta_image"],
//     packages: List<Package>.from(json["packages"].map((x) => Package.fromJson(x))),
//     products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "slug": slug,
//     "image": image,
//     "status": status,
//     "user_id": userId,
//     "added_by": addedBy,
//     "en_short_benefits": enShortBenefits,
//     "hi_short_benefits": hiShortBenefits,
//     "en_details": enDetails,
//     "hi_details": hiDetails,
//     "en_benefits": enBenefits,
//     "hi_benefits": hiBenefits,
//     "en_process": enProcess,
//     "hi_process": hiProcess,
//     "en_temple_details": enTempleDetails,
//     "hi_temple_details": hiTempleDetails,
//     "is_anushthan": isAnushthan,
//     "product_id": productId,
//     "packages_id": packagesId,
//     "video_provider": videoProvider,
//     "video_url": videoUrl,
//     "thumbnail": thumbnail,
//     "digital_file_ready": digitalFileReady,
//     "en_meta_title": enMetaTitle,
//     "hi_meta_title": hiMetaTitle,
//     "meta_description": metaDescription,
//     "meta_image": metaImage,
//     "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
//     "products": List<dynamic>.from(products.map((x) => x.toJson())),
//   };
// }
//
// class Package {
//   String packageId;
//   String enPackageName;
//   String hiPackageName;
//   int person;
//   String color;
//   String enDescription;
//   String hiDescription;
//   String packagePrice;
//
//   Package({
//     required this.packageId,
//     required this.enPackageName,
//     required this.hiPackageName,
//     required this.person,
//     required this.color,
//     required this.enDescription,
//     required this.hiDescription,
//     required this.packagePrice,
//   });
//
//   factory Package.fromJson(Map<String, dynamic> json) => Package(
//     packageId: json["package_id"],
//     enPackageName: json["en_package_name"],
//     hiPackageName: json["hi_package_name"],
//     person: json["person"],
//     color: json["color"],
//     enDescription: json["en_description"],
//     hiDescription: json["hi_description"],
//     packagePrice: json["package_price"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "package_id": packageId,
//     "en_package_name": enPackageName,
//     "hi_package_name": hiPackageName,
//     "person": person,
//     "color": color,
//     "en_description": enDescription,
//     "hi_description": hiDescription,
//     "package_price": packagePrice,
//   };
// }
//
// class Product {
//   String productId;
//   String enName;
//   dynamic hiName;
//   int price;
//   String thumbnail;
//   String images;
//
//   Product({
//     required this.productId,
//     required this.enName,
//     required this.hiName,
//     required this.price,
//     required this.thumbnail,
//     required this.images,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     productId: json["product_id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     price: json["price"],
//     thumbnail: json["thumbnail"],
//     images: json["images"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "product_id": productId,
//     "en_name": enName,
//     "hi_name": hiName,
//     "price": price,
//     "thumbnail": thumbnail,
//     "images": images,
//   };
// }
