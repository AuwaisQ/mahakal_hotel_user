// To parse this JSON data, do
//
//     final pdfDataModel = pdfDataModelFromJson(jsonString);

import 'dart:convert';

PdfDataModel pdfDataModelFromJson(String str) =>
    PdfDataModel.fromJson(json.decode(str));

String pdfDataModelToJson(PdfDataModel data) => json.encode(data.toJson());

class PdfDataModel {
  int status;
  String message;
  int recode;
  List<Pdf> pdf;

  PdfDataModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.pdf,
  });

  factory PdfDataModel.fromJson(Map<String, dynamic> json) => PdfDataModel(
        status: json["status"],
        message: json["message"],
        recode: json["recode"],
        pdf: List<Pdf>.from(json["pdf"].map((x) => Pdf.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recode": recode,
        "pdf": List<dynamic>.from(pdf.map((x) => x.toJson())),
      };
}

class Pdf {
  int id;
  String enDescription;
  String enShortDescription;
  String hiDescription;
  String hiShortDescription;
  int sellingPrice;
  String name;
  String type;
  int pages;
  String image;

  Pdf({
    required this.id,
    required this.enDescription,
    required this.enShortDescription,
    required this.hiDescription,
    required this.hiShortDescription,
    required this.sellingPrice,
    required this.name,
    required this.type,
    required this.pages,
    required this.image,
  });

  factory Pdf.fromJson(Map<String, dynamic> json) => Pdf(
        id: json["id"],
        enDescription: json["en_description"],
        enShortDescription: json["en_short_description"],
        hiDescription: json["hi_description"],
        hiShortDescription: json["hi_short_description"],
        sellingPrice: json["selling_price"],
        name: json["name"],
        type: json["type"],
        pages: json["pages"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_description": enDescription,
        "en_short_description": enShortDescription,
        "hi_description": hiDescription,
        "hi_short_description": hiShortDescription,
        "selling_price": sellingPrice,
        "name": name,
        "type": type,
        "pages": pages,
        "image": image,
      };
}
