// class AllPoojaModel {
//   AllPoojaModel({
//     required this.status,
//     required this.pooja,
//     required this.vipPooja,
//     required this.anushthan,
//     required this.chadhava,
//   });
//
//   final int status;
//   final List<Pooja> pooja;
//   final List<Anushthan> vipPooja;
//   final List<Anushthan> anushthan;
//   final List<Chadhava> chadhava;
//
//   factory AllPoojaModel.fromJson(Map<String, dynamic> json){
//     return AllPoojaModel(
//       status: json["status"] ?? 0,
//       pooja: json["pooja"] == null ? [] : List<Pooja>.from(json["pooja"]!.map((x) => Pooja.fromJson(x))),
//       vipPooja: json["vip_pooja"] == null ? [] : List<Anushthan>.from(json["vip_pooja"]!.map((x) => Anushthan.fromJson(x))),
//       anushthan: json["anushthan"] == null ? [] : List<Anushthan>.from(json["anushthan"]!.map((x) => Anushthan.fromJson(x))),
//       chadhava: json["chadhava"] == null ? [] : List<Chadhava>.from(json["chadhava"]!.map((x) => Chadhava.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "pooja": pooja.map((x) => x.toJson()).toList(),
//     "vip_pooja": vipPooja.map((x) => x.toJson()).toList(),
//     "anushthan": anushthan.map((x) => x.toJson()).toList(),
//     "chadhava": chadhava.map((x) => x.toJson()).toList(),
//   };
//
//   @override
//   String toString(){
//     return "$status, $pooja, $vipPooja, $anushthan, $chadhava, ";
//   }
// }
//
// class Anushthan {
//   Anushthan({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.enPoojaHeading,
//     required this.hiPoojaHeading,
//     required this.slug,
//     required this.status,
//     required this.enShortBenifits,
//     required this.hiShortBenifits,
//     required this.isAnushthan,
//     required this.thumbnail,
//   });
//
//   final int id;
//   final String enName;
//   final String hiName;
//   final String enPoojaHeading;
//   final String hiPoojaHeading;
//   final String slug;
//   final int status;
//   final String enShortBenifits;
//   final String hiShortBenifits;
//   final int isAnushthan;
//   final String thumbnail;
//
//   factory Anushthan.fromJson(Map<String, dynamic> json){
//     return Anushthan(
//       id: json["id"] ?? 0,
//       enName: json["en_name"] ?? "",
//       hiName: json["hi_name"] ?? "",
//       enPoojaHeading: json["en_pooja_heading"] ?? "",
//       hiPoojaHeading: json["hi_pooja_heading"] ?? "",
//       slug: json["slug"] ?? "",
//       status: json["status"] ?? 0,
//       enShortBenifits: json["en_short_benifits"] ?? "",
//       hiShortBenifits: json["hi_short_benifits"] ?? "",
//       isAnushthan: json["is_anushthan"] ?? 0,
//       thumbnail: json["thumbnail"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "en_pooja_heading": enPoojaHeading,
//     "hi_pooja_heading": hiPoojaHeading,
//     "slug": slug,
//     "status": status,
//     "en_short_benifits": enShortBenifits,
//     "hi_short_benifits": hiShortBenifits,
//     "is_anushthan": isAnushthan,
//     "thumbnail": thumbnail,
//   };
//
//   @override
//   String toString(){
//     return "$id, $enName, $hiName, $enPoojaHeading, $hiPoojaHeading, $slug, $status, $enShortBenifits, $hiShortBenifits, $isAnushthan, $thumbnail, ";
//   }
// }
//
// class Chadhava {
//   Chadhava({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.enPoojaHeading,
//     required this.hiPoojaHeading,
//     required this.slug,
//     required this.status,
//     required this.enShortDetails,
//     required this.hiShortDetails,
//     required this.productType,
//     required this.enDetails,
//     required this.hiDetails,
//     required this.enChadhavaVenue,
//     required this.hiChadhavaVenue,
//     required this.chadhavaWeek,
//     required this.thumbnail,
//     required this.nextChadhavaDate,
//     required this.chadhavaTypeText,
//   });
//
//   final int id;
//   final String enName;
//   final String hiName;
//   final String enPoojaHeading;
//   final String hiPoojaHeading;
//   final String slug;
//   final int status;
//   final String enShortDetails;
//   final String hiShortDetails;
//   final dynamic productType;
//   final String enDetails;
//   final String hiDetails;
//   final String enChadhavaVenue;
//   final String hiChadhavaVenue;
//   final String chadhavaWeek;
//   final String thumbnail;
//   final DateTime? nextChadhavaDate;
//   final String chadhavaTypeText;
//
//   factory Chadhava.fromJson(Map<String, dynamic> json){
//     return Chadhava(
//       id: json["id"] ?? 0,
//       enName: json["en_name"] ?? "",
//       hiName: json["hi_name"] ?? "",
//       enPoojaHeading: json["en_pooja_heading"] ?? "",
//       hiPoojaHeading: json["hi_pooja_heading"] ?? "",
//       slug: json["slug"] ?? "",
//       status: json["status"] ?? 0,
//       enShortDetails: json["en_short_details"] ?? "",
//       hiShortDetails: json["hi_short_details"] ?? "",
//       productType: json["product_type"],
//       enDetails: json["en_details"] ?? "",
//       hiDetails: json["hi_details"] ?? "",
//       enChadhavaVenue: json["en_chadhava_venue"] ?? "",
//       hiChadhavaVenue: json["hi_chadhava_venue"] ?? "",
//       chadhavaWeek: json["chadhava_week"] ?? "",
//       thumbnail: json["thumbnail"] ?? "",
//       nextChadhavaDate: DateTime.tryParse(json["next_chadhava_date"] ?? ""),
//       chadhavaTypeText: json["chadhava_type_text"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "en_pooja_heading": enPoojaHeading,
//     "hi_pooja_heading": hiPoojaHeading,
//     "slug": slug,
//     "status": status,
//     "en_short_details": enShortDetails,
//     "hi_short_details": hiShortDetails,
//     "product_type": productType,
//     "en_details": enDetails,
//     "hi_details": hiDetails,
//     "en_chadhava_venue": enChadhavaVenue,
//     "hi_chadhava_venue": hiChadhavaVenue,
//     "chadhava_week": chadhavaWeek,
//     "thumbnail": thumbnail,
//     "next_chadhava_date": nextChadhavaDate?.toIso8601String(),
//     "chadhava_type_text": chadhavaTypeText,
//   };
//
//   @override
//   String toString(){
//     return "$id, $enName, $hiName, $enPoojaHeading, $hiPoojaHeading, $slug, $status, $enShortDetails, $hiShortDetails, $productType, $enDetails, $hiDetails, $enChadhavaVenue, $hiChadhavaVenue, $chadhavaWeek, $thumbnail, $nextChadhavaDate, $chadhavaTypeText, ";
//   }
// }
//
// class Pooja {
//   Pooja({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.slug,
//     required this.status,
//     required this.enShortBenifits,
//     required this.hiShortBenifits,
//     required this.enPoojaHeading,
//     required this.hiPoojaHeading,
//     required this.productType,
//     required this.poojaType,
//     required this.enPoojaVenue,
//     required this.hiPoojaVenue,
//     required this.weekDays,
//     required this.thumbnail,
//     required this.nextPoojaDate,
//     required this.poojaTypeText,
//   });
//
//   final int id;
//   final String enName;
//   final String hiName;
//   final String slug;
//   final int status;
//   final String enShortBenifits;
//   final String hiShortBenifits;
//   final String enPoojaHeading;
//   final String hiPoojaHeading;
//   final String productType;
//   final int poojaType;
//   final String enPoojaVenue;
//   final String hiPoojaVenue;
//   final String weekDays;
//   final String thumbnail;
//   final DateTime? nextPoojaDate;
//   final String poojaTypeText;
//
//   factory Pooja.fromJson(Map<String, dynamic> json){
//     return Pooja(
//       id: json["id"] ?? 0,
//       enName: json["en_name"] ?? "",
//       hiName: json["hi_name"] ?? "",
//       slug: json["slug"] ?? "",
//       status: json["status"] ?? 0,
//       enShortBenifits: json["en_short_benifits"] ?? "",
//       hiShortBenifits: json["hi_short_benifits"] ?? "",
//       enPoojaHeading: json["en_pooja_heading"] ?? "",
//       hiPoojaHeading: json["hi_pooja_heading"] ?? "",
//       productType: json["product_type"] ?? "",
//       poojaType: json["pooja_type"] ?? 0,
//       enPoojaVenue: json["en_pooja_venue"] ?? "",
//       hiPoojaVenue: json["hi_pooja_venue"] ?? "",
//       weekDays: json["week_days"] ?? "",
//       thumbnail: json["thumbnail"] ?? "",
//       nextPoojaDate: DateTime.tryParse(json["next_pooja_date"] ?? ""),
//       poojaTypeText: json["pooja_type_text"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "slug": slug,
//     "status": status,
//     "en_short_benifits": enShortBenifits,
//     "hi_short_benifits": hiShortBenifits,
//     "en_pooja_heading": enPoojaHeading,
//     "hi_pooja_heading": hiPoojaHeading,
//     "product_type": productType,
//     "pooja_type": poojaType,
//     "en_pooja_venue": enPoojaVenue,
//     "hi_pooja_venue": hiPoojaVenue,
//     "week_days": weekDays,
//     "thumbnail": thumbnail,
//     "next_pooja_date": nextPoojaDate?.toIso8601String(),
//     "pooja_type_text": poojaTypeText,
//   };
//
//   @override
//   String toString(){
//     return "$id, $enName, $hiName, $slug, $status, $enShortBenifits, $hiShortBenifits, $enPoojaHeading, $hiPoojaHeading, $productType, $poojaType, $enPoojaVenue, $hiPoojaVenue, $weekDays, $thumbnail, $nextPoojaDate, $poojaTypeText, ";
//   }
// }

