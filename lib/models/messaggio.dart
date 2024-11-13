// To parse this JSON data, do
//
//     final messaggio = messaggioFromJson(jsonString);

import 'dart:convert';

List<Messaggio> messaggioFromJson(String str) =>
    List<Messaggio>.from(json.decode(str).map((x) => Messaggio.fromJson(x)));

String messaggioToJson(List<Messaggio> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Messaggio {
  int? metsId;
  String metsMessage;
  String metsDataSave;

  Messaggio({
    this.metsId,
    required this.metsMessage,
    required this.metsDataSave,
  });

  factory Messaggio.fromJson(Map<String, dynamic> json) => Messaggio(
        metsId: json["METS_ID"],
        metsMessage: json["METS_Message"],
        metsDataSave: json["METS_DataSave"],
      );

  Map<String, dynamic> toJson() => {
        "METS_ID": metsId,
        "METS_Message": metsMessage,
        "METS_DataSave": metsDataSave,
      };
}
