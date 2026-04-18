// class PoojaSearchModel {
//   int? status;
//   List<PoojaServices>? poojaServices;
//   List<Vippooja>? vippooja;
//   List<Anushthan>? anushthan;
//   List<Chadhava>? chadhava;
//
//   PoojaSearchModel(
//       {this.status,
//         this.poojaServices,
//         this.vippooja,
//         this.anushthan,
//         this.chadhava});
//
//   PoojaSearchModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     if (json['pooja_services'] != null) {
//       poojaServices = <PoojaServices>[];
//       json['pooja_services'].forEach((v) {
//         poojaServices!.add(new PoojaServices.fromJson(v));
//       });
//     }
//     if (json['vippooja'] != null) {
//       vippooja = <Vippooja>[];
//       json['vippooja'].forEach((v) {
//         vippooja!.add(new Vippooja.fromJson(v));
//       });
//     }
//     if (json['anushthan'] != null) {
//       anushthan = <Anushthan>[];
//       json['anushthan'].forEach((v) {
//         anushthan!.add(new Anushthan.fromJson(v));
//       });
//     }
//     if (json['chadhava'] != null) {
//       chadhava = <Chadhava>[];
//       json['chadhava'].forEach((v) {
//         chadhava!.add(new Chadhava.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     if (this.poojaServices != null) {
//       data['pooja_services'] =
//           this.poojaServices!.map((v) => v.toJson()).toList();
//     }
//     if (this.vippooja != null) {
//       data['vippooja'] = this.vippooja!.map((v) => v.toJson()).toList();
//     }
//     if (this.anushthan != null) {
//       data['anushthan'] = this.anushthan!.map((v) => v.toJson()).toList();
//     }
//     if (this.chadhava != null) {
//       data['chadhava'] = this.chadhava!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class PoojaServices {
//   int? id;
//   String? enName;
//   String? hiName;
//   String? slug;
//   String? enPoojaVenue;
//   String? hiPoojaVenue;
//   String? thumbnail;
//   String? nextPoojaDate;
//   String? poojaTypeText;
//
//   PoojaServices(
//       {this.id,
//         this.enName,
//         this.hiName,
//         this.slug,
//         this.enPoojaVenue,
//         this.hiPoojaVenue,
//         this.thumbnail,
//         this.nextPoojaDate,
//         this.poojaTypeText});
//
//   PoojaServices.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     enName = json['en_name'];
//     hiName = json['hi_name'];
//     slug = json['slug'];
//     enPoojaVenue = json['en_pooja_venue'];
//     hiPoojaVenue = json['hi_pooja_venue'];
//     thumbnail = json['thumbnail'];
//     nextPoojaDate = json['next_pooja_date'];
//     poojaTypeText = json['pooja_type_text'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['en_name'] = this.enName;
//     data['hi_name'] = this.hiName;
//     data['slug'] = this.slug;
//     data['en_pooja_venue'] = this.enPoojaVenue;
//     data['hi_pooja_venue'] = this.hiPoojaVenue;
//     data['thumbnail'] = this.thumbnail;
//     data['next_pooja_date'] = this.nextPoojaDate;
//     data['pooja_type_text'] = this.poojaTypeText;
//     return data;
//   }
// }
//
// class Chadhava {
//   int? id;
//   String? enName;
//   String? hiName;
//   String? slug;
//   String? enPoojaVenue;
//   String? hiPoojaVenue;
//   String? thumbnail;
//   String? nextPoojaDate;
//   String? poojaTypeText;
//
//   Chadhava(
//       {this.id,
//         this.enName,
//         this.hiName,
//         this.slug,
//         this.enPoojaVenue,
//         this.hiPoojaVenue,
//         this.thumbnail,
//         this.nextPoojaDate,
//         this.poojaTypeText});
//
//   Chadhava.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     enName = json['en_name'];
//     hiName = json['hi_name'];
//     slug = json['slug'];
//     enPoojaVenue = json['en_pooja_venue'];
//     hiPoojaVenue = json['hi_pooja_venue'];
//     thumbnail = json['thumbnail'];
//     nextPoojaDate = json['next_pooja_date'];
//     poojaTypeText = json['pooja_type_text'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['en_name'] = this.enName;
//     data['hi_name'] = this.hiName;
//     data['slug'] = this.slug;
//     data['en_pooja_venue'] = this.enPoojaVenue;
//     data['hi_pooja_venue'] = this.hiPoojaVenue;
//     data['thumbnail'] = this.thumbnail;
//     data['next_pooja_date'] = this.nextPoojaDate;
//     data['pooja_type_text'] = this.poojaTypeText;
//     return data;
//   }
// }
//
// class Vippooja {
//   int? id;
//   String? enName;
//   String? hiName;
//   String? slug;
//   String? thumbnail;
//
//   Vippooja({this.id, this.enName, this.hiName, this.slug, this.thumbnail});
//
//   Vippooja.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     enName = json['en_name'];
//     hiName = json['hi_name'];
//     slug = json['slug'];
//     thumbnail = json['thumbnail'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['en_name'] = this.enName;
//     data['hi_name'] = this.hiName;
//     data['slug'] = this.slug;
//     data['thumbnail'] = this.thumbnail;
//     return data;
//   }
// }
//
// class Anushthan {
//   int? id;
//   String? enName;
//   String? hiName;
//   String? slug;
//   String? thumbnail;
//
//   Anushthan({this.id, this.enName, this.hiName, this.slug, this.thumbnail});
//
//   Anushthan.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     enName = json['en_name'];
//     hiName = json['hi_name'];
//     slug = json['slug'];
//     thumbnail = json['thumbnail'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['en_name'] = this.enName;
//     data['hi_name'] = this.hiName;
//     data['slug'] = this.slug;
//     data['thumbnail'] = this.thumbnail;
//     return data;
//   }
// }
//

