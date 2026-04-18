class ActivityDetailsModel {
  ActivityDetailsModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final String recode;
  final Data? data;

  factory ActivityDetailsModel.fromJson(Map<String, dynamic> json){
    return ActivityDetailsModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data?.toJson(),
  };

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
    required this.youtubeVideo,
    required this.eventInterested,
    required this.informationalStatus,
    required this.aadharStatus,
    required this.percentageOff,
    required this.categorys,
    required this.organizers,
    required this.eventImage,
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
  final int id;
  final String organizerBy;
  final String ageGroup;
  final int days;
  final String youtubeVideo;
  final int eventInterested;
  final int informationalStatus;
  final int aadharStatus;
  final int percentageOff;
  final Categorys? categorys;
  final Organizers? organizers;
  final String eventImage;
  final List<AllVenueDatum> allVenueData;
  final List<String> images;
  final List<RemainingEvent> remainingEvent;
  final int eventInterest;

  factory Data.fromJson(Map<String, dynamic> json){
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
      youtubeVideo: json["youtube_video"] ?? "",
      eventInterested: json["event_interested"] ?? 0,
      informationalStatus: json["informational_status"] ?? 0,
      aadharStatus: json["aadhar_status"] ?? 0,
      percentageOff: json["percentage_off"] ?? 0,
      categorys: json["categorys"] == null ? null : Categorys.fromJson(json["categorys"]),
      organizers: json["organizers"] == null ? null : Organizers.fromJson(json["organizers"]),
      eventImage: json["event_image"] ?? "",
      allVenueData: json["all_venue_data"] == null ? [] : List<AllVenueDatum>.from(json["all_venue_data"]!.map((x) => AllVenueDatum.fromJson(x))),
      images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
      remainingEvent: json["remaining_event"] == null ? [] : List<RemainingEvent>.from(json["remaining_event"]!.map((x) => RemainingEvent.fromJson(x))),
      eventInterest: json["event_interest"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "en_event_name": enEventName,
    "hi_event_name": hiEventName,
    "en_event_about": enEventAbout,
    "hi_event_about": hiEventAbout,
    "en_event_schedule": enEventSchedule,
    "hi_event_schedule": hiEventSchedule,
    "en_event_attend": enEventAttend,
    "hi_event_attend": hiEventAttend,
    "en_event_team_condition": enEventTeamCondition,
    "hi_event_team_condition": hiEventTeamCondition,
    "en_language": enLanguage,
    "hi_language": hiLanguage,
    "id": id,
    "organizer_by": organizerBy,
    "age_group": ageGroup,
    "days": days,
    "youtube_video": youtubeVideo,
    "event_interested": eventInterested,
    "informational_status": informationalStatus,
    "aadhar_status": aadharStatus,
    "percentage_off": percentageOff,
    "categorys": categorys?.toJson(),
    "organizers": organizers?.toJson(),
    "event_image": eventImage,
    "all_venue_data": allVenueData.map((x) => x?.toJson()).toList(),
    "images": images.map((x) => x).toList(),
    "remaining_event": remainingEvent.map((x) => x?.toJson()).toList(),
    "event_interest": eventInterest,
  };

}

class AllVenueDatum {
  AllVenueDatum({
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

  factory AllVenueDatum.fromJson(Map<String, dynamic> json){
    return AllVenueDatum(
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

  Map<String, dynamic> toJson() => {
    "id": id,
    "en_event_venue": enEventVenue,
    "en_event_country": enEventCountry,
    "en_event_state": enEventState,
    "en_event_cities": enEventCities,
    "hi_event_venue": hiEventVenue,
    "hi_event_country": hiEventCountry,
    "hi_event_state": hiEventState,
    "hi_event_cities": hiEventCities,
  };

}

class Categorys {
  Categorys({
    required this.id,
    required this.enCategoryName,
    required this.hiCategoryName,
    required this.image,
  });

  final int id;
  final String enCategoryName;
  final String hiCategoryName;
  final String image;

  factory Categorys.fromJson(Map<String, dynamic> json){
    return Categorys(
      id: json["id"] ?? 0,
      enCategoryName: json["en_category_name"] ?? "",
      hiCategoryName: json["hi_category_name"] ?? "",
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "en_category_name": enCategoryName,
    "hi_category_name": hiCategoryName,
    "image": image,
  };

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
  final int id;
  final String fullName;
  final String emailAddress;
  final String contactNumber;
  final String image;

  factory Organizers.fromJson(Map<String, dynamic> json){
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

  Map<String, dynamic> toJson() => {
    "en_organizer_name": enOrganizerName,
    "hi_organizer_name": hiOrganizerName,
    "id": id,
    "full_name": fullName,
    "email_address": emailAddress,
    "contact_number": contactNumber,
    "image": image,
  };

}

class RemainingEvent {
  RemainingEvent({
    required this.id,
    required this.enEventName,
    required this.eventImage,
    required this.allVenueData,
    required this.eventOrderReviewCount,
    required this.reviewAvgStar,
    required this.hiEventName,
    required this.price,
  });

  final int id;
  final String enEventName;
  final String eventImage;
  final String allVenueData;
  final int eventOrderReviewCount;
  final int reviewAvgStar;
  final String hiEventName;
  final String price;

  factory RemainingEvent.fromJson(Map<String, dynamic> json){
    return RemainingEvent(
      id: json["id"] ?? 0,
      enEventName: json["en_event_name"] ?? "",
      eventImage: json["event_image"] ?? "",
      allVenueData: json["all_venue_data"] ?? "",
      eventOrderReviewCount: json["event_order_review_count"] ?? 0,
      reviewAvgStar: json["review_avg_star"] ?? 0,
      hiEventName: json["hi_event_name"] ?? "",
      price: json["price"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "en_event_name": enEventName,
    "event_image": eventImage,
    "all_venue_data": allVenueData,
    "event_order_review_count": eventOrderReviewCount,
    "review_avg_star": reviewAvgStar,
    "hi_event_name": hiEventName,
    "price": price,
  };

}
