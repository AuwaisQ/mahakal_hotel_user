class CheckAvailablityModel {
  CheckAvailablityModel({
    required this.status,
    required this.data,
  });

  final bool status;
  final Data? data;

  factory CheckAvailablityModel.fromJson(Map<String, dynamic> json){
    return CheckAvailablityModel(
      status: json["status"] ?? false,
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };

}

class Data {
  Data({
    required this.rooms,
  });

  final List<Room> rooms;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      rooms: json["rooms"] == null ? [] : List<Room>.from(json["rooms"]!.map((x) => Room.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "rooms": rooms.map((x) => x?.toJson()).toList(),
  };

}

class Room {
  Room({
    required this.id,
    required this.title,
    required this.price,
    required this.sizeHtml,
    required this.bedsHtml,
    required this.adultsHtml,
    required this.childrenHtml,
    required this.numberSelected,
    required this.number,
    required this.minDayStays,
    required this.image,
    required this.tmpNumber,
    required this.gallery,
    required this.priceHtml,
    required this.priceText,
    required this.terms,
    required this.termFeatures,
  });

  final int id;
  final String title;
  final int price;
  final String sizeHtml;
  final String bedsHtml;
  final String adultsHtml;
  final String childrenHtml;
   int numberSelected;
  final int number;
  final int minDayStays;
  final String image;
  final int tmpNumber;
  final List<Gallery> gallery;
  final String priceHtml;
  final String priceText;
  final Terms? terms;
  final List<TermFeature> termFeatures;

  factory Room.fromJson(Map<String, dynamic> json){
    return Room(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      price: json["price"] ?? 0,
      sizeHtml: json["size_html"] ?? "",
      bedsHtml: json["beds_html"] ?? "",
      adultsHtml: json["adults_html"] ?? "",
      childrenHtml: json["children_html"] ?? "",
      numberSelected: json["number_selected"] ?? 0,
      number: json["number"] ?? 0,
      minDayStays: json["min_day_stays"] ?? 0,
      image: json["image"] ?? "",
      tmpNumber: json["tmp_number"] ?? 0,
      gallery: json["gallery"] == null ? [] : List<Gallery>.from(json["gallery"]!.map((x) => Gallery.fromJson(x))),
      priceHtml: json["price_html"] ?? "",
      priceText: json["price_text"] ?? "",
      terms: json["terms"] == null ? null : Terms.fromJson(json["terms"]),
      termFeatures: json["term_features"] == null ? [] : List<TermFeature>.from(json["term_features"]!.map((x) => TermFeature.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "size_html": sizeHtml,
    "beds_html": bedsHtml,
    "adults_html": adultsHtml,
    "children_html": childrenHtml,
    "number_selected": numberSelected,
    "number": number,
    "min_day_stays": minDayStays,
    "image": image,
    "tmp_number": tmpNumber,
    "gallery": gallery.map((x) => x?.toJson()).toList(),
    "price_html": priceHtml,
    "price_text": priceText,
    "terms": terms?.toJson(),
    "term_features": termFeatures.map((x) => x?.toJson()).toList(),
  };

}

class Gallery {
  Gallery({
    required this.large,
    required this.thumb,
  });

  final String large;
  final String thumb;

  factory Gallery.fromJson(Map<String, dynamic> json){
    return Gallery(
      large: json["large"] ?? "",
      thumb: json["thumb"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "large": large,
    "thumb": thumb,
  };

}

class TermFeature {
  TermFeature({
    required this.icon,
    required this.title,
  });

  final String icon;
  final String title;

  factory TermFeature.fromJson(Map<String, dynamic> json){
    return TermFeature(
      icon: json["icon"] ?? "",
      title: json["title"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "icon": icon,
    "title": title,
  };

}

class Terms {
  Terms({
    required this.the8,
  });

  final The8? the8;

  factory Terms.fromJson(Map<String, dynamic> json){
    return Terms(
      the8: json["8"] == null ? null : The8.fromJson(json["8"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "8": the8?.toJson(),
  };

}

class The8 {
  The8({
    required this.parent,
    required this.child,
  });

  final Parent? parent;
  final List<Child> child;

  factory The8.fromJson(Map<String, dynamic> json){
    return The8(
      parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
      child: json["child"] == null ? [] : List<Child>.from(json["child"]!.map((x) => Child.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "parent": parent?.toJson(),
    "child": child.map((x) => x?.toJson()).toList(),
  };

}

class Child {
  Child({
    required this.id,
    required this.title,
    required this.content,
    required this.imageId,
    required this.icon,
    required this.attrId,
    required this.slug,
  });

  final int id;
  final String title;
  final dynamic content;
  final dynamic imageId;
  final String icon;
  final int attrId;
  final String slug;

  factory Child.fromJson(Map<String, dynamic> json){
    return Child(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      content: json["content"],
      imageId: json["image_id"],
      icon: json["icon"] ?? "",
      attrId: json["attr_id"] ?? 0,
      slug: json["slug"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "image_id": imageId,
    "icon": icon,
    "attr_id": attrId,
    "slug": slug,
  };

}

class Parent {
  Parent({
    required this.id,
    required this.title,
    required this.slug,
    required this.service,
    required this.displayType,
    required this.hideInSingle,
  });

  final int id;
  final String title;
  final String slug;
  final String service;
  final dynamic displayType;
  final dynamic hideInSingle;

  factory Parent.fromJson(Map<String, dynamic> json){
    return Parent(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      slug: json["slug"] ?? "",
      service: json["service"] ?? "",
      displayType: json["display_type"],
      hideInSingle: json["hide_in_single"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "service": service,
    "display_type": displayType,
    "hide_in_single": hideInSingle,
  };

}
