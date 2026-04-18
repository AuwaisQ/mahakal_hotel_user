// class SubCategoryModel {
//   SubCategoryModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.data,
//   });
//
//   final int status;
//   final String message;
//   final int recode;
//   final List<SubData> data;
//
//   factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
//     return SubCategoryModel(
//       status: json["status"] ?? 0,
//       message: json["message"] ?? "",
//       recode: json["recode"] ?? 0,
//       data: json["data"] == null
//           ? []
//           : List<SubData>.from(json["data"]!.map((x) => SubData.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "recode": recode,
//         "data": data.map((x) => x.toJson()).toList(),
//       };
//
//   @override
//   String toString() {
//     return "$status, $message, $recode, $data, ";
//   }
// }
//
// class SubData {
//   SubData({
//     required this.enEventName,
//     required this.enEventAbout,
//     required this.enEventSchedule,
//     required this.enEventAttend,
//     required this.enEventTeamCondition,
//     required this.hiEventName,
//     required this.hiEventAbout,
//     required this.hiEventSchedule,
//     required this.hiEventAttend,
//     required this.hiEventTeamCondition,
//     required this.id,
//     required this.organizerBy,
//     required this.ageGroup,
//     required this.language,
//     required this.days,
//     required this.startToEndDate,
//     required this.youtubeVideo,
//     required this.allVenueData,
//     required this.eventImage,
//     required this.images,
//   });
//
//   final String enEventName;
//   final String enEventAbout;
//   final String enEventSchedule;
//   final String enEventAttend;
//   final String enEventTeamCondition;
//   final String hiEventName;
//   final String hiEventAbout;
//   final String hiEventSchedule;
//   final String hiEventAttend;
//   final String hiEventTeamCondition;
//   final int id;
//   final String organizerBy;
//   final String ageGroup;
//   final String language;
//   final int days;
//   final String startToEndDate;
//   final String youtubeVideo;
//   final List<AllVenueDatum> allVenueData;
//   final String eventImage;
//   final List<String> images;
//
//   factory SubData.fromJson(Map<String, dynamic> json) {
//     return SubData(
//       enEventName: json["en_event_name"] ?? "",
//       enEventAbout: json["en_event_about"] ?? "",
//       enEventSchedule: json["en_event_schedule"] ?? "",
//       enEventAttend: json["en_event_attend"] ?? "",
//       enEventTeamCondition: json["en_event_team_condition"] ?? "",
//       hiEventName: json["hi_event_name"] ?? "",
//       hiEventAbout: json["hi_event_about"] ?? "",
//       hiEventSchedule: json["hi_event_schedule"] ?? "",
//       hiEventAttend: json["hi_event_attend"] ?? "",
//       hiEventTeamCondition: json["hi_event_team_condition"] ?? "",
//       id: json["id"] ?? 0,
//       organizerBy: json["organizer_by"] ?? "",
//       ageGroup: json["age_group"] ?? "",
//       language: json["language"] ?? "",
//       days: json["days"] ?? 0,
//       startToEndDate: json["start_to_end_date"] ?? "",
//       youtubeVideo: json["youtube_video"] ?? "",
//       allVenueData: json["all_venue_data"] == null
//           ? []
//           : List<AllVenueDatum>.from(
//               json["all_venue_data"]!.map((x) => AllVenueDatum.fromJson(x))),
//       eventImage: json["event_image"] ?? "",
//       images: json["images"] == null
//           ? []
//           : List<String>.from(json["images"]!.map((x) => x)),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "en_event_name": enEventName,
//         "en_event_about": enEventAbout,
//         "en_event_schedule": enEventSchedule,
//         "en_event_attend": enEventAttend,
//         "en_event_team_condition": enEventTeamCondition,
//         "hi_event_name": hiEventName,
//         "hi_event_about": hiEventAbout,
//         "hi_event_schedule": hiEventSchedule,
//         "hi_event_attend": hiEventAttend,
//         "hi_event_team_condition": hiEventTeamCondition,
//         "id": id,
//         "organizer_by": organizerBy,
//         "age_group": ageGroup,
//         "language": language,
//         "days": days,
//         "start_to_end_date": startToEndDate,
//         "youtube_video": youtubeVideo,
//         "all_venue_data": allVenueData.map((x) => x.toJson()).toList(),
//         "event_image": eventImage,
//         "images": images.map((x) => x).toList(),
//       };
//
//   @override
//   String toString() {
//     return "$enEventName, $enEventAbout, $enEventSchedule, $enEventAttend, $enEventTeamCondition, $hiEventName, $hiEventAbout, $hiEventSchedule, $hiEventAttend, $hiEventTeamCondition, $id, $organizerBy, $ageGroup, $language, $days, $startToEndDate, $youtubeVideo, $allVenueData, $eventImage, $images, ";
//   }
// }
//
// class AllVenueDatum {
//   AllVenueDatum({
//     required this.enEventVenue,
//     required this.enEventVenueFullAddress,
//     required this.enEventCountry,
//     required this.enEventState,
//     required this.enEventCities,
//     required this.enEventLat,
//     required this.enEventLong,
//     required this.date,
//     required this.startTime,
//     required this.endTime,
//     required this.eventDuration,
//     required this.packageList,
//     required this.hiEventVenue,
//     required this.hiEventVenueFullAddress,
//     required this.hiEventCountry,
//     required this.hiEventState,
//     required this.hiEventCities,
//     required this.hiEventLat,
//     required this.hiEventLong,
//     required this.id,
//   });
//
//   final String enEventVenue;
//   final String enEventVenueFullAddress;
//   final String enEventCountry;
//   final String enEventState;
//   final String enEventCities;
//   final String enEventLat;
//   final String enEventLong;
//   final DateTime? date;
//   final String startTime;
//   final String endTime;
//   final String eventDuration;
//   final List<PackageList> packageList;
//   final String hiEventVenue;
//   final String hiEventVenueFullAddress;
//   final String hiEventCountry;
//   final String hiEventState;
//   final String hiEventCities;
//   final String hiEventLat;
//   final String hiEventLong;
//   final int id;
//
//   factory AllVenueDatum.fromJson(Map<String, dynamic> json) {
//     return AllVenueDatum(
//       enEventVenue: json["en_event_venue"] ?? "",
//       enEventVenueFullAddress: json["en_event_venue_full_address"] ?? "",
//       enEventCountry: json["en_event_country"] ?? "",
//       enEventState: json["en_event_state"] ?? "",
//       enEventCities: json["en_event_cities"] ?? "",
//       enEventLat: json["en_event_lat"] ?? "",
//       enEventLong: json["en_event_long"] ?? "",
//       date: DateTime.tryParse(json["date"] ?? ""),
//       startTime: json["start_time"] ?? "",
//       endTime: json["end_time"] ?? "",
//       eventDuration: json["event_duration"] ?? "",
//       packageList: json["package_list"] == null
//           ? []
//           : List<PackageList>.from(
//               json["package_list"]!.map((x) => PackageList.fromJson(x))),
//       hiEventVenue: json["hi_event_venue"] ?? "",
//       hiEventVenueFullAddress: json["hi_event_venue_full_address"] ?? "",
//       hiEventCountry: json["hi_event_country"] ?? "",
//       hiEventState: json["hi_event_state"] ?? "",
//       hiEventCities: json["hi_event_cities"] ?? "",
//       hiEventLat: json["hi_event_lat"] ?? "",
//       hiEventLong: json["hi_event_long"] ?? "",
//       id: json["id"] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "en_event_venue": enEventVenue,
//         "en_event_venue_full_address": enEventVenueFullAddress,
//         "en_event_country": enEventCountry,
//         "en_event_state": enEventState,
//         "en_event_cities": enEventCities,
//         "en_event_lat": enEventLat,
//         "en_event_long": enEventLong,
//         "date":
//             "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
//         "start_time": startTime,
//         "end_time": endTime,
//         "event_duration": eventDuration,
//         "package_list": packageList.map((x) => x.toJson()).toList(),
//         "hi_event_venue": hiEventVenue,
//         "hi_event_venue_full_address": hiEventVenueFullAddress,
//         "hi_event_country": hiEventCountry,
//         "hi_event_state": hiEventState,
//         "hi_event_cities": hiEventCities,
//         "hi_event_lat": hiEventLat,
//         "hi_event_long": hiEventLong,
//         "id": id,
//       };
//
//   @override
//   String toString() {
//     return "$enEventVenue, $enEventVenueFullAddress, $enEventCountry, $enEventState, $enEventCities, $enEventLat, $enEventLong, $date, $startTime, $endTime, $eventDuration, $packageList, $hiEventVenue, $hiEventVenueFullAddress, $hiEventCountry, $hiEventState, $hiEventCities, $hiEventLat, $hiEventLong, $id, ";
//   }
// }
//
// class PackageList {
//   PackageList({
//     required this.packageName,
//     required this.seatsNo,
//     required this.priceNo,
//     required this.available,
//     required this.sold,
//     required this.packageId,
//     required this.enPackageName,
//     required this.hiPackageName,
//   });
//
//   final String packageName;
//   final String seatsNo;
//   final String priceNo;
//   final dynamic available;
//   final int sold;
//   final String packageId;
//   final String enPackageName;
//   final String hiPackageName;
//
//   factory PackageList.fromJson(Map<String, dynamic> json) {
//     return PackageList(
//       packageName: json["package_name"] ?? "",
//       seatsNo: json["seats_no"] ?? "",
//       priceNo: json["price_no"] ?? "",
//       available: json["available"] ?? 0,
//       sold: json["sold"] ?? 0,
//       packageId: json["package_id"] ?? "",
//       enPackageName: json["en_package_name"] ?? "",
//       hiPackageName: json["hi_package_name"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "package_name": packageName,
//         "seats_no": seatsNo,
//         "price_no": priceNo,
//         "available": available,
//         "sold": sold,
//         "package_id": packageId,
//         "en_package_name": enPackageName,
//         "hi_package_name": hiPackageName,
//       };
//
//   @override
//   String toString() {
//     return "$packageName, $seatsNo, $priceNo, $available, $sold, $packageId, $enPackageName, $hiPackageName, ";
//   }
// }

