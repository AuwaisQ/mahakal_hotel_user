// To parse this JSON data, do
//
//     final templeModel = templeModelFromJson(jsonString);

import 'dart:convert';

TempleModel templeModelFromJson(String str) =>
    TempleModel.fromJson(json.decode(str));

String templeModelToJson(TempleModel data) => json.encode(data.toJson());

class TempleModel {
  int? status;
  String? message;
  int? recode;
  List<Datum>? data;

  TempleModel({
    this.status,
    this.message,
    this.recode,
    this.data,
  });

  factory TempleModel.fromJson(Map<String, dynamic> json) => TempleModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? enName;
  String? enShortDescription;
  String? enFacilities;
  String? enTipsRestrictions;
  String? enDetails;
  String? enMoreDetails;
  String? enTempleKnown;
  String? enExpectDetails;
  String? enTipsDetails;
  String? enTempleServices;
  String? enTempleAarti;
  String? enTouristPlace;
  String? enTempleLocalFood;
  int? id;
  String? latitude;
  String? longitude;
  int? categoryId;
  Category? category;
  Cities? cities;
  States? states;
  dynamic country;
  dynamic videoUrl;
  String? videoProvider;
  String? entryFee;
  String? openingTime;
  String? closeingTime;
  String? requireTime;
  String? image;
  int? vipDarshanStatus;
  String? hiName;
  String? hiShortDescription;
  String? hiFacilities;
  String? hiTipsRestrictions;
  String? hiDetails;
  String? hiMoreDetails;
  String? hiTempleKnown;
  String? hiExpectDetails;
  String? hiTipsDetails;
  String? hiTempleServices;
  String? hiTempleAarti;
  String? hiTouristPlace;
  String? hiTempleLocalFood;

