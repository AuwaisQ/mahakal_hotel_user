class PoojaHomePageModel {
  PoojaHomePageModel({
    required this.status,
    required this.subcategory,
  });

  final int status;
  final List<Subcategory> subcategory;

  factory PoojaHomePageModel.fromJson(Map<String, dynamic> json) {
    return PoojaHomePageModel(
      status: json["status"] ?? 0,
      subcategory: json["subcategory"] == null
          ? []
          : List<Subcategory>.from(
              json["subcategory"]!.map((x) => Subcategory.fromJson(x))),
    );
  }
}

class Subcategory {
  Subcategory({
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
    required this.enShortBenifits,
    required this.hiShortBenifits,
    required this.productType,
    required this.poojaType,
    required this.schedule,
    required this.counsellingMainPrice,
    required this.counsellingSellingPrice,
    required this.enDetails,
    required this.hiDetails,
    required this.enBenefits,
    required this.hiBenefits,
    required this.enProcess,
    required this.hiProcess,
    required this.enTempleDetails,
    required this.hiTempleDetails,
    required this.categoryIds,
    required this.categoryId,
    required this.subCategoryId,
    required this.subSubCategoryId,
    required this.productId,
    required this.packagesId,
    required this.panditAssign,
    required this.enPoojaVenue,
    required this.hiPoojaVenue,
    required this.poojaTime,
    required this.weekDays,
    required this.videoProvider,
    required this.videoUrl,
    required this.thumbnail,
    required this.digitalFileReady,
    required this.enMetaTitle,
    required this.hiMetaTitle,
    required this.metaDescription,
    required this.metaImage,
    required this.packages,
    required this.products,
    required this.nextPoojaDate,
    required this.poojaTypeText,
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
  final String enShortBenifits;
  final String hiShortBenifits;
  final String productType;
  final int poojaType;
  final dynamic schedule;
  final dynamic counsellingMainPrice;
  final dynamic counsellingSellingPrice;
  final String enDetails;
  final String hiDetails;
  final String enBenefits;
  final String hiBenefits;
  final String enProcess;
  final String hiProcess;
  final String enTempleDetails;
  final String hiTempleDetails;
  final String categoryIds;
  final int categoryId;
  final int subCategoryId;
  final dynamic subSubCategoryId;
  final String productId;
  final String packagesId;
  final dynamic panditAssign;
  final String enPoojaVenue;
  final String hiPoojaVenue;
  final DateTime? poojaTime;
  final String weekDays;
  final String videoProvider;
  final String videoUrl;
  final String thumbnail;
  final dynamic digitalFileReady;
  final String enMetaTitle;
  final dynamic hiMetaTitle;
  final String metaDescription;
  final String metaImage;
  final List<Package> packages;
  final List<Product> products;
  final DateTime? nextPoojaDate;
  final String poojaTypeText;

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enPoojaHeading: json["en_pooja_heading"] ?? "",
      hiPoojaHeading: json["hi_pooja_heading"] ?? "",
      slug: json["slug"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? 0,
      userId: json["user_id"] ?? 0,
      addedBy: json["added_by"] ?? "",
      enShortBenifits: json["en_short_benifits"] ?? "",
      hiShortBenifits: json["hi_short_benifits"] ?? "",
      productType: json["product_type"] ?? "",
      poojaType: json["pooja_type"] ?? 0,
      schedule: json["schedule"],
      counsellingMainPrice: json["counselling_main_price"],
      counsellingSellingPrice: json["counselling_selling_price"],
      enDetails: json["en_details"] ?? "",
      hiDetails: json["hi_details"] ?? "",
      enBenefits: json["en_benefits"] ?? "",
      hiBenefits: json["hi_benefits"] ?? "",
      enProcess: json["en_process"] ?? "",
      hiProcess: json["hi_process"] ?? "",
      enTempleDetails: json["en_temple_details"] ?? "",
      hiTempleDetails: json["hi_temple_details"] ?? "",
      categoryIds: json["category_ids"] ?? "",
      categoryId: json["category_id"] ?? 0,
      subCategoryId: json["sub_category_id"] ?? 0,
      subSubCategoryId: json["sub_sub_category_id"],
      productId: json["product_id"] ?? "",
      packagesId: json["packages_id"] ?? "",
      panditAssign: json["pandit_assign"],
      enPoojaVenue: json["en_pooja_venue"] ?? "",
      hiPoojaVenue: json["hi_pooja_venue"] ?? "",
      poojaTime: DateTime.tryParse(json["pooja_time"] ?? ""),
      weekDays: json["week_days"] ?? "",
      videoProvider: json["video_provider"] ?? "",
      videoUrl: json["video_url"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      digitalFileReady: json["digital_file_ready"],
      enMetaTitle: json["en_meta_title"] ?? "",
      hiMetaTitle: json["hi_meta_title"],
      metaDescription: json["meta_description"] ?? "",
      metaImage: json["meta_image"] ?? "",
      packages: json["packages"] == null
          ? []
          : List<Package>.from(
              json["packages"]!.map((x) => Package.fromJson(x))),
      products: json["products"] == null
          ? []
          : List<Product>.from(
              json["products"]!.map((x) => Product.fromJson(x))),
      nextPoojaDate: DateTime.tryParse(json["next_pooja_date"] ?? ""),
      poojaTypeText: json["pooja_type_text"] ?? "",
    );
  }
}

class Package {
  Package({
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.person,
    required this.color,
    required this.enDescription,
    required this.hiDescription,
    required this.packagePrice,
  });

  final String packageId;
  final String enPackageName;
  final String hiPackageName;
  final int person;
  final String color;
  final String enDescription;
  final String hiDescription;
  final String packagePrice;

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      person: json["person"] ?? 0,
      color: json["color"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      packagePrice: json["package_price"] ?? "",
    );
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
}
