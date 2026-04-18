class CityListModel {
  CityListModel({
    required this.status,
    required this.message,
    required this.citylist,
    required this.state,
  });

  final bool status;
  final String message;
  final List<Citylist> citylist;
  final State? state;

  factory CityListModel.fromJson(Map<String, dynamic> json) {
    return CityListModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      citylist: json["citylist"] == null
          ? []
          : List<Citylist>.from(
              json["citylist"]!.map((x) => Citylist.fromJson(x))),
      state: json["state"] == null ? null : State.fromJson(json["state"]),
    );
  }
}

class Citylist {
  Citylist({
    required this.id,
    required this.cityId,
    required this.name,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  final int id;
  final int cityId;
  final String name;
  final int pincode;
  final double latitude;
  final double longitude;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic> translations;

  factory Citylist.fromJson(Map<String, dynamic> json) {
    return Citylist(
      id: json["id"] ?? 0,
      cityId: json["city_id"] ?? 0,
      name: json["name"] ?? "",
      pincode: json["pincode"] ?? 0,
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      translations: json["translations"] == null
          ? []
          : List<dynamic>.from(json["translations"]!.map((x) => x)),
    );
  }
}

class State {
  State({
    required this.id,
    required this.stateId,
    required this.states,
    required this.translations,
  });

  final int id;
  final int stateId;
  final States? states;
  final List<dynamic> translations;

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json["id"] ?? 0,
      stateId: json["state_id"] ?? 0,
      states: json["states"] == null ? null : States.fromJson(json["states"]),
      translations: json["translations"] == null
          ? []
          : List<dynamic>.from(json["translations"]!.map((x) => x)),
    );
  }
}

class States {
  States({
    required this.id,
    required this.name,
    required this.countryId,
  });

  final int id;
  final String name;
  final int countryId;

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      countryId: json["country_id"] ?? 0,
    );
  }
}
