// class DonationPageModel {
//   DonationPageModel({
//     required this.status,
//     required this.message,
//     required this.recode,
//     required this.data,
//   });
//
//   final int status;
//   final String message;
//   final int recode;
//   final Data? data;
//
//   factory DonationPageModel.fromJson(Map<String, dynamic> json) {
//     return DonationPageModel(
//       status: json["status"] ?? 0,
//       message: json["message"] ?? "",
//       recode: json["recode"] ?? 0,
//       data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "recode": recode,
//         "data": data?.toJson(),
//       };
//
//   @override
//   String toString() {
//     return "$status, $message, $recode, $data, ";
//   }
// }
//
// class Data {
//   Data({
//     required this.enName,
//     required this.hiName,
//     required this.enDescription,
//     required this.hiDescription,
//     required this.setType,
//     required this.setAmount,
//     required this.setTitle,
//     required this.setNumber,
//     required this.setUnit,
//     required this.autoStatus,
//     required this.enTrustName,
//     required this.hiTrustName,
//     required this.id,
//     required this.image,
//   });
//
//   final String enName;
//   final String hiName;
//   final String enDescription;
//   final String hiDescription;
//   final String setType;
//   final int setAmount;
//   final String setTitle;
//   final int setNumber;
//   final String setUnit;
//   final int autoStatus;
//   final String enTrustName;
//   final String hiTrustName;
//   final int id;
//   final String image;
//
//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       enName: json["en_name"] ?? "",
//       hiName: json["hi_name"] ?? "",
//       enDescription: json["en_description"] ?? "",
//       hiDescription: json["hi_description"] ?? "",
//       setType: json["set_type"] ?? "",
//       setAmount: json["set_amount"] ?? 0,
//       setTitle: json["set_title"] ?? "",
//       setNumber: json["set_number"] ?? 0,
//       setUnit: json["set_unit"] ?? "",
//       autoStatus: json["auto_pay_set_status"] ?? 0,
//       enTrustName: json["en_trust_name"] ?? "",
//       hiTrustName: json["hi_trust_name"] ?? "",
//       id: json["id"] ?? 0,
//       image: json["image"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "en_name": enName,
//         "hi_name": hiName,
//         "en_description": enDescription,
//         "hi_description": hiDescription,
//         "set_type": setType,
//         "set_amount": setAmount,
//         "set_title": setTitle,
//         "set_number": setNumber,
//         "set_unit": setUnit,
//         "auto_pay_set_status": autoStatus,
//         "en_trust_name": enTrustName,
//         "hi_trust_name": hiTrustName,
//         "id": id,
//         "image": image,
//       };
//
//   @override
//   String toString() {
//     return "$enName, $hiName, $enDescription, $hiDescription, $setType, $setAmount, $setTitle, $setNumber, $setUnit, $enTrustName, $hiTrustName, $id, $image, ";
//   }
// }
//

class DonationPageModel {
  DonationPageModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final Data? data;

  factory DonationPageModel.fromJson(Map<String, dynamic> json){
    return DonationPageModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
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
    required this.enName,
    required this.hiName,
    required this.enDescription,
    required this.hiDescription,
    required this.setType,
    required this.setAmount,
    required this.setTitle,
    required this.setNumber,
    required this.setUnit,
    required this.autoPaySetStatus,
    required this.enTrustName,
    required this.hiTrustName,
    required this.id,
    required this.productList,
    required this.image,
  });

  final String enName;
  final String hiName;
  final String enDescription;
  final String hiDescription;
  final String setType;
  final int setAmount;
  final String setTitle;
  final int setNumber;
  final String setUnit;
  final int autoPaySetStatus;
  final String enTrustName;
  final String hiTrustName;
  final int id;
  final List<ProductList> productList;
  final String image;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      enDescription: json["en_description"] ?? "",
      hiDescription: json["hi_description"] ?? "",
      setType: json["set_type"] ?? "",
      setAmount: json["set_amount"] ?? 0,
      setTitle: json["set_title"] ?? "",
      setNumber: json["set_number"] ?? 0,
      setUnit: json["set_unit"] ?? "",
      autoPaySetStatus: json["auto_pay_set_status"] ?? 0,
      enTrustName: json["en_trust_name"] ?? "",
      hiTrustName: json["hi_trust_name"] ?? "",
      id: json["id"] ?? 0,
      productList: json["product_list"] == null ? [] : List<ProductList>.from(json["product_list"]!.map((x) => ProductList.fromJson(x))),
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "en_name": enName,
    "hi_name": hiName,
    "en_description": enDescription,
    "hi_description": hiDescription,
    "set_type": setType,
    "set_amount": setAmount,
    "set_title": setTitle,
    "set_number": setNumber,
    "set_unit": setUnit,
    "auto_pay_set_status": autoPaySetStatus,
    "en_trust_name": enTrustName,
    "hi_trust_name": hiTrustName,
    "id": id,
    "product_list": productList.map((x) => x?.toJson()).toList(),
    "image": image,
  };

}

class ProductList {
  ProductList({
    required this.id,
    required this.setAmount,
    required this.enSetTitle,
    required this.hiSetTitle,
    required this.setNumber,
    required this.setUnit,
    required this.image,
  });

  final int id;
  final String setAmount;
  final String enSetTitle;
  final String hiSetTitle;
  final String setNumber;
  final String setUnit;
  final String image;

  factory ProductList.fromJson(Map<String, dynamic> json){
    return ProductList(
      id: json["id"] ?? 0,
      setAmount: json["set_amount"] ?? "",
      enSetTitle: json["en_set_title"] ?? "",
      hiSetTitle: json["hi_set_title"] ?? "",
      setNumber: json["set_number"] ?? "",
      setUnit: json["set_unit"] ?? "",
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "set_amount": setAmount,
    "en_set_title": enSetTitle,
    "hi_set_title": hiSetTitle,
    "set_number": setNumber,
    "set_unit": setUnit,
    "image": image,
  };

}
