// // To parse this JSON data, do
// //
// //     final mandirModel = mandirModelFromJson(jsonString);
//
// import 'dart:convert';
//
// MandirModel mandirModelFromJson(String str) => MandirModel.fromJson(json.decode(str));
//
// String mandirModelToJson(MandirModel data) => json.encode(data.toJson());
//
// class MandirModel {
//   int status;
//   List<MandirData> data;
//
//   MandirModel({
//     required this.status,
//     required this.data,
//   });
//
//   factory MandirModel.fromJson(Map<String, dynamic> json) => MandirModel(
//     status: json["status"],
//     data: List<MandirData>.from(json["data"].map((x) => MandirData.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// class MandirData {
//   int id;
//   String enName;
//   String hiName;
//   String thumbnail;
//   List<String> images;
//   String week;
//   DateTime? date;
//   dynamic eventImage;
//
//   MandirData({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.thumbnail,
//     required this.images,
//     required this.week,
//     required this.date,
//     required this.eventImage,
//   });
//
//   factory MandirData.fromJson(Map<String, dynamic> json) => MandirData(
//     id: json["id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     thumbnail: json["thumbnail"],
//     images: List<String>.from(json["images"].map((x) => x)),
//     week: json["week"],
//     date: json["date"] == null ? null : DateTime.parse(json["date"]),
//     eventImage: json["event_image"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "thumbnail": thumbnail,
//     "images": List<dynamic>.from(images.map((x) => x)),
//     "week": week,
//     "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
//     "event_image": eventImage,
//   };
// }

class MandirModel {
  MandirModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<MandirData> data;

  factory MandirModel.fromJson(Map<String, dynamic> json) {
    return MandirModel(
      status: json["status"] ?? 0,
      data: json["data"] == null
          ? []
          : List<MandirData>.from(
              json["data"]!.map((x) => MandirData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $data, ";
  }
}

class MandirData {
  MandirData({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.thumbnail,
    required this.images,
    required this.week,
    required this.date,
    required this.eventImage,
  });

  final int id;
  final String enName;
  final String hiName;
  final String thumbnail;
  final List<String> images;
  final String week;
  final dynamic date;
  final dynamic eventImage;

  factory MandirData.fromJson(Map<String, dynamic> json) {
    return MandirData(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x)),
      week: json["week"] ?? "",
      date: json["date"],
      eventImage: json["event_image"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "thumbnail": thumbnail,
        "images": images.map((x) => x).toList(),
        "week": week,
        "date": date,
        "event_image": eventImage,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $thumbnail, $images, $week, $date, $eventImage, ";
  }
}
