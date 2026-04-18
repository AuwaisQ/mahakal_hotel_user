class CityDetailsModel {
  int? status;
  String? message;
  int? recode;
  Citydetail? citydetail;

  CityDetailsModel({this.status, this.message, this.recode, this.citydetail});

  CityDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    recode = json['recode'];
    citydetail = json['citydetail'] != null
        ? Citydetail.fromJson(json['citydetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['recode'] = recode;
    if (citydetail != null) {
      data['citydetail'] = citydetail!.toJson();
    }
    return data;
  }
}

class Citydetail {
  String? enCity;
  String? enShortDesc;
  String? enDescription;
  String? enFamousFor;
  String? enFestivalsAndEvents;
  int? id;
  String? latitude;
  String? longitude;
  States? states;
  Country? country;
  List<Visits>? visits;
  String? hiCity;
  String? hiShortDesc;
  String? hiDescription;
  String? hiFamousFor;
  String? hiFestivalsAndEvents;
  List<String>? imageList;

  Citydetail(
      {this.enCity,
      this.enShortDesc,
      this.enDescription,
      this.enFamousFor,
      this.enFestivalsAndEvents,
      this.id,
      this.latitude,
      this.longitude,
      this.states,
      this.country,
      this.visits,
      this.hiCity,
      this.hiShortDesc,
      this.hiDescription,
      this.hiFamousFor,
      this.hiFestivalsAndEvents,
      this.imageList});

  Citydetail.fromJson(Map<String, dynamic> json) {
    enCity = json['en_city'];
    enShortDesc = json['en_short_desc'];
    enDescription = json['en_description'];
    enFamousFor = json['en_famous_for'];
    enFestivalsAndEvents = json['en_festivals_and_events'];
    id = json['id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    states = json['states'] != null ? States.fromJson(json['states']) : null;
    country =
        json['country'] != null ? Country.fromJson(json['country']) : null;
    if (json['visits'] != null) {
      visits = <Visits>[];
      json['visits'].forEach((v) {
        visits!.add(Visits.fromJson(v));
      });
    }
    hiCity = json['hi_city'];
    hiShortDesc = json['hi_short_desc'];
    hiDescription = json['hi_description'];
    hiFamousFor = json['hi_famous_for'];
    hiFestivalsAndEvents = json['hi_festivals_and_events'];
    imageList = json['image_list'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en_city'] = enCity;
    data['en_short_desc'] = enShortDesc;
    data['en_description'] = enDescription;
    data['en_famous_for'] = enFamousFor;
    data['en_festivals_and_events'] = enFestivalsAndEvents;
    data['id'] = id;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (states != null) {
      data['states'] = states!.toJson();
    }
    if (country != null) {
      data['country'] = country!.toJson();
    }
    if (visits != null) {
      data['visits'] = visits!.map((v) => v.toJson()).toList();
    }
    data['hi_city'] = hiCity;
    data['hi_short_desc'] = hiShortDesc;
    data['hi_description'] = hiDescription;
    data['hi_famous_for'] = hiFamousFor;
    data['hi_festivals_and_events'] = hiFestivalsAndEvents;
    data['image_list'] = imageList;
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

class Visits {
  String? enMonthName;
  String? enSeason;
  String? enCrowd;
  String? enWeather;
  String? enSight;
  String? hiMonthName;
  String? hiSeason;
  String? hiCrowd;
  String? hiWeather;
  String? hiSight;
  String? image;

  Visits(
      {this.enMonthName,
      this.enSeason,
      this.enCrowd,
      this.enWeather,
      this.enSight,
      this.hiMonthName,
      this.hiSeason,
      this.hiCrowd,
      this.hiWeather,
      this.hiSight,
      this.image});

  Visits.fromJson(Map<String, dynamic> json) {
    enMonthName = json['en_month_name'];
    enSeason = json['en_season'];
    enCrowd = json['en_crowd'];
    enWeather = json['en_weather'];
    enSight = json['en_sight'];
    hiMonthName = json['hi_month_name'];
    hiSeason = json['hi_season'];
    hiCrowd = json['hi_crowd'];
    hiWeather = json['hi_weather'];
    hiSight = json['hi_sight'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en_month_name'] = enMonthName;
    data['en_season'] = enSeason;
    data['en_crowd'] = enCrowd;
    data['en_weather'] = enWeather;
    data['en_sight'] = enSight;
    data['hi_month_name'] = hiMonthName;
    data['hi_season'] = hiSeason;
    data['hi_crowd'] = hiCrowd;
    data['hi_weather'] = hiWeather;
    data['hi_sight'] = hiSight;
    data['image'] = image;
    return data;
  }
}
