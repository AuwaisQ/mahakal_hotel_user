import 'package:intl/intl.dart';

class SingleDetailsModel {
  SingleDetailsModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final String recode;
  final Data? data;

  factory SingleDetailsModel.fromJson(Map<String, dynamic> json) {
    return SingleDetailsModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.enEventName,
    required this.hiEventName,
    required this.enEventAbout,
    required this.hiEventAbout,
    required this.enEventSchedule,
    required this.hiEventSchedule,
    required this.enEventAttend,
    required this.hiEventAttend,
    required this.enEventTeamCondition,
    required this.hiEventTeamCondition,
    required this.enLanguage,
    required this.hiLanguage,
    required this.id,
    required this.organizerBy,
    required this.ageGroup,
    required this.days,
    required this.startToEndDate,
    required this.eventNextDate,
    required this.youtubeVideo,
    required this.eventInterested,
    required this.informationalStatus,
    required this.auditoramStatus,
    required this.aadharStatus,
    required this.categorys,
    required this.organizers,
    required this.eventImage,
    required this.artist,
    required this.allVenueData,
    required this.images,
    required this.remainingEvent,
    required this.eventInterest,
  });

  final String enEventName;
  final String hiEventName;
  final String enEventAbout;
  final String hiEventAbout;
  final String enEventSchedule;
  final String hiEventSchedule;
  final String enEventAttend;
  final String hiEventAttend;
  final String enEventTeamCondition;
  final String hiEventTeamCondition;
  final String enLanguage;
  final String hiLanguage;
  final dynamic id;
  final String organizerBy;
  final dynamic ageGroup;
  final dynamic days;
  final DateTime? startToEndDate;
  final String eventNextDate;
  final dynamic youtubeVideo;
  final dynamic eventInterested;
  final dynamic informationalStatus;
  final dynamic auditoramStatus;
  final dynamic aadharStatus;
  final Categorys? categorys;
  final Organizers? organizers;
  final String eventImage;
  final Artist? artist;
  final List<EventAllVenueData> allVenueData;
  final List<String> images;
  final List<RemainingEvent> remainingEvent;
  final dynamic eventInterest;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      enEventName: json["en_event_name"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      enEventAbout: json["en_event_about"] ?? "",
      hiEventAbout: json["hi_event_about"] ?? "",
      enEventSchedule: json["en_event_schedule"] ?? "",
      hiEventSchedule: json["hi_event_schedule"] ?? "",
      enEventAttend: json["en_event_attend"] ?? "",
      hiEventAttend: json["hi_event_attend"] ?? "",
      enEventTeamCondition: json["en_event_team_condition"] ?? "",
      hiEventTeamCondition: json["hi_event_team_condition"] ?? "",
      enLanguage: json["en_language"] ?? "",
      hiLanguage: json["hi_language"] ?? "",
      id: json["id"] ?? 0,
      organizerBy: json["organizer_by"] ?? "",
      ageGroup: json["age_group"] ?? "",
      days: json["days"] ?? 0,
      startToEndDate: DateTime.tryParse(json["start_to_end_date"] ?? ""),
      eventNextDate: json["event_next_date"] ?? "",
      youtubeVideo: json["youtube_video"],
      eventInterested: json["event_interested"] ?? 0,
      informationalStatus: json["informational_status"] ?? 0,
      auditoramStatus: json["auditorium_status"] ?? 0,
      aadharStatus: json["aadhar_status"] ?? 0,
      categorys: json["categorys"] == null
          ? null
          : Categorys.fromJson(json["categorys"]),
      organizers: json["organizers"] == null
          ? null
          : Organizers.fromJson(json["organizers"]),
      eventImage: json["event_image"] ?? "",
      artist: json["artist"] == null ? null : Artist.fromJson(json["artist"]),
      allVenueData: json["all_venue_data"] == null
          ? []
          : List<EventAllVenueData>.from(json["all_venue_data"]!
              .map((x) => EventAllVenueData.fromJson(x))),
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x)),
      remainingEvent: json["remaining_event"] == null
          ? []
          : List<RemainingEvent>.from(
              json["remaining_event"]!.map((x) => RemainingEvent.fromJson(x))),
      eventInterest: json["event_interest"] ?? 0,
    );
  }
}

class EventAllVenueData {
  EventAllVenueData({
    required this.id,
    required this.enEventVenue,
    required this.enEventCountry,
    required this.enEventState,
    required this.enEventCities,
    required this.hiEventVenue,
    required this.hiEventCountry,
    required this.hiEventState,
    required this.hiEventCities,
  });

  final int id;
  final String enEventVenue;
  final String enEventCountry;
  final String enEventState;
  final String enEventCities;
  final String hiEventVenue;
  final String hiEventCountry;
  final String hiEventState;
  final String hiEventCities;

  factory EventAllVenueData.fromJson(Map<String, dynamic> json) {
    return EventAllVenueData(
      id: json["id"] ?? 0,
      enEventVenue: json["en_event_venue"] ?? "",
      enEventCountry: json["en_event_country"] ?? "",
      enEventState: json["en_event_state"] ?? "",
      enEventCities: json["en_event_cities"] ?? "",
      hiEventVenue: json["hi_event_venue"] ?? "",
      hiEventCountry: json["hi_event_country"] ?? "",
      hiEventState: json["hi_event_state"] ?? "",
      hiEventCities: json["hi_event_cities"] ?? "",
    );
  }
}

