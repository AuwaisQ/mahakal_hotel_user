class ActivitiesCategoryModel {
  ActivitiesCategoryModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<AcitivityCategoryList> data;

  factory ActivitiesCategoryModel.fromJson(Map<String, dynamic> json){
    return ActivitiesCategoryModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? [] : List<AcitivityCategoryList>.from(json["data"]!.map((x) => AcitivityCategoryList.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data.map((x) => x?.toJson()).toList(),
  };

}

class AcitivityCategoryList {
  AcitivityCategoryList({
    required this.enCategoryName,
    required this.hiCategoryName,
    required this.id,
    required this.image,
  });

  final String enCategoryName;
  final String hiCategoryName;
  final int id;
  final String image;

  factory AcitivityCategoryList.fromJson(Map<String, dynamic> json){
    return AcitivityCategoryList(
      enCategoryName: json["en_category_name"] ?? "",
      hiCategoryName: json["hi_category_name"] ?? "",
      id: json["id"] ?? 0,
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "en_category_name": enCategoryName,
    "hi_category_name": hiCategoryName,
    "id": id,
    "image": image,
  };

}
