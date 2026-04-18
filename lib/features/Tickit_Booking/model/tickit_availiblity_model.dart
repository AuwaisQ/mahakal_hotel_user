class TickitAvailiblityModel {
  TickitAvailiblityModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final Data? data;

  factory TickitAvailiblityModel.fromJson(Map<String, dynamic> json){
    return TickitAvailiblityModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.packageList,
    required this.auditorium,
  });

  final List<ActivityPackageList> packageList;
  final Auditorium? auditorium;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      packageList: json["package_list"] == null ? [] : List<ActivityPackageList>.from(json["package_list"]!.map((x) => ActivityPackageList.fromJson(x))),
      auditorium: json["auditorium"] == null ? null : Auditorium.fromJson(json["auditorium"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "package_list": packageList.map((x) => x?.toJson()).toList(),
    "auditorium": auditorium?.toJson(),
  };

}

class Auditorium {
  Auditorium({
    required this.venueId,
    required this.venueName,
    required this.stageType,
    required this.totalRows,
    required this.seatsPerRow,
    required this.aislePositions,
    required this.rowStart,
    required this.rows,
    required this.timestamp,
    required this.blockedSeats,
    required this.totalSeats,
    required this.availableSeats,
    required this.booked,
  });

  final int venueId;
  final String venueName;
  final String stageType;
  final int totalRows;
  final int seatsPerRow;
  final List<int> aislePositions;
  final String rowStart;
  final List<LayoutRow> rows;
  final DateTime? timestamp;
  final List<BlockedSeat> blockedSeats;
  final int totalSeats;
  final int availableSeats;
  final List<Booked> booked;

  factory Auditorium.fromJson(Map<String, dynamic> json){
    return Auditorium(
      venueId: json["venue_id"] ?? 0,
      venueName: json["venue_name"] ?? "",
      stageType: json["stage_type"] ?? "",
      totalRows: json["total_rows"] ?? 0,
      seatsPerRow: json["seats_per_row"] ?? 0,
      aislePositions: json["aisle_positions"] == null ? [] : List<int>.from(json["aisle_positions"]!.map((x) => x)),
      rowStart: json["row_start"] ?? "",
      rows: json["rows"] == null ? [] : List<LayoutRow>.from(json["rows"]!.map((x) => LayoutRow.fromJson(x))),
      timestamp: DateTime.tryParse(json["timestamp"] ?? ""),
      blockedSeats: json["blocked_seats"] == null ? [] : List<BlockedSeat>.from(json["blocked_seats"]!.map((x) => BlockedSeat.fromJson(x))),
      totalSeats: json["total_seats"] ?? 0,
      availableSeats: json["available_seats"] ?? 0,
      booked: json["booked"] == null ? [] : List<Booked>.from(json["booked"]!.map((x) => Booked.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "venue_id": venueId,
    "venue_name": venueName,
    "stage_type": stageType,
    "total_rows": totalRows,
    "seats_per_row": seatsPerRow,
    "aisle_positions": aislePositions.map((x) => x).toList(),
    "row_start": rowStart,
    "rows": rows.map((x) => x?.toJson()).toList(),
    "timestamp": timestamp?.toIso8601String(),
    "blocked_seats": blockedSeats.map((x) => x?.toJson()).toList(),
    "total_seats": totalSeats,
    "available_seats": availableSeats,
    "booked": booked.map((x) => x?.toJson()).toList(),
  };

}

class BlockedSeat {
  BlockedSeat({
    required this.id,
    required this.row,
    required this.seat,
  });

  final String id;
  final int row;
  final int seat;

  factory BlockedSeat.fromJson(Map<String, dynamic> json){
    return BlockedSeat(
      id: json["id"] ?? "",
      row: json["row"] ?? 0,
      seat: json["seat"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "row": row,
    "seat": seat,
  };

}

class Booked {
  Booked({
    required this.seatInfo,
    required this.eventOrder,
  });

  final String seatInfo;
  final dynamic eventOrder;

  factory Booked.fromJson(Map<String, dynamic> json){
    return Booked(
      seatInfo: json["seat_info"] ?? "",
      eventOrder: json["event_order"],
    );
  }

  Map<String, dynamic> toJson() => {
    "seat_info": seatInfo,
    "event_order": eventOrder,
  };

}

class LayoutRow {
  LayoutRow({
    required this.id,
    required this.name,
    required this.type,
    required this.packageId,
    required this.color,
    required this.rowname,
    required this.price,
  });

  final int id;
  final String name;
  final String type;
  final int packageId;
  final String color;
  final String rowname;
  final String price;

  factory LayoutRow.fromJson(Map<String, dynamic> json){
    return LayoutRow(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      type: json["type"] ?? "",
      packageId: json["package_id"] ?? 0,
      color: json["color"] ?? "",
      rowname: json["rowname"] ?? "",
      price: json["price"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "package_id": packageId,
    "color": color,
    "rowname": rowname,
    "price": price,

  };

}

class ActivityPackageList {
  ActivityPackageList({
    required this.packageId,
    required this.enPackageName,
    required this.hiPackageName,
    required this.hiPackageDetails,
    required this.enPackageDetails,
    required this.price,
    required this.type,
    required this.remainingSeats,
    required this.totalSeats,
    required this.available,
  });

  final String packageId;
  final String enPackageName;
  final String hiPackageName;
  final String hiPackageDetails;
  final String enPackageDetails;
  final String price;
  final String type;
  final String remainingSeats;
  final String totalSeats;
  final bool available;

  factory ActivityPackageList.fromJson(Map<String, dynamic> json){
    return ActivityPackageList(
      packageId: json["package_id"] ?? "",
      enPackageName: json["en_package_name"] ?? "",
      hiPackageName: json["hi_package_name"] ?? "",
      hiPackageDetails: json["hi_package_details"] ?? "",
      enPackageDetails: json["en_package_details"] ?? "",
      price: json["price"] ?? "",
      type: json["type"] ?? "",
      remainingSeats: json["remaining_seats"] ?? "",
      totalSeats: json["total_seats"] ?? "",
      available: json["available"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "package_id": packageId,
    "en_package_name": enPackageName,
    "hi_package_name": hiPackageName,
    "hi_package_details": hiPackageDetails,
    "en_package_details": enPackageDetails,
    "price": price,
    "type": type,
    "remaining_seats": remainingSeats,
    "total_seats": totalSeats,
    "available": available,
  };

}
