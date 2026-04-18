import 'dart:convert';

MandirChadhavaModel mandirChadhavaModelFromJson(String str) =>
    MandirChadhavaModel.fromJson(json.decode(str));

String mandirChadhavaModelToJson(MandirChadhavaModel data) =>
    json.encode(data.toJson());

// class MandirChadhavaModel {
//   int status;
//   Data data;
//
//   MandirChadhavaModel({
//     required this.status,
//     required this.data,
//   });
//
//   factory MandirChadhavaModel.fromJson(Map<String, dynamic> json) => MandirChadhavaModel(
//     status: json["status"],
//     data: Data.fromJson(json["data"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "data": data.toJson(),
//   };
// }
//
// class Data {
//   List<Chadhava> chadhava;
//   Products products;
//
//   Data({
//     required this.chadhava,
//     required this.products,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     chadhava: List<Chadhava>.from(json["chadhava"].map((x) => Chadhava.fromJson(x))),
//     products: Products.fromJson(json["products"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "chadhava": List<dynamic>.from(chadhava.map((x) => x.toJson())),
//     "products": products.toJson(),
//   };
// }
//
// class Chadhava {
//   int id;
//   String enName;
//   String hiName;
//   String thumbnail;
//   String enShortDetails;
//   String hiShortDetails;
//   DateTime nextChadhavaDate;
//   String chadhavaTypeText;
//
//   Chadhava({
//     required this.id,
//     required this.enName,
//     required this.hiName,
//     required this.thumbnail,
//     required this.enShortDetails,
//     required this.hiShortDetails,
//     required this.nextChadhavaDate,
//     required this.chadhavaTypeText,
//   });
//
//   factory Chadhava.fromJson(Map<String, dynamic> json) => Chadhava(
//     id: json["id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     thumbnail: json["thumbnail"],
//     enShortDetails: json["en_short_details"],
//     hiShortDetails: json["hi_short_details"],
//     nextChadhavaDate: DateTime.parse(json["next_chadhava_date"]),
//     chadhavaTypeText: json["chadhava_type_text"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "en_name": enName,
//     "hi_name": hiName,
//     "thumbnail": thumbnail,
//     "en_short_details": enShortDetails,
//     "hi_short_details": hiShortDetails,
//     "next_chadhava_date": nextChadhavaDate.toIso8601String(),
//     "chadhava_type_text": chadhavaTypeText,
//   };
// }
//
// class Products {
//   String productId;
//   String enName;
//   String hiName;
//   String thumbnail;
//
//   Products({
//     required this.productId,
//     required this.enName,
//     required this.hiName,
//     required this.thumbnail,
//   });
//
//   factory Products.fromJson(Map<String, dynamic> json) => Products(
//     productId: json["product_id"],
//     enName: json["en_name"],
//     hiName: json["hi_name"],
//     thumbnail: json["thumbnail"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "product_id": productId,
//     "en_name": enName,
//     "hi_name": hiName,
//     "thumbnail": thumbnail,
//   };
// }

class MandirChadhavaModel {
  MandirChadhavaModel({
    required this.status,
    required this.data,
  });

  final int status;
  final Data? data;

  factory MandirChadhavaModel.fromJson(Map<String, dynamic> json) {
    return MandirChadhavaModel(
      status: json["status"] ?? 0,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return "$status, $data, ";
  }
}

class Data {
  Data({
    required this.chadhava,
    required this.products,
  });

  final List<Chadhava> chadhava;
  final Products? products;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      chadhava: json["chadhava"] == null
          ? []
          : List<Chadhava>.from(
              json["chadhava"]!.map((x) => Chadhava.fromJson(x))),
      products:
          json["products"] == null ? null : Products.fromJson(json["products"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "chadhava": chadhava.map((x) => x.toJson()).toList(),
        "products": products?.toJson(),
      };

  @override
  String toString() {
    return "$chadhava, $products, ";
  }
}

class Chadhava {
  Chadhava({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.thumbnail,
    required this.enShortDetails,
    required this.hiShortDetails,
    required this.nextChadhavaDate,
    required this.chadhavaTypeText,
  });

  final int id;
  final String enName;
  final String hiName;
  final String thumbnail;
  final String enShortDetails;
  final String hiShortDetails;
  final DateTime? nextChadhavaDate;
  final String chadhavaTypeText;

  factory Chadhava.fromJson(Map<String, dynamic> json) {
    return Chadhava(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      enShortDetails: json["en_short_details"] ?? "",
      hiShortDetails: json["hi_short_details"] ?? "",
      nextChadhavaDate: DateTime.tryParse(json["next_chadhava_date"] ?? ""),
      chadhavaTypeText: json["chadhava_type_text"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "thumbnail": thumbnail,
        "en_short_details": enShortDetails,
        "hi_short_details": hiShortDetails,
        "next_chadhava_date": nextChadhavaDate?.toIso8601String(),
        "chadhava_type_text": chadhavaTypeText,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $thumbnail, $enShortDetails, $hiShortDetails, $nextChadhavaDate, $chadhavaTypeText, ";
  }
}

class Products {
  Products({
    required this.productId,
    required this.enName,
    required this.hiName,
    required this.thumbnail,
  });

  final String productId;
  final String enName;
  final String hiName;
  final String thumbnail;

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productId: json["product_id"] ?? "",
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "en_name": enName,
        "hi_name": hiName,
        "thumbnail": thumbnail,
      };

  @override
  String toString() {
    return "$productId, $enName, $hiName, $thumbnail, ";
  }
}
