class EventLeadModel {
  EventLeadModel({
    required this.status,
    required this.message,
    required this.id,
  });

  final int status;
  final String message;
  final int id;

  factory EventLeadModel.fromJson(Map<String, dynamic> json) {
    return EventLeadModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      id: json["id"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "id": id,
      };

  @override
  String toString() {
    return "$status, $message, $id, ";
  }
}