class SinglePackageList {
  SinglePackageList({
    required this.packageName,
    required this.seatsNo,
    required this.priceNo,
    required this.available,
    required this.sold,
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.enDescription,
    required this.hiDescription,
  });

  final String packageName;
  final dynamic seatsNo;
  final dynamic priceNo;
  final dynamic available;
  final dynamic sold;
  final dynamic packageId;
  final String enPackageName;
  final String hiPackageName;
  final String enDescription;
  final String hiDescription;

  factory SinglePackageList.fromJson(Map<String, dynamic> json) {
    return SinglePackageList(
      packageName: json["package_name"] ?? "",
      seatsNo: json["seats_no"] ?? "",
      priceNo: json["price"] ?? "",
      available: json["available"] ?? 0,
      sold: json["sold"] ?? 0,
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
    );
  }
}

class Artist {
  Artist({
    required this.id,
    required this.enArtistName,
    required this.hiArtistName,
    required this.enDescription,
    required this.hiDescription,
    required this.enProfession,
    required this.hiProfession,
    required this.image,
  });

  final dynamic id;
  final String enArtistName;
  final String hiArtistName;
  final String enDescription;
  final String hiDescription;
  final String enProfession;
  final String hiProfession;
  final String image;

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json["id"] ?? 0,
      enArtistName: json["en_artist_name"] ?? "",
      hiArtistName: json["hi_artist_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      enProfession: json["en_profession"] ?? "",
      hiProfession: json["hi_profession"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class Categorys {
  Categorys({
    required this.id,
    required this.enCategoryName,
    required this.hiCategoryName,
    required this.image,
  });

  final dynamic id;
  final String enCategoryName;
  final String hiCategoryName;
  final String image;

  factory Categorys.fromJson(Map<String, dynamic> json) {
    return Categorys(
      id: json["id"] ?? 0,
      enCategoryName: json["en_category_name"] ?? "",
      hiCategoryName: json["hi_category_name"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class Organizers {
  Organizers({
    required this.enOrganizerName,
    required this.hiOrganizerName,
    required this.id,
    required this.fullName,
    required this.emailAddress,
    required this.contactNumber,
    required this.image,
  });

  final String enOrganizerName;
  final String hiOrganizerName;
  final dynamic id;
  final String fullName;
  final String emailAddress;
  final String contactNumber;
  final String image;

  factory Organizers.fromJson(Map<String, dynamic> json) {
    return Organizers(
      enOrganizerName: json["en_organizer_name"] ?? "",
      hiOrganizerName: json["hi_organizer_name"] ?? "",
      id: json["id"] ?? 0,
      fullName: json["full_name"] ?? "",
      emailAddress: json["email_address"] ?? "",
      contactNumber: json["contact_number"] ?? "",
      image: json["image"] ?? "",
    );
  }
}

class RemainingEvent {
  RemainingEvent({
    required this.id,
    required this.enEventName,
    required this.informationalStatus,
    required this.startToEndDate,
    required this.eventImage,
    required this.eventOrderReviewCount,
    required this.reviewAvgStar,
    required this.hiEventName,
    required this.venueData,
    required this.categorys,
  });

  final dynamic id;
  final String enEventName;
  final dynamic informationalStatus;
  final String startToEndDate;
  final String eventImage;
  final dynamic eventOrderReviewCount;
  final dynamic reviewAvgStar;
  final String hiEventName;
  final List<VenueDataClass> venueData;
  final dynamic categorys;

  factory RemainingEvent.fromJson(Map<String, dynamic> json) {
    return RemainingEvent(
      id: json["id"] ?? 0,
      enEventName: json["en_event_name"] ?? "",
      informationalStatus: json["informational_status"] ?? 0,
      startToEndDate: json["start_to_end_date"] ?? "",
      eventImage: json["event_image"] ?? "",
      eventOrderReviewCount: json["event_order_review_count"] ?? 0,
      reviewAvgStar: json["review_avg_star"] ?? 0,
      hiEventName: json["hi_event_name"] ?? "",
      venueData: json["venue_data"] == null
          ? []
          : List<VenueDataClass>.from(
              json["venue_data"]!.map((x) => VenueDataClass.fromJson(x))),
      categorys: json["categorys"],
    );
  }
}

class VenueDataClass {
  VenueDataClass({
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
  final List<VenueDatumPackageList> packageList;
  final String hiEventVenue;
  final String hiEventVenueFullAddress;
  final String hiEventCountry;
  final String hiEventState;
  final String hiEventCities;
  final String hiEventLat;
  final String hiEventLong;
  final dynamic id;

  factory VenueDataClass.fromJson(Map<String, dynamic> json) {
    return VenueDataClass(
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
          : List<VenueDatumPackageList>.from(json["package_list"]!
              .map((x) => VenueDatumPackageList.fromJson(x))),
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

class VenueDatumPackageList {
  VenueDatumPackageList({
    required this.packageName,
    required this.seatsNo,
    required this.priceNo,
    required this.available,
    required this.sold,
  });

  final String packageName;
  final dynamic seatsNo;
  final dynamic priceNo;
  final dynamic available;
  final dynamic sold;

  factory VenueDatumPackageList.fromJson(Map<String, dynamic> json) {
    return VenueDatumPackageList(
      packageName: json["package_name"] ?? "",
      seatsNo: json["seats_no"] ?? "",
      priceNo: json["price_no"] ?? "",
      available: json["available"] ?? 0,
      sold: json["sold"] ?? 0,
    );
  }
}
