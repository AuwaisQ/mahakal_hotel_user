// class NewToursModel {
//   NewToursModel({
//     required this.status,
//     required this.count,
//     required this.data,
//   });
//
//   final int status;
//   final int count;
//   final List<NewToursData> data;
//
//   factory NewToursModel.fromJson(Map<String, dynamic> json) {
//     return NewToursModel(
//       status: json["status"] ?? 0,
//       count: json["count"] ?? 0,
//       data: json["data"] == null
//           ? []
//           : List<NewToursData>.from(
//               json["data"]!.map((x) => NewToursData.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "count": count,
//         "data": data.map((x) => x.toJson()).toList(),
//       };
//
//   @override
//   String toString() {
//     return "$status, $count, $data, ";
//   }
// }
//
// class NewToursData {
//   NewToursData({
//     required this.id,
//     required this.enTourName,
//     required this.hiTourName,
//     required this.useDate,
//     required this.date,
//     required this.enNumberOfDay,
//     required this.hiNumberOfDay,
//     required this.cabList,
//     required this.packageList,
//     required this.services,
//     required this.image,
//   });
//
//   final int id;
//   final String enTourName;
//   final String hiTourName;
//   final int useDate;
//   final String date;
//   final String enNumberOfDay;
//   final String hiNumberOfDay;
//   final List<CabList> cabList;
//   final List<PackageList> packageList;
//   final List<String> services;
//   final String image;
//
//   factory NewToursData.fromJson(Map<String, dynamic> json) {
//     return NewToursData(
//       id: json["id"] ?? 0,
//       enTourName: json["en_tour_name"] ?? "",
//       hiTourName: json["hi_tour_name"] ?? "",
//       useDate: json["use_date"] ?? 0,
//       date: json["date"] ?? "",
//       enNumberOfDay: json["en_number_of_day"] ?? "",
//       hiNumberOfDay: json["hi_number_of_day"] ?? "",
//       cabList: json["cab_list"] == null
//           ? []
//           : List<CabList>.from(
//               json["cab_list"]!.map((x) => CabList.fromJson(x))),
//       packageList: json["package_list"] == null
//           ? []
//           : List<PackageList>.from(
//               json["package_list"]!.map((x) => PackageList.fromJson(x))),
//       services: json["services"] == null
//           ? []
//           : List<String>.from(json["services"]!.map((x) => x)),
//       image: json["image"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "en_tour_name": enTourName,
//         "hi_tour_name": hiTourName,
//         "use_date": useDate,
//         "date": date,
//         "en_number_of_day": enNumberOfDay,
//         "hi_number_of_day": hiNumberOfDay,
//         "cab_list": cabList.map((x) => x.toJson()).toList(),
//         "package_list": packageList.map((x) => x.toJson()).toList(),
//         "services": services.map((x) => x).toList(),
//         "image": image,
//       };
//
//   @override
//   String toString() {
//     return "$id, $enTourName, $hiTourName, $useDate, $date, $enNumberOfDay, $hiNumberOfDay, $cabList, $packageList, $services, $image, ";
//   }
// }
//
// class CabList {
//   CabList({
//     required this.price,
//     required this.cabId,
//     required this.min,
//     required this.max,
//     required this.cabName,
//     required this.seats,
//     required this.image,
//   });
//
//   final String price;
//   final dynamic cabId;
//   final dynamic min;
//   final dynamic max;
//   final String cabName;
//   final dynamic seats;
//   final String image;
//
//   factory CabList.fromJson(Map<String, dynamic> json) {
//     return CabList(
//       price: json["price"] ?? "",
//       cabId: json["cab_id"],
//       min: json["min"],
//       max: json["max"],
//       cabName: json["cab_name"] ?? "",
//       seats: json["seats"],
//       image: json["image"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "price": price,
//         "cab_id": cabId,
//         "min": min,
//         "max": max,
//         "cab_name": cabName,
//         "seats": seats,
//         "image": image,
//       };
//
//   @override
//   String toString() {
//     return "$price, $cabId, $min, $max, $cabName, $seats, $image, ";
//   }
// }
//
// class PackageList {
//   PackageList({
//     required this.price,
//     required this.packageId,
//     required this.packageName,
//     required this.seats,
//     required this.type,
//     required this.title,
//     required this.image,
//   });
//
//   final String price;
//   final String packageId;
//   final String packageName;
//   final int seats;
//   final String type;
//   final String title;
//   final String image;
//
//   factory PackageList.fromJson(Map<String, dynamic> json) {
//     return PackageList(
//       price: json["price"] ?? "",
//       packageId: json["package_id"] ?? "",
//       packageName: json["package_name"] ?? "",
//       seats: json["seats"] ?? 0,
//       type: json["type"] ?? "",
//       title: json["title"] ?? "",
//       image: json["image"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "price": price,
//         "package_id": packageId,
//         "package_name": packageName,
//         "seats": seats,
//         "type": type,
//         "title": title,
//         "image": image,
//       };
//
//   @override
//   String toString() {
//     return "$price, $packageId, $packageName, $seats, $type, $title, $image, ";
//   }
// }

