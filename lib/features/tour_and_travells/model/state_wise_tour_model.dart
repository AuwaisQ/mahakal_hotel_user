class StateWiseTourModel {
  StateWiseTourModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final List<StateData> data;

  factory StateWiseTourModel.fromJson(Map<String, dynamic> json) {
    return StateWiseTourModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null
          ? []
          : List<StateData>.from(
              json["data"]!.map((x) => StateData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $count, $data, ";
  }
}

class StateData {
  StateData({
    required this.enStateName,
    required this.hiStateName,
    required this.list,
  });

  final String enStateName;
  final String hiStateName;
  final List<ListElement> list;

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      enStateName: json["en_state_name"] ?? "",
      hiStateName: json["hi_state_name"] ?? "",
      list: json["list"] == null
          ? []
          : List<ListElement>.from(
              json["list"]!.map((x) => ListElement.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "en_state_name": enStateName,
        "hi_state_name": hiStateName,
        "list": list.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$enStateName, $hiStateName, $list, ";
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
    required this.packageList,
    required this.services,
    required this.useDate,
    required this.date,
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
  final String enCitiesName;
  final String hiCitiesName;
  final String hiTourName;
  final String enTourName;
  final dynamic enNumberOfDay;
  final dynamic hiNumberOfDay;
  final dynamic isPersonUse;
  final List<ExTransportPrice> exTransportPrice;
  final List<CabList> cabList;
  final List<PackageList> packageList;
  final List<String> services;
  final dynamic useDate;
  final dynamic date;
  final dynamic pickupTime;
  final String pickupLocation;
  final dynamic pickupLat;
  final dynamic pickupLong;
  final String citiesName;
  final String countryName;
  final String stateName;
  final String tourImage;

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
          : List<ExTransportPrice>.from(json["ex_transport_price"]!
              .map((x) => ExTransportPrice.fromJson(x))),
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_cities_name": enCitiesName,
        "hi_cities_name": hiCitiesName,
        "hi_tour_name": hiTourName,
        "en_tour_name": enTourName,
        "en_number_of_day": enNumberOfDay,
        "hi_number_of_day": hiNumberOfDay,
        "is_person_use": isPersonUse,
        "ex_transport_price": exTransportPrice.map((x) => x.toJson()).toList(),
        "cab_list": cabList.map((x) => x.toJson()).toList(),
        "package_list": packageList.map((x) => x.toJson()).toList(),
        "services": services.map((x) => x).toList(),
        "use_date": useDate,
        "date": date,
        "pickup_time": pickupTime,
        "pickup_location": pickupLocation,
        "pickup_lat": pickupLat,
        "pickup_long": pickupLong,
        "cities_name": citiesName,
        "country_name": countryName,
        "state_name": stateName,
        "tour_image": tourImage,
      };

  @override
  String toString() {
    return "$id, $enCitiesName, $hiCitiesName, $hiTourName, $enTourName, $enNumberOfDay, $hiNumberOfDay, $isPersonUse, $exTransportPrice, $cabList, $packageList, $services, $useDate, $date, $pickupTime, $pickupLocation, $pickupLat, $pickupLong, $citiesName, $countryName, $stateName, $tourImage, ";
  }
}

class CabList {
  CabList({
    required this.price,
    required this.cabId,
    required this.min,
    required this.max,
    required this.cabName,
    required this.seats,
    required this.image,
  });

  final dynamic price;
  final dynamic cabId;
  final dynamic min;
  final dynamic max;
  final String cabName;
  final dynamic seats;
  final String image;

  factory CabList.fromJson(Map<String, dynamic> json) {
    return CabList(
      price: json["price"] ?? "",
      cabId: json["cab_id"],
      min: json["min"],
      max: json["max"],
      cabName: json["cab_name"] ?? "",
      seats: json["seats"],
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "price": price,
        "cab_id": cabId,
        "min": min,
        "max": max,
        "cab_name": cabName,
        "seats": seats,
        "image": image,
      };

  @override
  String toString() {
    return "$price, $cabId, $min, $max, $cabName, $seats, $image, ";
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

  final dynamic id;
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "min": min,
        "max": max,
        "pick": pick,
        "drop": drop,
        "both": both,
      };

  @override
  String toString() {
    return "$id, $min, $max, $pick, $drop, $both, ";
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

  final dynamic price;
  final dynamic packageId;
  final String packageName;
  final dynamic seats;
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

  Map<String, dynamic> toJson() => {
        "price": price,
        "package_id": packageId,
        "package_name": packageName,
        "seats": seats,
        "type": type,
        "title": title,
        "image": image,
      };

  @override
  String toString() {
    return "$price, $packageId, $packageName, $seats, $type, $title, $image, ";
  }
}
