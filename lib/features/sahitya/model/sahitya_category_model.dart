class SahityaCategoryModel {
  SahityaCategoryModel({
    required this.status,
    required this.data,
  });

  final int status;
  final List<SahityaData> data;

  factory SahityaCategoryModel.fromJson(Map<String, dynamic> json) {
    return SahityaCategoryModel(
      status: json["status"] ?? 0,
      data: json["data"] == null
          ? []
          : List<SahityaData>.from(
              json["data"]!.map((x) => SahityaData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$status, $data, ";
  }
}

class SahityaData {
  SahityaData({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.image,
  });

  final int id;
  final String enName;
  final String hiName;
  final String image;

  factory SahityaData.fromJson(Map<String, dynamic> json) {
    return SahityaData(
      id: json["id"] ?? 0,
      enName: json["en_name"] ?? "",
      hiName: json["hi_name"] ?? "",
      image: json["image"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en_name": enName,
        "hi_name": hiName,
        "image": image,
      };

  @override
  String toString() {
    return "$id, $enName, $hiName, $image, ";
  }
}
