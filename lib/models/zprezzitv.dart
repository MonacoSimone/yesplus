import 'dart:convert';

PrezziTV prezziTVFromJson(String str) => PrezziTV.fromJson(json.decode(str));

String prezziTVToJson(PrezziTV data) => json.encode(data.toJson());

class PrezziTV {
  int zptvId;
  int zptvMgaaId;
  int? zptvMbpcId;
  double zptvPrezzo;
  double? zptvSconto1;
  double? zptvSconto2;
  double? zptvSconto3;

  PrezziTV({
    required this.zptvId,
    required this.zptvMgaaId,
    required this.zptvMbpcId,
    required this.zptvPrezzo,
    required this.zptvSconto1,
    required this.zptvSconto2,
    required this.zptvSconto3,
  });

  factory PrezziTV.fromJson(Map<String, dynamic> json) => PrezziTV(
        zptvId: json["ZPTV_Id"],
        zptvMgaaId: json["ZPTV_MGAA_Id"] ?? 0,
        zptvMbpcId: json["ZPTV_MBPC_Id"],
        zptvPrezzo: json["ZPTV_Prezzo"]?.toDouble(),
        zptvSconto1: json["ZPTV_Sconto1"]?.toDouble(),
        zptvSconto2: json["ZPTV_Sconto2"]?.toDouble(),
        zptvSconto3: json["ZPTV_Sconto3"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "ZPTV_Id": zptvId,
        "ZPTV_MGAA_Id": zptvMgaaId,
        "ZPTV_MBPC_Id": zptvMbpcId,
        "ZPTV_Prezzo": zptvPrezzo,
        "ZPTV_Sconto1": zptvSconto1,
        "ZPTV_Sconto2": zptvSconto2,
        "ZPTV_Sconto3": zptvSconto3,
      };
}