class PoojaSearchModel {
  int? status;
  List<PoojaServices>? poojaServices;
  List<Vippooja>? vippooja;
  List<Anushthan>? anushthan;
  List<Chadhava>? chadhava;

  PoojaSearchModel(
      {this.status,
      this.poojaServices,
      this.vippooja,
      this.anushthan,
      this.chadhava});

  PoojaSearchModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['pooja_services'] != null) {
      poojaServices = <PoojaServices>[];
      json['pooja_services'].forEach((v) {
        poojaServices!.add(PoojaServices.fromJson(v));
      });
    }
    if (json['vippooja'] != null) {
      vippooja = <Vippooja>[];
      json['vippooja'].forEach((v) {
        vippooja!.add(Vippooja.fromJson(v));
      });
    }
    if (json['anushthan'] != null) {
      anushthan = <Anushthan>[];
      json['anushthan'].forEach((v) {
        anushthan!.add(Anushthan.fromJson(v));
      });
    }
    if (json['chadhava'] != null) {
      chadhava = <Chadhava>[];
      json['chadhava'].forEach((v) {
        chadhava!.add(Chadhava.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (poojaServices != null) {
      data['pooja_services'] = poojaServices!.map((v) => v.toJson()).toList();
    }
    if (vippooja != null) {
      data['vippooja'] = vippooja!.map((v) => v.toJson()).toList();
    }
    if (anushthan != null) {
      data['anushthan'] = anushthan!.map((v) => v.toJson()).toList();
    }
    if (chadhava != null) {
      data['chadhava'] = chadhava!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Anushthan {
  Anushthan({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.slug,
    required this.thumbnail,
  });

  final int id;
  final String enName;
  final String hiName;
  final String slug;
  final String thumbnail;

  factory Anushthan.fromJson(Map<String, dynamic> json) {
    return Anushthan(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      slug: json["slug"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "slug": slug,
        "thumbnail": thumbnail,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $slug, $thumbnail, ";
  }
}

class PoojaServices {
  PoojaServices({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.slug,
    required this.enPoojaVenue,
    required this.hiPoojaVenue,
    required this.thumbnail,
    required this.nextPoojaDate,
    required this.poojaTypeText,
  });

  final int id;
  final String enName;
  final String hiName;
  final String slug;
  final String enPoojaVenue;
  final String hiPoojaVenue;
  final String thumbnail;
  final DateTime? nextPoojaDate;
  final String poojaTypeText;

  factory PoojaServices.fromJson(Map<String, dynamic> json) {
    return PoojaServices(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      slug: json["slug"] ?? "",
      enPoojaVenue: json["en_pooja_venue"] ?? "",
      hiPoojaVenue: json["hi_pooja_venue"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      nextPoojaDate: DateTime.tryParse(json["next_pooja_date"] ?? ""),
      poojaTypeText: json["pooja_type_text"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "slug": slug,
        "en_pooja_venue": enPoojaVenue,
        "hi_pooja_venue": hiPoojaVenue,
        "thumbnail": thumbnail,
        "next_pooja_date": nextPoojaDate?.toIso8601String(),
        "pooja_type_text": poojaTypeText,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $slug, $enPoojaVenue, $hiPoojaVenue, $thumbnail, $nextPoojaDate, $poojaTypeText, ";
  }
}

class Vippooja {
  int? id;
  String? enName;
  String? hiName;
  String? slug;
  String? thumbnail;

  Vippooja({this.id, this.enName, this.hiName, this.slug, this.thumbnail});

  Vippooja.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enName = json['en_name'];
    hiName = json['hi_name'];
    slug = json['slug'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en_name'] = enName;
    data['hi_name'] = hiName;
    data['slug'] = slug;
    data['thumbnail'] = thumbnail;
    return data;
  }
}

class Chadhava {
  int? id;
  String? enName;
  String? hiName;
  String? slug;
  String? enPoojaVenue;
  String? hiPoojaVenue;
  String? thumbnail;
  String? nextPoojaDate;
  String? poojaTypeText;

  Chadhava(
      {this.id,
      this.enName,
      this.hiName,
      this.slug,
      this.enPoojaVenue,
      this.hiPoojaVenue,
      this.thumbnail,
      this.nextPoojaDate,
      this.poojaTypeText});

  Chadhava.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enName = json['en_name'];
    hiName = json['hi_name'];
    slug = json['slug'];
    enPoojaVenue = json['en_pooja_venue'];
    hiPoojaVenue = json['hi_pooja_venue'];
    thumbnail = json['thumbnail'];
    nextPoojaDate = json['next_pooja_date'];
    poojaTypeText = json['pooja_type_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en_name'] = enName;
    data['hi_name'] = hiName;
    data['slug'] = slug;
    data['en_pooja_venue'] = enPoojaVenue;
    data['hi_pooja_venue'] = hiPoojaVenue;
    data['thumbnail'] = thumbnail;
    data['next_pooja_date'] = nextPoojaDate;
    data['pooja_type_text'] = poojaTypeText;
    return data;
  }
}
