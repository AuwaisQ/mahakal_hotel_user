class ActivitiesListModel {
  ActivitiesListModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
    required this.pagination,
  });

  final int status;
  final String message;
  final int recode;
  final List<Datum> data;
  final Pagination? pagination;

  factory ActivitiesListModel.fromJson(Map<String, dynamic> json){
    return ActivitiesListModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data.map((x) => x?.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };

}

class Datum {
  Datum({
    required this.enEventName,
    required this.hiEventName,
    required this.id,
    required this.slug,
    required this.organizerBy,
    required this.ageGroup,
    required this.reviewCount,
    required this.reviewAvgStar,
    required this.language,
    required this.percentageOff,
    required this.minPrice,
    required this.price,
    required this.eventImage,
  });

  final String enEventName;
  final String hiEventName;
  final int id;
  final String slug;
  final String organizerBy;
  final String ageGroup;
  final String reviewCount;
  final String reviewAvgStar;
  final String language;
  final int percentageOff;
  final String minPrice;
  final String price;
  final String eventImage;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      enEventName: json["en_event_name"] ?? "",
      hiEventName: json["hi_event_name"] ?? "",
      id: json["id"] ?? 0,
      slug: json["slug"] ?? "",
      organizerBy: json["organizer_by"] ?? "",
      ageGroup: json["age_group"] ?? "",
      reviewCount: json["review_count"] ?? "",
      reviewAvgStar: json["review_avg_star"] ?? "",
      language: json["language"] ?? "",
      percentageOff: json["percentage_off"] ?? 0,
      minPrice: json["min_price"] ?? "",
      price: json["price"] ?? "",
      eventImage: json["event_image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "en_event_name": enEventName,
    "hi_event_name": hiEventName,
    "id": id,
    "slug": slug,
    "organizer_by": organizerBy,
    "age_group": ageGroup,
    "review_count": reviewCount,
    "review_avg_star": reviewAvgStar,
    "language": language,
    "percentage_off": percentageOff,
    "min_price": minPrice,
    "price": price,
    "event_image": eventImage,
  };

}

class Pagination {
  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.nextPage,
    required this.prevPage,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final dynamic nextPage;
  final dynamic prevPage;

  factory Pagination.fromJson(Map<String, dynamic> json){
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      lastPage: json["last_page"] ?? 0,
      perPage: json["per_page"] ?? 0,
      total: json["total"] ?? 0,
      nextPage: json["next_page"],
      prevPage: json["prev_page"],
    );
  }

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
    "next_page": nextPage,
    "prev_page": prevPage,
  };

}