class NewToursModel {
  NewToursModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int? status;
  final int? count;
  final List<NewToursData> data;

  factory NewToursModel.fromJson(Map<String, dynamic> json){
    return NewToursModel(
      status: json["status"],
      count: json["count"],
      data: json["data"] == null ? [] : List<NewToursData>.from(json["data"]!.map((x) => NewToursData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "count": count,
    "data": data.map((x) => x?.toJson()).toList(),
  };

}

class NewToursData {
  NewToursData({
    required this.id,
    required this.slug,
    required this.enTourName,
    required this.hiTourName,
    required this.useDate,
    required this.date,
    required this.enNumberOfDay,
    required this.hiNumberOfDay,
    required this.planTypeName,
    required this.planTypeColor,
    required this.tourOrderReviewCount,
    required this.reviewAvgStar,
    required this.percentageOff,
    required this.isPersonUse,
    required this.minAmount,
    required this.image,
  });

  final int? id;
  final String? slug;
  final String? enTourName;
  final String? hiTourName;
  final int? useDate;
  final String? date;
  final String? enNumberOfDay;
  final String? hiNumberOfDay;
  final String? planTypeName;
  final String? planTypeColor;
  final int? tourOrderReviewCount;
  final String? reviewAvgStar;
  final int? percentageOff;
  final int? isPersonUse;
  final String? minAmount;
  final String? image;

  factory NewToursData.fromJson(Map<String, dynamic> json){
    return NewToursData(
      id: json["id"],
      slug: json["slug"],
      enTourName: json["en_tour_name"],
      hiTourName: json["hi_tour_name"],
      useDate: json["use_date"],
      date: json["date"],
      enNumberOfDay: json["en_number_of_day"],
      hiNumberOfDay: json["hi_number_of_day"],
      planTypeName: json["plan_type_name"],
      planTypeColor: json["plan_type_color"],
      tourOrderReviewCount: json["tour_order_review_count"],
      reviewAvgStar: json["review_avg_star"],
      percentageOff: json["percentage_off"],
      isPersonUse: json["is_person_use"],
      minAmount: json["min_amount"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "en_tour_name": enTourName,
    "hi_tour_name": hiTourName,
    "use_date": useDate,
    "date": date,
    "en_number_of_day": enNumberOfDay,
    "hi_number_of_day": hiNumberOfDay,
    "plan_type_name": planTypeName,
    "plan_type_color": planTypeColor,
    "tour_order_review_count": tourOrderReviewCount,
    "review_avg_star": reviewAvgStar,
    "percentage_off": percentageOff,
    "is_person_use": isPersonUse,
    "min_amount": minAmount,
    "image": image,
  };

}
