// import 'dart:convert';
//
// TravellersModel travellersModelFromJson(String str) =>
//     TravellersModel.fromJson(json.decode(str));
//
// String travellersModelToJson(TravellersModel data) =>
//     json.encode(data.toJson());
//
// class TravellersModel {
//   int status;
//   int count;
//   TravellerData data;
//
//   TravellersModel({
//     required this.status,
//     required this.count,
//     required this.data,
//   });
//
//   factory TravellersModel.fromJson(Map<String, dynamic> json) =>
//       TravellersModel(
//         status: json["status"],
//         count: json["count"],
//         data: TravellerData.fromJson(json["data"]),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "count": count,
//         "data": data.toJson(),
//       };
// }
//
// class TravellerData {
//   int id;
//   String enOwnerName;
//   String hiOwnerName;
//   String enCompanyName;
//   String hiCompanyName;
//   String image;
//
//   TravellerData({
//     required this.id,
//     required this.enOwnerName,
//     required this.hiOwnerName,
//     required this.enCompanyName,
//     required this.hiCompanyName,
//     required this.image,
//   });
//
//   factory TravellerData.fromJson(Map<String, dynamic> json) => TravellerData(
//         id: json["id"],
//         enOwnerName: json["en_owner_name"],
//         hiOwnerName: json["hi_owner_name"],
//         enCompanyName: json["en_company_name"],
//         hiCompanyName: json["hi_company_name"],
//         image: json["image"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "en_owner_name": enOwnerName,
//         "hi_owner_name": hiOwnerName,
//         "en_company_name": enCompanyName,
//         "hi_company_name": hiCompanyName,
//         "image": image,
//       };
// }
//

class TravellersModel {
  TravellersModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final TravellerData? data;

  factory TravellersModel.fromJson(Map<String, dynamic> json) {
    return TravellersModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null ? null : TravellerData.fromJson(json["data"]),
    );
  }
}

class TravellerData {
  TravellerData({
    required this.id,
    required this.enOwnerName,
    required this.hiOwnerName,
    required this.enCompanyName,
    required this.hiCompanyName,
    required this.experience,
    required this.rating,
    required this.verifiedStatus,
    required this.gstNo,
    required this.image,
  });

  final int id;
  final String enOwnerName;
  final String hiOwnerName;
  final String enCompanyName;
  final String hiCompanyName;
  final int experience;
  final int rating;
  final int verifiedStatus;
  final String gstNo;
  final String image;

  factory TravellerData.fromJson(Map<String, dynamic> json) {
    return TravellerData(
      id: json["id"] ?? 0,
      enOwnerName: json["en_owner_name"] ?? "",
      hiOwnerName: json["hi_owner_name"] ?? "",
      enCompanyName: json["en_company_name"] ?? "",
      hiCompanyName: json["hi_company_name"] ?? "",
      experience: json["experience"] ?? 0,
      rating: json["rating"] ?? 0,
      verifiedStatus: json["verified_status"] ?? 0,
      gstNo: json["gst_no"] ?? "",
      image: json["image"] ?? "",
    );
  }
}
