import 'dart:convert';

TipoFattura tipoFatturaFromJson(String str) =>
    TipoFattura.fromJson(json.decode(str));

String tipoFatturaToJson(TipoFattura data) => json.encode(data.toJson());

class TipoFattura {
  int fttiId;
  String fttiDescr;
  int fttiTipNum;
  int fttiTipo;
  int fttiInStatistica;
  int fttiNaturaFattura;

  TipoFattura(
      {required this.fttiId,
      required this.fttiDescr,
      required this.fttiTipNum,
      required this.fttiTipo,
      required this.fttiInStatistica,
      required this.fttiNaturaFattura});

  factory TipoFattura.fromJson(Map<String, dynamic> json) => TipoFattura(
      fttiId: json["FTTI_ID"],
      fttiDescr: json["FTTI_Descr"],
      fttiTipNum: json["FTTI_TipNum"],
      fttiTipo: json["FTTI_Tipo"],
      fttiInStatistica: json["FTTI_FattureInStatistica"] ?? 0,
      fttiNaturaFattura: json["FTTI_NaturaFattura"] ?? 0);

  Map<String, dynamic> toJson() => {
        "FTTI_ID": fttiId,
        "FTTI_Descr": fttiDescr,
        "FTTI_TipNum": fttiTipNum,
        "FTTI_Tipo": fttiTipo,
        "FTTI_FattureInStatistica": fttiInStatistica,
        "FTTI_NaturaFattura": fttiNaturaFattura
      };
}
