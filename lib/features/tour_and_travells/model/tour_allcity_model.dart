class TourAllCityModel {
  TourAllCityModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final dynamic status;
  final dynamic count;
  final List<AllCityTour> data;

  factory TourAllCityModel.fromJson(Map<String, dynamic> json) {
    return TourAllCityModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null
          ? []
          : List<AllCityTour>.from(
              json["data"]!.map((x) => AllCityTour.fromJson(x))),
    );
  }
}

class AllCityTour {
  AllCityTour({
    required this.enStateName,
    required this.hiStateName,
    required this.list,
  });

  final String enStateName;
  final String hiStateName;
  final List<ListElement> list;

  factory AllCityTour.fromJson(Map<String, dynamic> json) {
    return AllCityTour(
      enStateName: json["en_state_name"] ?? "",
      hiStateName: json["hi_state_name"] ?? "",
      list: json["list"] == null
          ? []
          : List<ListElement>.from(
              json["list"]!.map((x) => ListElement.fromJson(x))),
    );
  }
}

class ListElement {
  ListElement({
    required this.id,
    required this.enCitiesName,
    required this.hiCitiesName,
    required this.hiTourName,
    required this.enTourName,
    required this.enNumberOfDay,
    required this.hiNumberOfDay,
    required this.isPersonUse,
    required this.exTransportPrice,
    required this.cabList,
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
    required this.totalTourCount,
  });

  final int id;
  final String enCitiesName;
  final String hiCitiesName;
  final String hiTourName;
  final String enTourName;
  final dynamic enNumberOfDay;
  final dynamic hiNumberOfDay;
  final dynamic isPersonUse;
  final List<dynamic> exTransportPrice;
  final List<CabList> cabList;
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
  final dynamic totalTourCount;

  factory ListElement.fromJson(Map<String, dynamic> json) {
    return ListElement(
      id: json["id"] ?? 0,
      enCitiesName: json["en_cities_name"] ?? "",
      hiCitiesName: json["hi_cities_name"] ?? "",
      hiTourName: json["hi_tour_name"] ?? "",
      enTourName: json["en_tour_name"] ?? "",
      enNumberOfDay: json["en_number_of_day"] ?? "",
      hiNumberOfDay: json["hi_number_of_day"] ?? "",
      isPersonUse: json["is_person_use"] ?? 0,
      exTransportPrice: json["ex_transport_price"] == null
          ? []
          : List<dynamic>.from(json["ex_transport_price"]!.map((x) => x)),
      cabList: json["cab_list"] == null
          ? []
          : List<CabList>.from(
              json["cab_list"]!.map((x) => CabList.fromJson(x))),
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
      totalTourCount: json["total_tour_count"] ?? "",
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

class ExTransportPrice {
  ExTransportPrice({
    required this.id,
    required this.min,
    required this.max,
    required this.pick,
    required this.drop,
    required this.both,
  });

  final int id;
  final dynamic min;
  final dynamic max;
  final dynamic pick;
  final dynamic drop;
  final dynamic both;

  factory ExTransportPrice.fromJson(Map<String, dynamic> json) {
    return ExTransportPrice(
      id: json["id"] ?? 0,
      min: json["min"] ?? "",
      max: json["max"] ?? "",
      pick: json["pick"] ?? "",
      drop: json["drop"] ?? "",
      both: json["both"] ?? "",
    );
  }
}
