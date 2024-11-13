// To parse this JSON data, do
//
//     final tipoOrdine = tipoOrdineFromJson(jsonString);

import 'dart:convert';

Agente agenteFromJson(String str) => Agente.fromJson(json.decode(str));

String agenteToJson(Agente data) => json.encode(data.toJson());

class Agente {
  int mbagId;
  int mbagMbanId;
  String mbanRagSoc;
  Agente({
    required this.mbagId,
    required this.mbagMbanId,
    required this.mbanRagSoc,
  });

  factory Agente.fromJson(Map<String, dynamic> json) => Agente(
      mbagId: json["MBAG_ID"],
      mbagMbanId: json["MBAG_MBAN_ID"],
      mbanRagSoc: json["MBAN_RagSoc"]);

  Map<String, dynamic> toJson() => {
        "MBAG_ID": mbagId,
        "MBAG_MBAN_ID": mbagMbanId,
        "MBAN_RagSoc": mbanRagSoc,
      };
}
