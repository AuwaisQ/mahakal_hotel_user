class ParkingDetailsModel {
  bool? success;
  ParkingDetails? data;

  ParkingDetailsModel({this.success, this.data});

  ParkingDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ParkingDetails.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ParkingDetails {
  int? id;
  int? vendorId;
  String? parkingNameEn;
  String? parkingNameHi;
  String? parkingAddress;
  String? parkingLat;
  String? parkingLong;
  String? servicesEn;
  String? servicesHi;
  List<Slabs>? slabs;

  ParkingDetails({
    this.id,
    this.vendorId,
    this.parkingNameEn,
    this.parkingNameHi,
    this.parkingAddress,
    this.parkingLat,
    this.parkingLong,
    this.servicesEn,
    this.servicesHi,
    this.slabs,
  });

  ParkingDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    parkingNameEn = json['parking_name_en'];
    parkingNameHi = json['parking_name_hi'];
    parkingAddress = json['parking_address'];
    parkingLat = json['parking_lat'];
    parkingLong = json['parking_long'];
    servicesEn = json['services_en'];
    servicesHi = json['services_hi'];
    if (json['slabs'] != null) {
      slabs = <Slabs>[];
      json['slabs'].forEach((v) {
        slabs!.add(Slabs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vendor_id'] = vendorId;
    data['parking_name_en'] = parkingNameEn;
    data['parking_name_hi'] = parkingNameHi;
    data['parking_address'] = parkingAddress;
    data['parking_lat'] = parkingLat;
    data['parking_long'] = parkingLong;
    data['services_en'] = servicesEn;
    data['services_hi'] = servicesHi;
    if (slabs != null) {
      data['slabs'] = slabs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slabs {
  int? id;
  String? from;
  String? to;
  String? price;

  Slabs({this.id, this.from, this.to, this.price});

  Slabs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    from = json['from']?.toString();
    to = json['to']?.toString();
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from'] = from;
    data['to'] = to;
    data['price'] = price;
    return data;
  }
}
