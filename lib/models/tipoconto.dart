// To parse this JSON data, do
//
//     final tipoBolla = tipoBollaFromJson(jsonString);

import 'dart:convert';

TipoConto tipoContoFromJson(String str) => TipoConto.fromJson(json.decode(str));

String tipoContoToJson(TipoConto data) => json.encode(data.toJson());

class TipoConto {
  int mbtcId;
  String mbtcDescr;
  int mbtcTipoConto;
  String mbtcCode;

  TipoConto({
    required this.mbtcId,
    required this.mbtcDescr,
    required this.mbtcTipoConto,
    required this.mbtcCode,
  });

  factory TipoConto.fromJson(Map<String, dynamic> json) => TipoConto(
        mbtcId: json["MBTC_Id"],
        mbtcDescr: json["MBTC_Descr"] ?? '',
        mbtcTipoConto: json["MBTC_TipoConto"] ?? 0,
        mbtcCode: json["MBTC_Code"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "MBTC_Id": mbtcId,
        "MBTC_Descr": mbtcDescr,
        "MBTC_TipoConto": mbtcTipoConto,
        "MBTC_Code": mbtcCode,
      };
}