class AllPoojaModel {
  AllPoojaModel({
    required this.status,
    required this.pooja,
    required this.vipPooja,
    required this.anushthan,
    required this.chadhava,
  });

  final int status;
  final List<Pooja> pooja;
  final List<Anushthan> vipPooja;
  final List<Anushthan> anushthan;
  final List<Chadhava> chadhava;

  factory AllPoojaModel.fromJson(Map<String, dynamic> json) {
    return AllPoojaModel(
      status: json["status"] ?? 0,
      pooja: json["pooja"] == null
          ? []
          : List<Pooja>.from(json["pooja"]!.map((x) => Pooja.fromJson(x))),
      vipPooja: json["vip_pooja"] == null
          ? []
          : List<Anushthan>.from(
              json["vip_pooja"]!.map((x) => Anushthan.fromJson(x))),
      anushthan: json["anushthan"] == null
          ? []
          : List<Anushthan>.from(
              json["anushthan"]!.map((x) => Anushthan.fromJson(x))),
      chadhava: json["chadhava"] == null
          ? []
          : List<Chadhava>.from(
              json["chadhava"]!.map((x) => Chadhava.fromJson(x))),
    );
  }
}

class Anushthan {
  Anushthan({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.enPoojaHeading,
    required this.hiPoojaHeading,
    required this.slug,
    required this.status,
    required this.enShortBenifits,
    required this.hiShortBenifits,
    required this.isAnushthan,
    required this.thumbnail,
  });

