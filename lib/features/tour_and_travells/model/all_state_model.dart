class TourAllStateModel {
  TourAllStateModel({
    required this.status,
    required this.count,
    required this.data,
  });

  final int status;
  final int count;
  final List<TourAllState> data;

  factory TourAllStateModel.fromJson(Map<String, dynamic> json) {
    return TourAllStateModel(
      status: json["status"] ?? 0,
      count: json["count"] ?? 0,
      data: json["data"] == null
          ? []
          : List<TourAllState>.from(
              json["data"]!.map((x) => TourAllState.fromJson(x))),
    );
  }
}

class TourAllState {
  TourAllState({
    required this.name,
    required this.logo,
  });

  final String name;
  final String logo;

  factory TourAllState.fromJson(Map<String, dynamic> json) {
    return TourAllState(
      name: json["name"] ?? "",
      logo: json["logo"] ?? "",
    );
  }
}
