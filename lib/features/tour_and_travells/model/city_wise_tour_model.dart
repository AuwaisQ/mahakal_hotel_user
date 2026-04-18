class CityWiseTourModel {
  CityWiseTourModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final List<CityData> data;

  factory CityWiseTourModel.fromJson(Map<String, dynamic> json) {
    return CityWiseTourModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null
          ? []
          : List<CityData>.from(json["data"]!.map((x) => CityData.fromJson(x))),
    );
  }
}

class CityData {
  CityData({
    required this.id,
    required this.slug,
    required this.shareLink,
    required this.enCitiesName,
    required this.hiCitiesName,
    required this.hiTourName,
    required this.enTourName,
    required this.enNumberOfDay,
    required this.hiNumberOfDay,
    required this.isPersonUse,
    required this.tourType,
    required this.exTransportPrice,
    required this.cabList,
    required this.packageList,
    required this.services,
    required this.useDate,
    required this.date,
    required this.planTypeName,
    required this.planTypeColor,
    required this.tourOrderReviewCount,
    required this.reviewAvgStar,
    required this.percentageOff,
    required this.pickupTime,
    required this.pickupLocation,
    required this.pickupLat,
    required this.pickupLong,
    required this.citiesName,
    required this.countryName,
    required this.stateName,
    required this.tourImage,
  });

  final dynamic id;
  final dynamic slug;
  final dynamic shareLink;
  final String enCitiesName;
  final String hiCitiesName;
  final String hiTourName;
  final String enTourName;
  final dynamic enNumberOfDay;
  final dynamic hiNumberOfDay;
  final dynamic isPersonUse;
  final dynamic tourType;
  final List<dynamic> exTransportPrice;
  final List<CabList> cabList;
  final List<PackageList> packageList;
  final List<String> services;
  final dynamic useDate;
  final dynamic date;
  final String planTypeName;
  final String planTypeColor;
  final dynamic tourOrderReviewCount;
  final dynamic reviewAvgStar;
  final dynamic percentageOff;
  final dynamic pickupTime;
  final String pickupLocation;
  final dynamic pickupLat;
  final dynamic pickupLong;
  final String citiesName;
  final String countryName;
  final String stateName;
  final String tourImage;

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      shareLink: json["share_link"] ?? "",
      enCitiesName: json["en_cities_name"] ?? "",
      hiCitiesName: json["hi_cities_name"] ?? "",
      hiTourName: json["hi_tour_name"] ?? "",
      enTourName: json["en_tour_name"] ?? "",
      enNumberOfDay: json["en_number_of_day"] ?? "",
      hiNumberOfDay: json["hi_number_of_day"] ?? "",
      isPersonUse: json["is_person_use"] ?? 0,
      tourType: json["tour_type"] ?? "",
      exTransportPrice: json["ex_transport_price"] == null
          ? []
          : List<dynamic>.from(json["ex_transport_price"]!.map((x) => x)),
      cabList: json["cab_list"] == null
          ? []
          : List<CabList>.from(
              json["cab_list"]!.map((x) => CabList.fromJson(x))),
      packageList: json["package_list"] == null
          ? []
          : List<PackageList>.from(
              json["package_list"]!.map((x) => PackageList.fromJson(x))),
      services: json["services"] == null
          ? []
          : List<String>.from(json["services"]!.map((x) => x)),
      useDate: json["use_date"] ?? 0,
      date: json["date"] ?? "",
      planTypeName: json["plan_type_name"] ?? "",
      planTypeColor: json["plan_type_color"] ?? "",
      tourOrderReviewCount: json["tour_order_review_count"] ?? 0,
      reviewAvgStar: json["review_avg_star"] ?? "",
      percentageOff: json["percentage_off"] ?? 0,
      pickupTime: json["pickup_time"] ?? "",
      pickupLocation: json["pickup_location"] ?? "",
      pickupLat: json["pickup_lat"] ?? "",
      pickupLong: json["pickup_long"] ?? "",
      citiesName: json["cities_name"] ?? "",
      countryName: json["country_name"] ?? "",
      stateName: json["state_name"] ?? "",
      tourImage: json["tour_image"] ?? "",
    );
  }
}

class CabList {
  CabList({
    required this.minPrice,
    required this.price,
    required this.cabId,
    required this.min,
    required this.max,
    required this.cabName,
    required this.seats,
    required this.image,
  });

  final dynamic minPrice;
  final dynamic price;
  final dynamic cabId;
  final dynamic min;
  final dynamic max;
  final String cabName;
  final dynamic seats;
  final String image;

  factory CabList.fromJson(Map<String, dynamic> json) {
    return CabList(
      minPrice: json["min_price"] ?? "",
      price: json["price"] ?? "",
      cabId: json["cab_id"] ?? 0,
      min: json["min"] ?? "",
      max: json["max"] ?? "",
      cabName: json["cab_name"] ?? "",
      seats: json["seats"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class PackageList {
  PackageList({
    required this.price,
    required this.packageId,
    required this.packageName,
    required this.seats,
    required this.type,
    required this.title,
    required this.image,
  });

  final String price;
  final String packageId;
  final String packageName;
  final int seats;
  final String type;
  final String title;
  final String image;

  factory PackageList.fromJson(Map<String, dynamic> json) {
    return PackageList(
      price: json["price"] ?? "",
      packageId: json["package_id"] ?? "",
      packageName: json["package_name"] ?? "",
      seats: json["seats"] ?? 0,
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",
    );
  }
}
