// To parse this JSON data, do
//
//     final mahaVimshottariModel = mahaVimshottariModelFromJson(jsonString);

import 'dart:convert';

MahaVimshottariModel mahaVimshottariModelFromJson(String str) =>
    MahaVimshottariModel.fromJson(json.decode(str));

String mahaVimshottariModelToJson(MahaVimshottariModel data) =>
    json.encode(data.toJson());

class MahaVimshottariModel {
  int status;
  List<MahaVimshottari> mahaVimshottari;

  MahaVimshottariModel({
    required this.status,
    required this.mahaVimshottari,
  });

  factory MahaVimshottariModel.fromJson(Map<String, dynamic> json) =>
      MahaVimshottariModel(
        status: json["status"],
        mahaVimshottari: List<MahaVimshottari>.from(
            json["mahaVimshottari"].map((x) => MahaVimshottari.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "mahaVimshottari":
            List<dynamic>.from(mahaVimshottari.map((x) => x.toJson())),
      };
}

class MahaVimshottari {
  String planet;
  int planetId;
  String start;
  String end;

  MahaVimshottari({
    required this.planet,
    required this.planetId,
    required this.start,
    required this.end,
  });

  factory MahaVimshottari.fromJson(Map<String, dynamic> json) =>
      MahaVimshottari(
        planet: json["planet"],
        planetId: json["planet_id"],
        start: json["start"],
        end: json["end"],
      );

  Map<String, dynamic> toJson() => {
        "planet": planet,
        "planet_id": planetId,
        "start": start,
        "end": end,
      };
}
