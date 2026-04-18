class DarshanModel {
  int? status;
  String? message;
  int? recode;
  List<DarshanData>? data;

  DarshanModel({this.status, this.message, this.recode, this.data});

  DarshanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    recode = json['recode'];
    if (json['data'] != null) {
      data = <DarshanData>[];
      json['data'].forEach((v) {
        data!.add(DarshanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['recode'] = recode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DarshanData {
  String? enName;
  String? enShortDescription;
  String? image;
  int? id;
  String? hiName;
  String? hiShortDescription;

  DarshanData(
      {this.enName,
      this.enShortDescription,
      this.image,
      this.id,
      this.hiName,
      this.hiShortDescription});

  DarshanData.fromJson(Map<String, dynamic> json) {
    enName = json['en_name'];
    enShortDescription = json['en_short_description'];
    image = json['image'];
    id = json['id'];
    hiName = json['hi_name'];
    hiShortDescription = json['hi_short_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en_name'] = enName;
    data['en_short_description'] = enShortDescription;
    data['image'] = image;
    data['id'] = id;
    data['hi_name'] = hiName;
    data['hi_short_description'] = hiShortDescription;
    return data;
  }
}
