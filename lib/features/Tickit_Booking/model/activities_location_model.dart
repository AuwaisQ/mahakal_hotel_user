class ActivitiesLocationListModel {
  ActivitiesLocationListModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final List<String> data;

  factory ActivitiesLocationListModel.fromJson(Map<String, dynamic> json){
    return ActivitiesLocationListModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? [] : List<String>.from(json["data"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recode": recode,
    "data": data.map((x) => x).toList(),
  };

}
