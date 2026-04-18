// // To parse this JSON data, do
// //
// //     final cityReviewModel = cityReviewModelFromJson(jsonString);
//
// import 'dart:convert';
//
// CityReviewModel cityReviewModelFromJson(String str) => CityReviewModel.fromJson(json.decode(str));
//
// String cityReviewModelToJson(CityReviewModel data) => json.encode(data.toJson());
//
// class CityReviewModel {
//   int status;
//   String message;
//   double citiesStar;
//   int recode;
//   List<Cityreview> cityreview;
//
//   CityReviewModel({
//     required this.status,
//     required this.message,
//     required this.citiesStar,
//     required this.recode,
//     required this.cityreview,
//   });
//
//   factory CityReviewModel.fromJson(Map<String, dynamic> json) => CityReviewModel(
//     status: json["status"],
//     message: json["message"],
//     citiesStar: json["cities_star"]?.toDouble(),
//     recode: json["recode"],
//     cityreview: List<Cityreview>.from(json["cityreview"].map((x) => Cityreview.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "cities_star": citiesStar,
//     "recode": recode,
//     "cityreview": List<dynamic>.from(cityreview.map((x) => x.toJson())),
//   };
// }
//
// class Cityreview {
//   String? userName;
//   int userId;
//   String userImage;
//   String comment;
//   int star;
//   DateTime createdAt;
//
//   Cityreview({
//     required this.userName,
//     required this.userId,
//     required this.userImage,
//     required this.comment,
//     required this.star,
//     required this.createdAt,
//   });
//
//   factory Cityreview.fromJson(Map<String, dynamic> json) => Cityreview(
//     userName: json["user_name"],
//     userId: json["user_id"],
//     userImage: json["user_image"],
//     comment: json["comment"],
//     star: json["star"],
//     createdAt: DateTime.parse(json["created_at"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "user_name": userName,
//     "user_id": userId,
//     "user_image": userImage,
//     "comment": comment,
//     "star": star,
//     "created_at": createdAt.toIso8601String(),
//   };
// }

class CityReviewModel {
  CityReviewModel({
    required this.status,
    required this.message,
    required this.citiesStar,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final double citiesStar;
  final int recode;
  final List<Cityreview> data;

  factory CityReviewModel.fromJson(Map<String, dynamic> json) {
    return CityReviewModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      citiesStar: json["cities_star"] ?? 0.0,
      recode: json["recode"] ?? 0,
      data: json["data"] == null
          ? []
          : List<Cityreview>.from(
              json["data"]!.map((x) => Cityreview.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "cities_star": citiesStar,
        "recode": recode,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $message, $citiesStar, $recode, $data, ";
  }
}

class Cityreview {
  Cityreview({
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.comment,
    required this.star,
    required this.createdAt,
  });

  final String userName;
  final int userId;
  final String userImage;
  final String comment;
  final int star;
  final DateTime? createdAt;

  factory Cityreview.fromJson(Map<String, dynamic> json) {
    return Cityreview(
      userName: json["user_name"] ?? "",
      userId: json["user_id"] ?? 0,
      userImage: json["user_image"] ?? "",
      comment: json["comment"] ?? "",
      star: json["star"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "user_id": userId,
        "user_image": userImage,
        "comment": comment,
        "star": star,
        "created_at": createdAt?.toIso8601String(),
      };

  @override
  String toString() {
    return "$userName, $userId, $userImage, $comment, $star, $createdAt, ";
  }
}