  Datum({
    this.enName,
    this.enShortDescription,
    this.enFacilities,
    this.enTipsRestrictions,
    this.enDetails,
    this.enMoreDetails,
    this.enTempleKnown,
    this.enExpectDetails,
    this.enTipsDetails,
    this.enTempleServices,
    this.enTempleAarti,
    this.enTouristPlace,
    this.enTempleLocalFood,
    this.id,
    this.latitude,
    this.longitude,
    this.categoryId,
    this.category,
    this.cities,
    this.states,
    this.country,
    this.videoUrl,
    this.videoProvider,
    this.entryFee,
    this.openingTime,
    this.closeingTime,
    this.requireTime,
    this.image,
    this.vipDarshanStatus,
    this.hiName,
    this.hiShortDescription,
    this.hiFacilities,
    this.hiTipsRestrictions,
    this.hiDetails,
    this.hiMoreDetails,
    this.hiTempleKnown,
    this.hiExpectDetails,
    this.hiTipsDetails,
    this.hiTempleServices,
    this.hiTempleAarti,
    this.hiTouristPlace,
    this.hiTempleLocalFood,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        enName: json["en_name"],
        enShortDescription: json["en_short_description"],
        enFacilities: json["en_facilities"],
        enTipsRestrictions: json["en_tips_restrictions"],
        enDetails: json["en_details"],
        enMoreDetails: json["en_more_details"],
        enTempleKnown: json["en_temple_known"],
        enExpectDetails: json["en_expect_details"],
        enTipsDetails: json["en_tips_details"],
        enTempleServices: json["en_temple_services"],
        enTempleAarti: json["en_temple_aarti"],
        enTouristPlace: json["en_tourist_place"],
        enTempleLocalFood: json["en_temple_local_food"],
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        categoryId: json["category_id"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        cities: json["cities"] == null ? null : Cities.fromJson(json["cities"]),
        states: json["states"] == null ? null : States.fromJson(json["states"]),
        country: json["country"],
        videoUrl: json["video_url"],
        videoProvider: json["video_provider"],
        entryFee: json["entry_fee"],
        openingTime: json["opening_time"],
        closeingTime: json["closeing_time"],
        requireTime: json["require_time"],
        image: json["image"],
        vipDarshanStatus: json["vip_darshan_status"],
        hiName: json["hi_name"],
        hiShortDescription: json["hi_short_description"],
        hiFacilities: json["hi_facilities"],
        hiTipsRestrictions: json["hi_tips_restrictions"],
        hiDetails: json["hi_details"],
        hiMoreDetails: json["hi_more_details"],
        hiTempleKnown: json["hi_temple_known"],
        hiExpectDetails: json["hi_expect_details"],
        hiTipsDetails: json["hi_tips_details"],
        hiTempleServices: json["hi_temple_services"],
        hiTempleAarti: json["hi_temple_aarti"],
        hiTouristPlace: json["hi_tourist_place"],
        hiTempleLocalFood: json["hi_temple_local_food"],
      );

  Map<String, dynamic> toJson() => {
        "en_name": enName,
        "en_short_description": enShortDescription,
        "en_facilities": enFacilities,
        "en_tips_restrictions": enTipsRestrictions,
        "en_details": enDetails,
        "en_more_details": enMoreDetails,
        "en_temple_known": enTempleKnown,
        "en_expect_details": enExpectDetails,
        "en_tips_details": enTipsDetails,
        "en_temple_services": enTempleServices,
        "en_temple_aarti": enTempleAarti,
        "en_tourist_place": enTouristPlace,
        "en_temple_local_food": enTempleLocalFood,
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "category_id": categoryId,
        "category": category?.toJson(),
        "cities": cities?.toJson(),
        "states": states?.toJson(),
        "country": country,
        "video_url": videoUrl,
        "video_provider": videoProvider,
        "entry_fee": entryFee,
        "opening_time": openingTime,
        "closeing_time": closeingTime,
        "require_time": requireTime,
        "image": image,
        "vip_darshan_status": vipDarshanStatus,
        "hi_name": hiName,
        "hi_short_description": hiShortDescription,
        "hi_facilities": hiFacilities,
        "hi_tips_restrictions": hiTipsRestrictions,
        "hi_details": hiDetails,
        "hi_more_details": hiMoreDetails,
        "hi_temple_known": hiTempleKnown,
        "hi_expect_details": hiExpectDetails,
        "hi_tips_details": hiTipsDetails,
        "hi_temple_services": hiTempleServices,
        "hi_temple_aarti": hiTempleAarti,
        "hi_tourist_place": hiTouristPlace,
        "hi_temple_local_food": hiTempleLocalFood,
      };
}

class Category {
  int? id;
  String? name;
  String? shortDescription;
  String? image;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.shortDescription,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        shortDescription: json["short_description"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_description": shortDescription,
        "image": image,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Cities {
  int? id;
  String? city;
  dynamic countryId;
  int? stateId;
  String? shortDesc;
  String? description;
  dynamic images;
  String? latitude;
  String? longitude;
  String? famousFor;
  String? festivalsAndEvents;
  int? status;
  DateTime? createdAt;
  dynamic updatedAt;

  Cities({
    this.id,
    this.city,
    this.countryId,
    this.stateId,
    this.shortDesc,
    this.description,
    this.images,
    this.latitude,
    this.longitude,
    this.famousFor,
    this.festivalsAndEvents,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Cities.fromJson(Map<String, dynamic> json) => Cities(
        id: json["id"],
        city: json["city"],
        countryId: json["country_id"],
        stateId: json["state_id"],
        shortDesc: json["short_desc"],
        description: json["description"],
        images: json["images"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        famousFor: json["famous_for"],
        festivalsAndEvents: json["festivals_and_events"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "city": city,
        "country_id": countryId,
        "state_id": stateId,
        "short_desc": shortDesc,
        "description": description,
        "images": images,
        "latitude": latitude,
        "longitude": longitude,
        "famous_for": famousFor,
        "festivals_and_events": festivalsAndEvents,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt,
      };
}

class States {
  int? id;
  String? name;
  int? countryId;

  States({
    this.id,
    this.name,
    this.countryId,
  });

  factory States.fromJson(Map<String, dynamic> json) => States(
        id: json["id"],
        name: json["name"],
        countryId: json["country_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country_id": countryId,
      };
}
