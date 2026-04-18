class CityDetailsModel {
  CityDetailsModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final Data? data;

  factory CityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CityDetailsModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.enTourName,
    required this.hiTourName,
    required this.enDescription,
    required this.hiDescription,
    required this.enHighlights,
    required this.hiHighlights,
    required this.enInclusion,
    required this.hiInclusion,
    required this.enExclusion,
    required this.hiExclusion,
    required this.enTermsAndConditions,
    required this.hiTermsAndConditions,
    required this.enCancellationPolicy,
    required this.hiCancellationPolicy,
    required this.enNotes,
    required this.hiNotes,
    required this.useDate,
    required this.customizedType,
    required this.date,
    required this.shareLink,
    required this.pickupTime,
    required this.pickupLocation,
    required this.pickupLat,
    required this.pickupLong,
    required this.citiesName,
    required this.countryName,
    required this.stateName,
    required this.exDistance,
    required this.isPersonUse,
    required this.exTransportPrice,
    required this.transportGst,
    required this.tourGst,
    required this.itineraryUpload,
    required this.enNumberOfDay,
    required this.hiNumberOfDay,
    required this.hotelTypeList,
    required this.foodsList,
    required this.hotelList,
    required this.cabList,
    required this.packageList,
    required this.tourPackageTotalPrice,
    required this.services,
    required this.customizedDates,
    required this.image,
    required this.imageList,
    required this.timeSlot,
    required this.itineraryPlace,
    required this.userBookingCount,
    required this.userProfileImage,
  });

  final String enTourName;
  final String hiTourName;
  final String enDescription;
  final String hiDescription;
  final String enHighlights;
  final String hiHighlights;
  final String enInclusion;
  final String hiInclusion;
  final String enExclusion;
  final String hiExclusion;
  final String enTermsAndConditions;
  final String hiTermsAndConditions;
  final String enCancellationPolicy;
  final String hiCancellationPolicy;
  final String enNotes;
  final String hiNotes;
  final dynamic useDate;
  final String customizedType;
  final String date;
  final String shareLink;
  final String pickupTime;
  final String pickupLocation;
  final String pickupLat;
  final String pickupLong;
  final String citiesName;
  final String countryName;
  final String stateName;
  final dynamic exDistance;
  final dynamic isPersonUse;
  final List<ExTransportPrice> exTransportPrice;
  final dynamic transportGst;
  final dynamic tourGst;
  final dynamic itineraryUpload;
  final dynamic enNumberOfDay;
  final dynamic hiNumberOfDay;
  final List<HotelTypeList> hotelTypeList;
  final List<FoodsListElement> foodsList;
  final List<FoodsListElement> hotelList;
  final List<CabList> cabList;
  final List<PackageList> packageList;
  final dynamic tourPackageTotalPrice;
  final List<String> services;
  final List<String> customizedDates;
  final String image;
  final List<String> imageList;
  final List<String> timeSlot;
  final List<ItineraryPlace> itineraryPlace;
  final dynamic userBookingCount;
  final List<String> userProfileImage;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      enTourName: json["en_tour_name"] ?? "",
      hiTourName: json["hi_tour_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      enHighlights: json["en_highlights"] ?? "",
      hiHighlights: json["hi_highlights"] ?? "",
      enInclusion: json["en_inclusion"] ?? "",
      hiInclusion: json["hi_inclusion"] ?? "",
      enExclusion: json["en_exclusion"] ?? "",
      hiExclusion: json["hi_exclusion"] ?? "",
      enTermsAndConditions: json["en_terms_and_conditions"] ?? "",
      hiTermsAndConditions: json["hi_terms_and_conditions"] ?? "",
      enCancellationPolicy: json["en_cancellation_policy"] ?? "",
      hiCancellationPolicy: json["hi_cancellation_policy"] ?? "",
      enNotes: json["en_notes"] ?? "",
      hiNotes: json["hi_notes"] ?? "",
      useDate: json["use_date"] ?? 0,
      customizedType: json["customized_type"] ?? "",
      date: json["date"] ?? "",
      shareLink: json["share_link"] ?? "",
      pickupTime: json["pickup_time"] ?? "",
      pickupLocation: json["pickup_location"] ?? "",
      pickupLat: json["pickup_lat"] ?? "",
      pickupLong: json["pickup_long"] ?? "",
      citiesName: json["cities_name"] ?? "",
      countryName: json["country_name"] ?? "",
      stateName: json["state_name"] ?? "",
      exDistance: json["ex_distance"] ?? 0,
      isPersonUse: json["is_person_use"] ?? 0,
      exTransportPrice: json["ex_transport_price"] == null
          ? []
          : List<ExTransportPrice>.from(json["ex_transport_price"]!
              .map((x) => ExTransportPrice.fromJson(x))),
      transportGst: json["transport_gst"] ?? 0,
      tourGst: json["tour_gst"] ?? 0,
      itineraryUpload: json["itineraryupload"] ?? "",
      enNumberOfDay: json["en_number_of_day"] ?? "",
      hiNumberOfDay: json["hi_number_of_day"] ?? "",
      hotelTypeList: json["hotel_type_list"] == null
          ? []
          : List<HotelTypeList>.from(
              json["hotel_type_list"]!.map((x) => HotelTypeList.fromJson(x))),
      foodsList: json["foods_list"] == null
          ? []
          : List<FoodsListElement>.from(
              json["foods_list"]!.map((x) => FoodsListElement.fromJson(x))),
      hotelList: json["hotel_list"] == null
          ? []
          : List<FoodsListElement>.from(
              json["hotel_list"]!.map((x) => FoodsListElement.fromJson(x))),
      cabList: json["cab_list"] == null
          ? []
          : List<CabList>.from(
              json["cab_list"]!.map((x) => CabList.fromJson(x))),
      packageList: json["package_list"] == null
          ? []
          : List<PackageList>.from(
              json["package_list"]!.map((x) => PackageList.fromJson(x))),
      tourPackageTotalPrice: json["tour_package_total_price"] ?? 0,
      services: json["services"] == null ? [] : List<String>.from(json["services"]!.map((x) => x)),
      customizedDates: json["customized_dates"] == null ? [] : List<String>.from(json["customized_dates"]!.map((x) => x)),
      image: json["image"] ?? "",
      imageList: json["image_list"] == null
          ? []
          : List<String>.from(json["image_list"]!.map((x) => x)),
      timeSlot: json["time_slot"] == null
          ? []
          : List<String>.from(json["time_slot"]!.map((x) => x)),
      itineraryPlace: json["itinerary_place"] == null
          ? []
          : List<ItineraryPlace>.from(
              json["itinerary_place"]!.map((x) => ItineraryPlace.fromJson(x))),
      userBookingCount: json["user_booking_count"] ?? 0,
      userProfileImage: json["user_profile_image"] == null
          ? []
          : List<String>.from(json["user_profile_image"]!.map((x) => x)),
    );
  }
}

