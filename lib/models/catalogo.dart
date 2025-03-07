// To parse this JSON data, do
//
//     final catalogo = catalogoFromJson(jsonString);

import 'dart:convert';

Catalogo catalogoFromJson(String str) => Catalogo.fromJson(json.decode(str));

String catalogoToJson(Catalogo data) => json.encode(data.toJson());

class Catalogo {
  List<Prodotto> prodotti;

  Catalogo({
    required this.prodotti,
  });

  factory Catalogo.fromJson(Map<String, dynamic> json) => Catalogo(
        prodotti: List<Prodotto>.from(
            json["prodotti"].map((x) => Prodotto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "prodotti": List<dynamic>.from(prodotti.map((x) => x.toJson())),
      };
}

class Prodotto {
  int id;
  String descrizione;
  String matricola;
  int idIva;
  String classe;
  String unMis;
  double prezzo;
  int stato;
  double sconto1 = 0.0;
  double sconto2 = 0.0;
  double sconto3 = 0.0;

  Prodotto(
      {required this.id,
      required this.classe,
      required this.matricola,
      required this.idIva,
      required this.descrizione,
      required this.unMis,
      required this.prezzo,
      required this.stato,
      required this.sconto1,
      required this.sconto2,
      required this.sconto3});

  factory Prodotto.fromJson(Map<String, dynamic> json) => Prodotto(
      id: json["MGAA_ID"],
      classe: json["MGAA_MBDC_Classe"],
      matricola: json["MGAA_Matricola"],
      descrizione: json["MGAA_Descr"],
      unMis: json["MGAA_MBUM_Codice"],
      idIva: json["MGAA_MBIV_ID"] ?? 0,
      prezzo: json["MGAA_PVendita"]?.toDouble() ?? 0.0,
      stato: json["MGAA_Stato"],
      sconto1: json["Sconto1"]?.toDouble() ?? 0.0,
      sconto2: json["Sconto2"]?.toDouble() ?? 0.0,
      sconto3: json["Sconto3"]?.toDouble() ?? 0.0);

  Map<String, dynamic> toJson() => {
        "MGAA_ID": id,
        "MGAA_MBDC_Classe": classe,
        "MGAA_Matricola": matricola,
        "MGAA_Descr": descrizione,
        "MGAA_MBUM_Codice": unMis,
        "MGAA_PVendita": prezzo,
        "MGAA_Stato": stato,
        "MGAA_MBIV_ID": idIva,
        "Sconto1": sconto1,
        "Sconto2": sconto2,
        "Sconto3": sconto3
      };
}
