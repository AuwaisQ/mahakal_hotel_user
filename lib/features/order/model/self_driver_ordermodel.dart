// To parse this JSON data, do
//
//     final selfDriverOrder = selfDriverOrderFromJson(jsonString);

import 'dart:convert';

SelfDriverOrder selfDriverOrderFromJson(String str) => SelfDriverOrder.fromJson(json.decode(str));

String selfDriverOrderToJson(SelfDriverOrder data) => json.encode(data.toJson());

class SelfDriverOrder {
  int? status;
  String? message;
  List<SelfList>? selfList;

  SelfDriverOrder({
    this.status,
    this.message,
    this.selfList,
  });

  factory SelfDriverOrder.fromJson(Map<String, dynamic> json) => SelfDriverOrder(
    status: json['status'],
    message: json['message'],
    selfList: json['self_list'] == null ? [] : List<SelfList>.from(json['self_list']!.map((x) => SelfList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'self_list': selfList == null ? [] : List<dynamic>.from(selfList!.map((x) => x.toJson())),
  };
}

class SelfList {
  int? id;
  String? orderId;
  int? price;
  String? orderStatus;
  String? thumbnail;
  String? serviceName;

  SelfList({
    this.id,
    this.orderId,
    this.price,
    this.orderStatus,
    this.thumbnail,
    this.serviceName,
  });

  factory SelfList.fromJson(Map<String, dynamic> json) => SelfList(
    id: json['id'],
    orderId: json['order_id'],
    price: json['price'],
    orderStatus: json['order_status'],
    thumbnail: json['thumbnail'],
    serviceName: json['service_name'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'price': price,
    'order_status': orderStatus,
    'thumbnail': thumbnail,
    'service_name': serviceName,
  };
}
