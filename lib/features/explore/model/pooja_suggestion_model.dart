// To parse this JSON data, do
//
//     final prayerSuggestion = prayerSuggestionFromJson(jsonString);

import 'dart:convert';

PrayerSuggestion prayerSuggestionFromJson(String str) => PrayerSuggestion.fromJson(json.decode(str));

String prayerSuggestionToJson(PrayerSuggestion data) => json.encode(data.toJson());

class PrayerSuggestion {
  final int? status;
  final PrayerSuggestionClass? prayerSuggestion;

  PrayerSuggestion({
    this.status,
    this.prayerSuggestion,
  });

  factory PrayerSuggestion.fromJson(Map<String, dynamic> json) => PrayerSuggestion(
    status: json["status"],
    prayerSuggestion: json["prayerSuggestion"] == null ? null : PrayerSuggestionClass.fromJson(json["prayerSuggestion"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "prayerSuggestion": prayerSuggestion?.toJson(),
  };
}

class PrayerSuggestionClass {
  final String? summary;
  final List<Suggestion>? suggestions;

  PrayerSuggestionClass({
    this.summary,
    this.suggestions,
  });

  factory PrayerSuggestionClass.fromJson(Map<String, dynamic> json) => PrayerSuggestionClass(
    summary: json["summary"],
    suggestions: json["suggestions"] == null ? [] : List<Suggestion>.from(json["suggestions"]!.map((x) => Suggestion.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "summary": summary,
    "suggestions": suggestions == null ? [] : List<dynamic>.from(suggestions!.map((x) => x.toJson())),
  };
}

class Suggestion {
  final bool? status;
  final int? priority;
  final String? title;
  final String? pujaId;
  final String? summary;
  final String? oneLine;

  Suggestion({
    this.status,
    this.priority,
    this.title,
    this.pujaId,
    this.summary,
    this.oneLine,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
    status: json["status"],
    priority: json["priority"],
    title: json["title"],
    pujaId: json["puja_id"],
    summary: json["summary"],
    oneLine: json["one_line"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "priority": priority,
    "title": title,
    "puja_id": pujaId,
    "summary": summary,
    "one_line": oneLine,
  };
}
