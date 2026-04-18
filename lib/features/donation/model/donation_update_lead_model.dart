class DonationUpdateLeadModel {
  DonationUpdateLeadModel({
    required this.status,
    required this.message,
    required this.recode,
    required this.data,
  });

  final int status;
  final String message;
  final int recode;
  final Data? data;

  factory DonationUpdateLeadModel.fromJson(Map<String, dynamic> json) {
    return DonationUpdateLeadModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      recode: json["recode"] ?? 0,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.id,
    required this.subscriptionId,
  });

  final String id;
  final String subscriptionId;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? "",
      subscriptionId: json["subscription_id"] ?? "",
    );
  }
}