class SubCategoryModel {
  SubCategoryModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<SubData> data;

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null
          ? []
          : List<SubData>.from(json["data"]!.map((x) => SubData.fromJson(x))),
    );
  }
}

class SubData {
  SubData({
    required this.enEventName,
    required this.enEventAbout,
    required this.enEventSchedule,
    required this.enEventAttend,
    required this.enEventTeamCondition,
    required this.hiEventName,
    required this.hiEventAbout,
    required this.hiEventSchedule,
    required this.hiEventAttend,
    required this.hiEventTeamCondition,
    required this.id,
    required this.organizerBy,
    required this.ageGroup,
    required this.reviewCount,
    required this.reviewAvgStar,
    required this.language,
    required this.days,
    required this.startToEndDate,
    required this.eventDates,
    required this.formattedDate,
    required this.informationalStatus,
    required this.youtubeVideo,
    required this.allVenueData,
    required this.eventImage,
    required this.images,
  });

  final String enEventName;
  final String enEventAbout;
  final String enEventSchedule;
  final String enEventAttend;
  final String enEventTeamCondition;
  final String hiEventName;
  final String hiEventAbout;
  final String hiEventSchedule;
  final String hiEventAttend;
  final String hiEventTeamCondition;
  final int id;
  final String organizerBy;
  final String ageGroup;
  final String reviewCount;
  final String reviewAvgStar;
  final String language;
  final int days;
  final String startToEndDate;
  final DateTime? eventDates;
  final String formattedDate;
  final int informationalStatus;
  final dynamic youtubeVideo;
  final List<AllVenueDatum> allVenueData;
  final String eventImage;
  final List<String> images;

