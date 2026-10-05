class VehicleTypeModel {
  bool? success;
  bool? status;
  List<VehicleType>? data;

  VehicleTypeModel({this.success, this.status, this.data});

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    if (json['data'] != null) {
      data = <VehicleType>[];
      json['data'].forEach((v) {
        data!.add(VehicleType.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleType {
  int? id;
  String? nameEn;
  String? nameHi;
  String? image;

  VehicleType({this.id, this.nameEn, this.nameHi, this.image});

  VehicleType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameEn = json['name_en'];
    nameHi = json['name_hi'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name_en'] = nameEn;
    data['name_hi'] = nameHi;
    data['image'] = image;
    return data;
  }
}
