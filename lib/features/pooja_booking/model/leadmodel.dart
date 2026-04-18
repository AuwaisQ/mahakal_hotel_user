// // To parse this JSON data, do
// //
// //     final leadModel = leadModelFromJson(jsonString);
//
// import 'dart:convert';
//
// LeadModel leadModelFromJson(String str) => LeadModel.fromJson(json.decode(str));
//
// String leadModelToJson(LeadModel data) => json.encode(data.toJson());
//
// class LeadModel {
//   bool success;
//   String message;
//   Lead lead;
//
//   LeadModel({
//     required this.success,
//     required this.message,
//     required this.lead,
//   });
//
//   factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
//     success: json["success"],
//     message: json["message"],
//     lead: Lead.fromJson(json["lead"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "message": message,
//     "lead": lead.toJson(),
//   };
// }
//
// class Lead {
//   int serviceId;
//   String type;
//   int packageId;
//   String productId;
//   String packageName;
//   String packagePrice;
//   String noperson;
//   String personPhone;
//   String personName;
//   DateTime bookingDate;
//   DateTime updatedAt;
//   DateTime createdAt;
//   int id;
//
//   Lead({
//     required this.serviceId,
//     required this.type,
//     required this.packageId,
//     required this.productId,
//     required this.packageName,
//     required this.packagePrice,
//     required this.noperson,
//     required this.personPhone,
//     required this.personName,
//     required this.bookingDate,
//     required this.updatedAt,
//     required this.createdAt,
//     required this.id,
//   });
//
//   factory Lead.fromJson(Map<String, dynamic> json) => Lead(
//     serviceId: json["service_id"],
//     type: json["type"],
//     packageId: json["package_id"],
//     productId: json["product_id"],
//     packageName: json["package_name"],
//     packagePrice: json["package_price"],
//     noperson: json["noperson"],
//     personPhone: json["person_phone"],
//     personName: json["person_name"],
//     bookingDate: DateTime.parse(json["booking_date"]),
//     updatedAt: DateTime.parse(json["updated_at"]),
//     createdAt: DateTime.parse(json["created_at"]),
//     id: json["id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "service_id": serviceId,
//     "type": type,
//     "package_id": packageId,
//     "product_id": productId,
//     "package_name": packageName,
//     "package_price": packagePrice,
//     "noperson": noperson,
//     "person_phone": personPhone,
//     "person_name": personName,
//     "booking_date": bookingDate.toIso8601String(),
//     "updated_at": updatedAt.toIso8601String(),
//     "created_at": createdAt.toIso8601String(),
//     "id": id,
//   };
// }