  factory SubData.fromJson(Map<String, dynamic> json) {
    return SubData(
      enEventName: json["en_event_name"] ?? "",
      enEventAbout: json["en_event_about"] ?? "",
      enEventSchedule: json["en_event_schedule"] ?? "",
      enEventAttend: json["en_event_attend"] ?? "",
      enEventTeamCondition: json["en_event_team_condition"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      hiEventAbout: json["hi_event_about"] ?? "",
      hiEventSchedule: json["hi_event_schedule"] ?? "",
      hiEventAttend: json["hi_event_attend"] ?? "",
      hiEventTeamCondition: json["hi_event_team_condition"] ?? "",
      id: json["id"] ?? 0,
      organizerBy: json["organizer_by"] ?? "",
      ageGroup: json["age_group"] ?? "",
      reviewCount: json["review_count"] ?? "",
      reviewAvgStar: json["review_avg_star"] ?? "",
      language: json["language"] ?? "",
      days: json["days"] ?? 0,
      startToEndDate: json["start_to_end_date"] ?? "",
      eventDates: DateTime.tryParse(json["event_dates"] ?? ""),
      formattedDate: json["formatted_date"] ?? "",
      informationalStatus: json["informational_status"] ?? 0,
      youtubeVideo: json["youtube_video"],
      allVenueData: json["all_venue_data"] == null
          ? []
          : List<AllVenueDatum>.from(
              json["all_venue_data"]!.map((x) => AllVenueDatum.fromJson(x))),
      eventImage: json["event_image"] ?? "",
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x)),
    );
  }
}

