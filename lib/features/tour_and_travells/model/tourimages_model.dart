class TourImagesModel {
  TourImagesModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final List<String> data;

  factory TourImagesModel.fromJson(Map<String, dynamic> json) {
    return TourImagesModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null
          ? []
          : List<String>.from(json["data"]!.map((x) => x)),
    );
  }
}
