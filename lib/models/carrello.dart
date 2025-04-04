// To parse this JSON data, do
//
//     final carrello = carrelloFromJson(jsonString);

import 'dart:convert';
import 'dart:ffi';

import 'package:get/get.dart';

Carrello carrelloFromJson(String str) => Carrello.fromJson(json.decode(str));

String carrelloToJson(Carrello data) => json.encode(data.toJson());

class Carrello {
  RxDouble totale;
  RxDouble subtotale;
  RxDouble tasse;
  int sconti;
  List<ProdottoCarrello> prodotto;

  Carrello({
    required this.totale,
    required this.subtotale,
    required this.tasse,
    this.sconti = 0,
    required this.prodotto,
  });

  factory Carrello.fromJson(Map<String, dynamic> json) => Carrello(
        totale: json["totale"],
        subtotale: json["subtotale"],
        tasse: json["tasse"],
        sconti: json["sconti"],
        prodotto: List<ProdottoCarrello>.from(
            json["prodotti"].map((x) => ProdottoCarrello.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totale": totale,
        "subtotale": subtotale,
        "tasse": tasse,
        "sconti": sconti,
        "prodotti": List<dynamic>.from(prodotto.map((x) => x.toJson())),
      };
}

class ProdottoCarrello {
  int idProdotto;
  String nomeProdotto;
  RxDouble quantita;
  double? prezzoListino;
  double prezzo;
  RxDouble totale;
  double sconti;
  int iva;
  int idIva;
  String UM;
  double? sconto1;
  double? sconto2;
  double? sconto3;

  ProdottoCarrello(
      {required this.idProdotto,
      required this.nomeProdotto,
      required this.quantita,
      required this.prezzo,
      required this.totale,
      required this.iva,
      required this.idIva,
      required this.sconti,
      required this.prezzoListino,
      required this.UM,
      this.sconto1,
      this.sconto2,
      this.sconto3});

  factory ProdottoCarrello.fromJson(Map<String, dynamic> json) =>
      ProdottoCarrello(
        idProdotto: json["idProdotto"],
        nomeProdotto: json["nomeProdotto"],
        quantita: json["quantita"],
        prezzo: json["prezzo"],
        totale: json["totale"],
        iva: json["iva"],
        idIva: json["idIva"],
        sconti: json["sconti"],
        prezzoListino: json["prezzoListino"]?.toDouble(),
        UM: json["UM"],
        sconto1: json["sconto1"]?.toDouble(),
        sconto2: json["sconto2"]?.toDouble(),
        sconto3: json["sconto3"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "idProdotto": idProdotto,
        "nomeProdotto": nomeProdotto,
        "quantita": quantita,
        "prezzo": prezzo,
        "sconti": sconti,
        "iva": iva,
        "idIva": idIva,
        "prezzoListino": prezzoListino,
        "UM": UM,
        "sconto1": sconto1,
        "sconto2": sconto2,
        "sconto3": sconto3,
      };
}