class AllVenueDatum {
  AllVenueDatum({
    required this.enEventVenue,
    required this.enEventVenueFullAddress,
    required this.enEventCountry,
    required this.enEventState,
    required this.enEventCities,
    required this.enEventLat,
    required this.enEventLong,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.eventDuration,
    required this.packageList,
    required this.hiEventVenue,
    required this.hiEventVenueFullAddress,
    required this.hiEventCountry,
    required this.hiEventState,
    required this.hiEventCities,
    required this.hiEventLat,
    required this.hiEventLong,
    required this.id,
  });

  final String enEventVenue;
  final String enEventVenueFullAddress;
  final String enEventCountry;
  final String enEventState;
  final String enEventCities;
  final String enEventLat;
  final String enEventLong;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final String eventDuration;
  final List<PackageList> packageList;
  final String hiEventVenue;
  final String hiEventVenueFullAddress;
  final String hiEventCountry;
  final String hiEventState;
  final String hiEventCities;
  final String hiEventLat;
  final String hiEventLong;
  final int id;

  factory AllVenueDatum.fromJson(Map<String, dynamic> json) {
    return AllVenueDatum(
      enEventVenue: json["en_event_venue"] ?? "",
      enEventVenueFullAddress: json["en_event_venue_full_address"] ?? "",
      enEventCountry: json["en_event_country"] ?? "",
      enEventState: json["en_event_state"] ?? "",
      enEventCities: json["en_event_cities"] ?? "",
      enEventLat: json["en_event_lat"] ?? "",
      enEventLong: json["en_event_long"] ?? "",
      date: DateTime.tryParse(json["date"] ?? ""),
      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
      eventDuration: json["event_duration"] ?? "",
      packageList: json["package_list"] == null
          ? []
          : List<PackageList>.from(
              json["package_list"]!.map((x) => PackageList.fromJson(x))),
      hiEventVenue: json["hi_event_venue"] ?? "",
      hiEventVenueFullAddress: json["hi_event_venue_full_address"] ?? "",
      hiEventCountry: json["hi_event_country"] ?? "",
      hiEventState: json["hi_event_state"] ?? "",
      hiEventCities: json["hi_event_cities"] ?? "",
      hiEventLat: json["hi_event_lat"] ?? "",
      hiEventLong: json["hi_event_long"] ?? "",
      id: json["id"] ?? 0,
    );
  }
}

class PackageList {
  PackageList({
    required this.packageName,
    required this.seatsNo,
    required this.priceNo,
    required this.available,
    required this.sold,
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
  });

  final String packageName;
  final String seatsNo;
  final String priceNo;
  final dynamic available;
  final int sold;
  final String packageId;
  final String enPackageName;
  final String hiPackageName;

  factory PackageList.fromJson(Map<String, dynamic> json) {
    return PackageList(
      packageName: json["package_name"] ?? "",
      seatsNo: json["seats_no"] ?? "",
      priceNo: json["price_no"] ?? "",
      available: json["available"],
      sold: json["sold"] ?? 0,
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
    );
  }
}
