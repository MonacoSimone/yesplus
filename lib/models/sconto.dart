import 'dart:convert';

Sconto scontoFromJson(String str) => Sconto.fromJson(json.decode(str));

String scontoToJson(Sconto data) => json.encode(data.toJson());

class Sconto {
  int mbpcId;
  int mbscProg;
  double mbscPerc;

  Sconto({
    required this.mbpcId,
    required this.mbscProg,
    required this.mbscPerc,
  });

  factory Sconto.fromJson(Map<String, dynamic> json) => Sconto(
        mbpcId: json["MBCF_MBPC_ID"],
        mbscProg: json["MBSC_Progr"] ?? 0,
        mbscPerc: json["MBSC_Perc"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "MBCF_MBPC_ID": mbpcId,
        "MBSC_Progr": mbscProg,
        "MBSC_Perc": mbscPerc,
      };
}
