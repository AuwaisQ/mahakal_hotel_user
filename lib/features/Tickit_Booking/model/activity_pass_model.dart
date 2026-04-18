class ActivitiesPassModel {
  ActivitiesPassModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<Datum> data;

  factory ActivitiesPassModel.fromJson(Map<String, dynamic> json){
    return ActivitiesPassModel(
      status: json["status"] ?? 0,
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.map((x) => x?.toJson()).toList(),
  };

}

class Datum {
  Datum({
    required this.amount,
    required this.totalSeats,
    required this.enPackageName,
    required this.hiPackageName,
    required this.enEventName,
    required this.hiEventName,
    required this.enArtistName,
    required this.hiArtistName,
    required this.enOrganizerName,
    required this.hiOrganizerName,
    required this.enCategoryName,
    required this.hiCategoryName,
    required this.eventImage,
    required this.enEventVenue,
    required this.hiEventVenue,
    required this.eventDate,
    required this.footerPhone,
    required this.footerEmail,
    required this.footerUrl,
    required this.footerCopyright,
    required this.passUrl,
    required this.passUserName,
    required this.seats,
    required this.rows,
  });

  final int amount;
  final int totalSeats;
  final String enPackageName;
  final String hiPackageName;
  final String enEventName;
  final String hiEventName;
  final String enArtistName;
  final String hiArtistName;
  final String enOrganizerName;
  final String hiOrganizerName;
  final String enCategoryName;
  final String hiCategoryName;
  final String eventImage;
  final String enEventVenue;
  final String hiEventVenue;
  final String eventDate;
  final String footerPhone;
  final String footerEmail;
  final String footerUrl;
  final String footerCopyright;
  final String passUrl;
  final String passUserName;
  final String seats;
  final String rows;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      amount: json["amount"] ?? 0,
      totalSeats: json["total_seats"] ?? 0,
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      enEventName: json["en_event_name"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      enArtistName: json["en_artist_name"] ?? "",
      hiArtistName: json["hi_artist_name"] ?? "",
      enOrganizerName: json["en_organizer_name"] ?? "",
      hiOrganizerName: json["hi_organizer_name"] ?? "",
      enCategoryName: json["en_category_name"] ?? "",
      hiCategoryName: json["hi_category_name"] ?? "",
      eventImage: json["event_image"] ?? "",
      enEventVenue: json["en_event_venue"] ?? "",
      hiEventVenue: json["hi_event_venue"] ?? "",
      eventDate: json["event_date"] ?? "",
      footerPhone: json["footer_phone"] ?? "",
      footerEmail: json["footer_email"] ?? "",
      footerUrl: json["footer_url"] ?? "",
      footerCopyright: json["footer_copyright"] ?? "",
      passUrl: json["pass_url"] ?? "",
      passUserName: json["pass_user_name"] ?? "",
      seats: json["seats"] ?? "",
      rows: json["rows"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "total_seats": totalSeats,
    "en_package_name": enPackageName,
    "hi_package_name": hiPackageName,
    "en_event_name": enEventName,
    "hi_event_name": hiEventName,
    "en_artist_name": enArtistName,
    "hi_artist_name": hiArtistName,
    "en_organizer_name": enOrganizerName,
    "hi_organizer_name": hiOrganizerName,
    "en_category_name": enCategoryName,
    "hi_category_name": hiCategoryName,
    "event_image": eventImage,
    "en_event_venue": enEventVenue,
    "hi_event_venue": hiEventVenue,
    "event_date": eventDate,
    "footer_phone": footerPhone,
    "footer_email": footerEmail,
    "footer_url": footerUrl,
    "footer_copyright": footerCopyright,
    "pass_url": passUrl,
    "pass_user_name": passUserName,
    "seats": seats,
    "rows": rows,
  };

}
