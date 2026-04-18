// // To parse this JSON data, do
// //
// //     final cityModel = cityModelFromJson(jsonString);
//
// import 'dart:convert';
//
// CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));
//
// String cityModelToJson(CityModel data) => json.encode(data.toJson());
//
// class CityModel {
//   int status;
//   String message;
//   int recode;
//   List<City> city;
//
//   CityModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.city,
//   });
//
//   factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
//     status: json["status"],
//     message: json["message"],
//     recode: json["recode"],
//     city: List<City>.from(json["city"].map((x) => City.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "recode": recode,
//     "city": List<dynamic>.from(city.map((x) => x.toJson())),
//   };
// }
//
// class City {
//   String enCity;
//   String enShortDesc;
//   String enDescription;
//   String enFamousFor;
//   String enFestivalsAndEvents;
//   int id;
//   String latitude;
//   String longitude;
//   String image;
//   String hiCity;
//   String hiShortDesc;
//   String hiDescription;
//   String hiFamousFor;
//   String hiFestivalsAndEvents;
//
//   City({
//     required this.enCity,
//     required this.enShortDesc,
//     required this.enDescription,
//     required this.enFamousFor,
//     required this.enFestivalsAndEvents,
//     required this.id,
//     required this.latitude,
//     required this.longitude,
//     required this.image,
//     required this.hiCity,
//     required this.hiShortDesc,
//     required this.hiDescription,
//     required this.hiFamousFor,
//     required this.hiFestivalsAndEvents,
//   });
//
//   factory City.fromJson(Map<String, dynamic> json) => City(
//     enCity: json["en_city"],
//     enShortDesc: json["en_short_desc"],
//     enDescription: json["en_description"],
//     enFamousFor: json["en_famous_for"],
//     enFestivalsAndEvents: json["en_festivals_and_events"],
//     id: json["id"],
//     latitude: json["latitude"],
//     longitude: json["longitude"],
//     image: json["image"],
//     hiCity: json["hi_city"],
//     hiShortDesc: json["hi_short_desc"],
//     hiDescription: json["hi_description"],
//     hiFamousFor: json["hi_famous_for"],
//     hiFestivalsAndEvents: json["hi_festivals_and_events"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "en_city": enCity,
//     "en_short_desc": enShortDesc,
//     "en_description": enDescription,
//     "en_famous_for": enFamousFor,
//     "en_festivals_and_events": enFestivalsAndEvents,
//     "id": id,
//     "latitude": latitude,
//     "longitude": longitude,
//     "image": image,
//     "hi_city": hiCity,
//     "hi_short_desc": hiShortDesc,
//     "hi_description": hiDescription,
//     "hi_famous_for": hiFamousFor,
//     "hi_festivals_and_events": hiFestivalsAndEvents,
//   };
// }

class CityModel {
  CityModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<City> data;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null
          ? []
          : List<City>.from(json["data"]!.map((x) => City.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $message, $recode, $data, ";
  }
}

class City {
  City({
    required this.enCity,
    required this.hiCity,
    required this.enShortDesc,
    required this.hiShortDesc,
    required this.enDescription,
    required this.hiDescription,
    required this.enFamousFor,
    required this.hiFamousFor,
    required this.enFestivalsAndEvents,
    required this.hiFestivalsAndEvents,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  final String enCity;
  final String hiCity;
  final String enShortDesc;
  final String hiShortDesc;
  final String enDescription;
  final String hiDescription;
  final String enFamousFor;
  final String hiFamousFor;
  final String enFestivalsAndEvents;
  final String hiFestivalsAndEvents;
  final int id;
  final String latitude;
  final String longitude;
  final String image;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      enCity: json["en_city"] ?? "",
      hiCity: json["hi_city"] ?? "",
      enShortDesc: json["en_short_desc"] ?? "",
      hiShortDesc: json["hi_short_desc"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      enFamousFor: json["en_famous_for"] ?? "",
      hiFamousFor: json["hi_famous_for"] ?? "",
      enFestivalsAndEvents: json["en_festivals_and_events"] ?? "",
      hiFestivalsAndEvents: json["hi_festivals_and_events"] ?? "",
      id: json["id"] ?? 0,
      latitude: json["latitude"] ?? "",
      longitude: json["longitude"] ?? "",
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en_city": enCity,
        "hi_city": hiCity,
        "en_short_desc": enShortDesc,
        "hi_short_desc": hiShortDesc,
        "en_description": enDescription,
        "hi_description": hiDescription,
        "en_famous_for": enFamousFor,
        "hi_famous_for": hiFamousFor,
        "en_festivals_and_events": enFestivalsAndEvents,
        "hi_festivals_and_events": hiFestivalsAndEvents,
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "image": image,
      };

  @override
  String toString() {
    return "$enCity, $hiCity, $enShortDesc, $hiShortDesc, $enDescription, $hiDescription, $enFamousFor, $hiFamousFor, $enFestivalsAndEvents, $hiFestivalsAndEvents, $id, $latitude, $longitude, $image, ";
  }
}
