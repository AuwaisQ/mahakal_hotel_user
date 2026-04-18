// To parse this JSON data, do
//
//     final hotelModel = hotelModelFromJson(jsonString);

import 'dart:convert';

HotelModel hotelModelFromJson(String str) =>
    HotelModel.fromJson(json.decode(str));

String hotelModelToJson(HotelModel data) => json.encode(data.toJson());

class HotelModel {
  int status;
  String message;
  int recode;
  List<Hotel> hotel;

  HotelModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.hotel,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        hotel: List<Hotel>.from(json["hotel"].map((x) => Hotel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "hotel": List<dynamic>.from(hotel.map((x) => x.toJson())),
      };
}

class Hotel {
  String enHotelName;
  String enDescription;
  String enAmenities;
  String enRoomAmenities;
  String enRoomTypes;
  String enBookingInformation;
  int id;
  String latitude;
  String longitude;
  int zipcode;
  int phoneNo;
  String emailId;
  String websiteLink;
  String image;
  String hiHotelName;
  String hiDescription;
  String hiAmenities;
  String hiRoomAmenities;
  String hiRoomTypes;
  String hiBookingInformation;

  Hotel({
    required this.enHotelName,
    required this.enDescription,
    required this.enAmenities,
    required this.enRoomAmenities,
    required this.enRoomTypes,
    required this.enBookingInformation,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.zipcode,
    required this.phoneNo,
    required this.emailId,
    required this.websiteLink,
    required this.image,
    required this.hiHotelName,
    required this.hiDescription,
    required this.hiAmenities,
    required this.hiRoomAmenities,
    required this.hiRoomTypes,
    required this.hiBookingInformation,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
        enHotelName: json["en_hotel_name"],
        enDescription: json["en_description"],
        enAmenities: json["en_amenities"],
        enRoomAmenities: json["en_room_amenities"],
        enRoomTypes: json["en_room_types"],
        enBookingInformation: json["en_booking_information"],
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        zipcode: json["zipcode"],
        phoneNo: json["phone_no"],
        emailId: json["email_id"],
        websiteLink: json["website_link"],
        image: json["image"],
        hiHotelName: json["hi_hotel_name"],
        hiDescription: json["hi_description"],
        hiAmenities: json["hi_amenities"],
        hiRoomAmenities: json["hi_room_amenities"],
        hiRoomTypes: json["hi_room_types"],
        hiBookingInformation: json["hi_booking_information"],
      );

  Map<String, dynamic> toJson() => {
        "en_hotel_name": enHotelName,
        "en_description": enDescription,
        "en_amenities": enAmenities,
        "en_room_amenities": enRoomAmenities,
        "en_room_types": enRoomTypes,
        "en_booking_information": enBookingInformation,
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "zipcode": zipcode,
        "phone_no": phoneNo,
        "email_id": emailId,
        "website_link": websiteLink,
        "image": image,
        "hi_hotel_name": hiHotelName,
        "hi_description": hiDescription,
        "hi_amenities": hiAmenities,
        "hi_room_amenities": hiRoomAmenities,
        "hi_room_types": hiRoomTypes,
        "hi_booking_information": hiBookingInformation,
      };
}