  final int id;
  final String enName;
  final String hiName;
  final String enPoojaHeading;
  final String hiPoojaHeading;
  final String slug;
  final int status;
  final String enShortBenifits;
  final String hiShortBenifits;
  final int isAnushthan;
  final String thumbnail;

  factory Anushthan.fromJson(Map<String, dynamic> json) {
    return Anushthan(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enPoojaHeading: json["en_pooja_heading"] ?? "",
      hiPoojaHeading: json["hi_pooja_heading"] ?? "",
      slug: json["slug"] ?? "",
      status: json["status"] ?? 0,
      enShortBenifits: json["en_short_benifits"] ?? "",
      hiShortBenifits: json["hi_short_benifits"] ?? "",
      isAnushthan: json["is_anushthan"] ?? 0,
      thumbnail: json["thumbnail"] ?? "",
    );
  }
}

class Chadhava {
  Chadhava({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.enPoojaHeading,
    required this.hiPoojaHeading,
    required this.slug,
    required this.status,
    required this.enShortDetails,
    required this.hiShortDetails,
    required this.productType,
    required this.enDetails,
    required this.hiDetails,
    required this.enChadhavaVenue,
    required this.hiChadhavaVenue,
    required this.chadhavaWeek,
    required this.thumbnail,
    required this.nextChadhavaDate,
    required this.chadhavaTypeText,
  });