class CabList {
  CabList({
    required this.price,
    required this.cabId,
    required this.min,
    required this.max,
    required this.enCabName,
    required this.hiCabName,
    required this.enDescription,
    required this.hiDescription,
    required this.seats,
    required this.totalSeats,
    required this.totalSeatsMessage,
    required this.totalBookingSeats,
    required this.image,
  });

  final dynamic price;
  final dynamic cabId;
  final dynamic min;
  final dynamic max;
  final String enCabName;
  final String hiCabName;
  final String enDescription;
  final String hiDescription;
  final dynamic seats;
  final dynamic totalSeats;
  final dynamic totalSeatsMessage;
  final dynamic totalBookingSeats;
  final String image;

  factory CabList.fromJson(Map<String, dynamic> json) {
    return CabList(
      price: json["price"] ?? "",
      cabId: json["cab_id"] ?? 0,
      min: json["min"] ?? "",
      max: json["max"] ?? "",
      enCabName: json["en_cab_name"] ?? "",
      hiCabName: json["hi_cab_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      seats: json["seats"] ?? "",
      totalSeats: json["total_seats"] ?? 0,
      totalSeatsMessage: json["total_seats_message"] ?? 0,
      totalBookingSeats: json["total_booking_seats"] ?? 0,
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

  final dynamic id;
  final dynamic min;
  final dynamic max;
  final dynamic pick;
  final dynamic drop;
  final dynamic both;

  factory ExTransportPrice.fromJson(Map<String, dynamic> json) {
    return ExTransportPrice(
      id: json["id"] ?? 0,
      min: json["min"],
      max: json["max"],
      pick: json["pick"],
      drop: json["drop"],
      both: json["both"],
    );
  }
}

class FoodsListElement {
  FoodsListElement({
    required this.price,
    required this.packageId,
    required this.enPackageName,
    required this.enDescription,
    required this.hiPackageName,
    required this.hiDescription,
    required this.seats,
    required this.type,
    required this.title,
    required this.includedStatus,
    required this.hotelType,
    required this.image,
  });

  final dynamic price;
  final dynamic packageId;
  final String enPackageName;
  final String enDescription;
  final String hiPackageName;
  final String hiDescription;
  final dynamic seats;
  final String type;
  final String title;
  final dynamic includedStatus;
  final String hotelType;
  final String image;

  factory FoodsListElement.fromJson(Map<String, dynamic> json) {
    return FoodsListElement(
      price: json["price"] ?? "",
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      seats: json["seats"] ?? 0,
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      includedStatus: json["included_status"] ?? 0,
      hotelType: json["hotel_type"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class PackageList {
  PackageList({
    required this.price,
    required this.packageId,
    required this.enPackageName,
    required this.enDescription,
    required this.hiPackageName,
    required this.hiDescription,
    required this.seats,
    required this.type,
    required this.title,
    required this.includedStatus,
    required this.hotelType,
    required this.image,
  });

  final dynamic price;
  final dynamic packageId;
  final String enPackageName;
  final String enDescription;
  final String hiPackageName;
  final String hiDescription;
  final dynamic seats;
  final String type;
  final String title;
  final dynamic includedStatus;
  final String hotelType;
  final String image;

  factory PackageList.fromJson(Map<String, dynamic> json) {
    return PackageList(
      price: json["price"] ?? "",
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      seats: json["seats"] ?? 0,
      type: json["type"] ?? "",
      title: json["title"] ?? "",
      includedStatus: json["included_status"] ?? 0,
      hotelType: json["hotel_type"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class HotelTypeList {
  HotelTypeList({
    required this.hotelType,
    required this.translations,
  });

  final String hotelType;
  final List<dynamic> translations;

  factory HotelTypeList.fromJson(Map<String, dynamic> json) {
    return HotelTypeList(
      hotelType: json["hotel_type"] ?? "",
      translations: json["translations"] == null
          ? []
          : List<dynamic>.from(json["translations"]!.map((x) => x)),
    );
  }
}

class ItineraryPlace {
  ItineraryPlace({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.enTime,
    required this.hiTime,
    required this.enDescription,
    required this.hiDescription,
    required this.image,
  });

  final dynamic id;
  final String enName;
  final String hiName;
  final String enTime;
  final String hiTime;
  final String enDescription;
  final String hiDescription;
  final List<dynamic> image;

  factory ItineraryPlace.fromJson(Map<String, dynamic> json) {
    return ItineraryPlace(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enTime: json["en_time"] ?? "",
      hiTime: json["hi_time"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      image: json["image"] == null
          ? []
          : List<dynamic>.from(json["image"]!.map((x) => x)),
    );
  }
}
