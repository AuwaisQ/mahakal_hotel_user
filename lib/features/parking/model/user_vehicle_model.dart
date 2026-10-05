class UserVehicleModel {
  bool? status;
  bool? success;
  String? message;
  List<UserVehicle>? data;

  UserVehicleModel({this.status, this.success, this.message, this.data});

  UserVehicleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UserVehicle>[];
      json['data'].forEach((v) {
        data!.add(UserVehicle.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserVehicle {
  int? id;
  String? cabName;
  int? vehicleId;
  String? cabRegisterNumber;
  String? color;
  String? userName;
  String? userPhone;
  String? aadhar;

  UserVehicle({
    this.id,
    this.cabName,
    this.vehicleId,
    this.cabRegisterNumber,
    this.color,
    this.userName,
    this.userPhone,
    this.aadhar,
  });

  UserVehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? "");
    cabName = json['cab_name']?.toString();
    vehicleId = json['vehicle_id'] is int ? json['vehicle_id'] : int.tryParse(json['vehicle_id']?.toString() ?? "");
    cabRegisterNumber = json['cab_register_number']?.toString();
    color = json['color']?.toString();
    userName = json['user_name']?.toString();
    userPhone = json['user_phone']?.toString();
    aadhar = json['aadhar']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cab_name'] = cabName;
    data['vehicle_id'] = vehicleId;
    data['cab_register_number'] = cabRegisterNumber;
    data['color'] = color;
    data['user_name'] = userName;
    data['user_phone'] = userPhone;
    data['aadhar'] = aadhar;
    return data;
  }
}