  final int id;
  final String enName;
  final String hiName;
  final String enPoojaHeading;
  final String hiPoojaHeading;
  final String slug;
  final int status;
  final String enShortDetails;
  final String hiShortDetails;
  final dynamic productType;
  final String enDetails;
  final String hiDetails;
  final String enChadhavaVenue;
  final String hiChadhavaVenue;
  final String chadhavaWeek;
  final String thumbnail;
  final String nextChadhavaDate;
  final String chadhavaTypeText;

  factory Chadhava.fromJson(Map<String, dynamic> json) {
    return Chadhava(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enPoojaHeading: json["en_pooja_heading"] ?? "",
      hiPoojaHeading: json["hi_pooja_heading"] ?? "",
      slug: json["slug"] ?? "",
      status: json["status"] ?? 0,
      enShortDetails: json["en_short_details"] ?? "",
      hiShortDetails: json["hi_short_details"] ?? "",
      productType: json["product_type"],
      enDetails: json["en_details"] ?? "",
      hiDetails: json["hi_details"] ?? "",
      enChadhavaVenue: json["en_chadhava_venue"] ?? "",
      hiChadhavaVenue: json["hi_chadhava_venue"] ?? "",
      chadhavaWeek: json["chadhava_week"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      nextChadhavaDate: json["next_chadhava_date"] ?? "",
      chadhavaTypeText: json["chadhava_type_text"] ?? "",
    );
  }
}

class Pooja {
  Pooja({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.slug,
    required this.status,
    required this.enShortBenifits,
    required this.hiShortBenifits,
    required this.enPoojaHeading,
    required this.hiPoojaHeading,
    required this.productType,
    required this.poojaType,
    required this.enPoojaVenue,
    required this.hiPoojaVenue,
    required this.weekDays,
    required this.thumbnail,
    required this.nextPoojaDate,
    required this.poojaTypeText,
  });

  final int id;
  final String enName;
  final String hiName;
  final String slug;
  final int status;
  final String enShortBenifits;
  final String hiShortBenifits;
  final String enPoojaHeading;
  final String hiPoojaHeading;
  final String productType;
  final int poojaType;
  final String enPoojaVenue;
  final String hiPoojaVenue;
  final String weekDays;
  final String thumbnail;
  final DateTime? nextPoojaDate;
  final String poojaTypeText;

  factory Pooja.fromJson(Map<String, dynamic> json) {
    return Pooja(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      slug: json["slug"] ?? "",
      status: json["status"] ?? 0,
      enShortBenifits: json["en_short_benifits"] ?? "",
      hiShortBenifits: json["hi_short_benifits"] ?? "",
      enPoojaHeading: json["en_pooja_heading"] ?? "",
      hiPoojaHeading: json["hi_pooja_heading"] ?? "",
      productType: json["product_type"] ?? "",
      poojaType: json["pooja_type"] ?? 0,
      enPoojaVenue: json["en_pooja_venue"] ?? "",
      hiPoojaVenue: json["hi_pooja_venue"] ?? "",
      weekDays: json["week_days"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      nextPoojaDate: DateTime.tryParse(json["next_pooja_date"] ?? ""),
      poojaTypeText: json["pooja_type_text"] ?? "",
    );
  }
}
