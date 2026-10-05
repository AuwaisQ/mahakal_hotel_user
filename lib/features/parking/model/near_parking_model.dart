class NearParkingModel {
  bool? status;
  String? message;
  List<NearParking>? data;

  NearParkingModel({this.status, this.message, this.data});

  NearParkingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NearParking>[];
      json['data'].forEach((v) {
        data!.add(NearParking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NearParking {
  int? id;
  String? parkingName;
  String? parkingAddress;
  String? parkingLat;
  String? parkingLong;
  String? distance;
  String? vehicleName;
  dynamic price;
  List<String>? images;

  NearParking({
    this.id,
    this.parkingName,
    this.parkingAddress,
    this.parkingLat,
    this.parkingLong,
    this.distance,
    this.vehicleName,
    this.price,
    this.images,
  });

  NearParking.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? "");
    parkingName = json['parking_name']?.toString();
    parkingAddress = json['parking_address']?.toString();
    parkingLat = json['parking_lat']?.toString();
    parkingLong = json['parking_long']?.toString();
    distance = json['distance']?.toString();
    vehicleName = json['vehicle_name']?.toString();
    price = json['price'];
    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images'].map((x) => x.toString()));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parking_name'] = parkingName;
    data['parking_address'] = parkingAddress;
    data['parking_lat'] = parkingLat;
    data['parking_long'] = parkingLong;
    data['distance'] = distance;
    data['vehicle_name'] = vehicleName;
    data['price'] = price;
    data['images'] = images;
    return data;
  }
}
