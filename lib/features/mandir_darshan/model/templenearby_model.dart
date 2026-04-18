class TempleModel {
  int? status;
  String? message;
  int? recode;
  List<Data>? data;

  TempleModel({this.status, this.message, this.recode, this.data});

  TempleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    recode = json['recode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['recode'] = recode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
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
  Country? country;
  String? videoUrl;
  String? videoProvider;
  String? entryFee;
  String? openingTime;
  String? closeingTime;
  String? requireTime;
  String? image;
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

  Data(
      {this.enName,
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
      this.hiTempleLocalFood});

  Data.fromJson(Map<String, dynamic> json) {
    enName = json['en_name'];
    enShortDescription = json['en_short_description'];
    enFacilities = json['en_facilities'];
    enTipsRestrictions = json['en_tips_restrictions'];
    enDetails = json['en_details'];
    enMoreDetails = json['en_more_details'];
    enTempleKnown = json['en_temple_known'];
    enExpectDetails = json['en_expect_details'];
    enTipsDetails = json['en_tips_details'];
    enTempleServices = json['en_temple_services'];
    enTempleAarti = json['en_temple_aarti'];
    enTouristPlace = json['en_tourist_place'];
    enTempleLocalFood = json['en_temple_local_food'];
    id = json['id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    categoryId = json['category_id'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    cities = json['cities'] != null ? Cities.fromJson(json['cities']) : null;
    states = json['states'] != null ? States.fromJson(json['states']) : null;
    country =
        json['country'] != null ? Country.fromJson(json['country']) : null;
    videoUrl = json['video_url'];
    videoProvider = json['video_provider'];
    entryFee = json['entry_fee'];
    openingTime = json['opening_time'];
    closeingTime = json['closeing_time'];
    requireTime = json['require_time'];
    image = json['image'];
    hiName = json['hi_name'];
    hiShortDescription = json['hi_short_description'];
    hiFacilities = json['hi_facilities'];
    hiTipsRestrictions = json['hi_tips_restrictions'];
    hiDetails = json['hi_details'];
    hiMoreDetails = json['hi_more_details'];
    hiTempleKnown = json['hi_temple_known'];
    hiExpectDetails = json['hi_expect_details'];
    hiTipsDetails = json['hi_tips_details'];
    hiTempleServices = json['hi_temple_services'];
    hiTempleAarti = json['hi_temple_aarti'];
    hiTouristPlace = json['hi_tourist_place'];
    hiTempleLocalFood = json['hi_temple_local_food'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en_name'] = enName;
    data['en_short_description'] = enShortDescription;
    data['en_facilities'] = enFacilities;
    data['en_tips_restrictions'] = enTipsRestrictions;
    data['en_details'] = enDetails;
    data['en_more_details'] = enMoreDetails;
    data['en_temple_known'] = enTempleKnown;
    data['en_expect_details'] = enExpectDetails;
    data['en_tips_details'] = enTipsDetails;
    data['en_temple_services'] = enTempleServices;
    data['en_temple_aarti'] = enTempleAarti;
    data['en_tourist_place'] = enTouristPlace;
    data['en_temple_local_food'] = enTempleLocalFood;
    data['id'] = id;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['category_id'] = categoryId;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (cities != null) {
      data['cities'] = cities!.toJson();
    }
    if (states != null) {
      data['states'] = states!.toJson();
    }
    if (country != null) {
      data['country'] = country!.toJson();
    }
    data['video_url'] = videoUrl;
    data['video_provider'] = videoProvider;
    data['entry_fee'] = entryFee;
    data['opening_time'] = openingTime;
    data['closeing_time'] = closeingTime;
    data['require_time'] = requireTime;
    data['image'] = image;
    data['hi_name'] = hiName;
    data['hi_short_description'] = hiShortDescription;
    data['hi_facilities'] = hiFacilities;
    data['hi_tips_restrictions'] = hiTipsRestrictions;
    data['hi_details'] = hiDetails;
    data['hi_more_details'] = hiMoreDetails;
    data['hi_temple_known'] = hiTempleKnown;
    data['hi_expect_details'] = hiExpectDetails;
    data['hi_tips_details'] = hiTipsDetails;
    data['hi_temple_services'] = hiTempleServices;
    data['hi_temple_aarti'] = hiTempleAarti;
    data['hi_tourist_place'] = hiTouristPlace;
    data['hi_temple_local_food'] = hiTempleLocalFood;
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? shortDescription;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  Category(
      {this.id,
      this.name,
      this.shortDescription,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Cities {
  int? id;
  String? city;
  int? countryId;
  int? stateId;
  String? shortDesc;
  String? description;
  String? images;
  String? latitude;
  String? longitude;
  String? famousFor;
  String? festivalsAndEvents;
  int? status;
  String? createdAt;
  String? updatedAt;

  Cities(
      {this.id,
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
      this.updatedAt});

  Cities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    city = json['city'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    shortDesc = json['short_desc'];
    description = json['description'];
    images = json['images'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    famousFor = json['famous_for'];
    festivalsAndEvents = json['festivals_and_events'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['city'] = city;
    data['country_id'] = countryId;
    data['state_id'] = stateId;
    data['short_desc'] = shortDesc;
    data['description'] = description;
    data['images'] = images;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['famous_for'] = famousFor;
    data['festivals_and_events'] = festivalsAndEvents;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class States {
  int? id;
  String? name;
  int? countryId;

  States({this.id, this.name, this.countryId});

  States.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryId = json['country_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country_id'] = countryId;
    return data;
  }
}

class Country {
  int? id;
  String? sortname;
  String? name;

  Country({this.id, this.sortname, this.name});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sortname = json['sortname'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sortname'] = sortname;
    data['name'] = name;
    return data;
  }
}
