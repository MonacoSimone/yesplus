// To parse this JSON data, do
//
//     final mbCliForDest = mbCliForDestFromJson(jsonString);

import 'dart:convert';

MbCliForDest mbCliForDestFromJson(String str) =>
    MbCliForDest.fromJson(json.decode(str));

String mbCliForDestToJson(MbCliForDest data) => json.encode(data.toJson());

class MbCliForDest {
  int mbdId;
  String? mbdDestinatario;
  int? mbdMbanId;

  MbCliForDest({
    required this.mbdId,
    this.mbdDestinatario,
    this.mbdMbanId,
  });

  factory MbCliForDest.fromJson(Map<String, dynamic> json) => MbCliForDest(
        mbdId: json["MBDT_ID"],
        mbdDestinatario: json["MBDT_Destinatario"],
        mbdMbanId: json["MBDT_MBAN_ID"],
      );

  Map<String, dynamic> toJson() => {
        "MBDT_ID": mbdId,
        "MBDT_Destinatario": mbdDestinatario,
        "MBDT_MBAN_ID": mbdMbanId,
      };
}
