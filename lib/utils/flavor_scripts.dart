import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/web.dart';

class FlavorScripts {
  // Variabile di classe per mantenere il nome del flavor attivo
  static String _flavor = 'default';
  var logger = Logger();
  static Map<String, dynamic> _config = {};

  // Imposta il flavor corrente (ad esempio: 'clienteA', 'clienteB', ecc.)
  Future<void> setFlavor(String packageName) async {
    String flavor = packageName.split('.').last;
    _flavor = flavor;
    logger.i("Flavor attuale impostato a: $_flavor");
  }

  // Restituisce il flavor corrente
  String getFlavor() {
    return _flavor;
  }

  // Carica un file di configurazione specifico per il flavor corrente
  Future<void> loadConfig() async {
    try {
      //String path = 'assets/$_flavor/$configFile.json';
      String path = 'assets/json/features_config.json';
      String data = await rootBundle.loadString(path);
      _config = json.decode(data);
    } catch (e) {
      logger.e("Errore nel caricamento della configurazione: $e");
    }
  }

  // Carica immagini specifiche per il flavor corrente
  String getAssetImagePath(String imageName) {
    return 'assets/$_flavor/images/$imageName';
  }

  // Funzione per loggare il flavor corrente
  void logCurrentFlavor() {
    logger.i("Flavor attuale: $_flavor");
  }

  // Verifica se una specifica feature è abilitata
  Future<bool> isFeatureEnabled(String featureName) async {
    return _config[featureName] ?? false;
  }

  int getMaxItems() {
    return _config['maxItems'] ?? 0;
  }

  Color? getScaffoldBackgroundColor() {
    switch (_flavor) {
      case 'gelomare':
        return const Color.fromARGB(255, 172, 179, 188);
      case 'mcfood':
        return const Color.fromARGB(255, 188, 172, 172);
      default:
        return const Color.fromARGB(255, 193, 186, 186);
    }
  }

  List<pw.Text> getIntestazioneDoc() {
    switch (_flavor) {
      case 'gelomare':
        return [
          pw.Text('GELOMARE S.r.l.',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text('Sede Att. Via Tancia, 71 - Rieti',
              style: pw.TextStyle(fontSize: 6)),
          pw.Text('Tel. 0746.210656 - 210129',
              style: pw.TextStyle(fontSize: 6)),
          pw.Text('P.Iva/C.F. :PRTGLN42H52H282Q',
              style: pw.TextStyle(fontSize: 6)),
          pw.Text('Iscr. Trib. n. 4234, aut. san. n. 287 del 28/07/95 ',
              style: pw.TextStyle(fontSize: 5)),
          pw.Text('Cap. Soc. Euro 100.000,00  i.v.',
              style: pw.TextStyle(fontSize: 5)),
          pw.Text('IBAN: IT18H0200814607000005225801',
              style: pw.TextStyle(fontSize: 6)),
        ];
        break;
      case 'mcfood':
        return [
          pw.Text('M&C FOOD SRL',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          /* pw.Text('Sede Att. Via Tancia, 71 - Rieti',
                                      style: pw.TextStyle(fontSize: 8)), */
          pw.Text('Dom.Fisc. Zona Industriale',
              style: pw.TextStyle(fontSize: 8)),
          pw.Text('loc. Aeroporto lotto n. 61/bis',
              style: pw.TextStyle(fontSize: 8)),
          pw.Text('Tel. 0963.530599', style: pw.TextStyle(fontSize: 8)),
          pw.Text('Cod.Fisc.:03149960795', style: pw.TextStyle(fontSize: 8)),
          pw.Text('P.Iva:03149960795', style: pw.TextStyle(fontSize: 8)),
        ];
        break;
      default:
        return [
          pw.Text('NOME AZIENDA',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          /* pw.Text('Sede Att. Via Tancia, 71 - Rieti',
                                      style: pw.TextStyle(fontSize: 8)), */
          pw.Text('Dom.Fisc. SEDE LEGALE AZIENDA',
              style: pw.TextStyle(fontSize: 8)),
          /*  pw.Text('loc. Aeroporto lotto n. 61/bis',
                                          style: pw.TextStyle(fontSize: 8)), */ // SE LA SEDE LEGALE E' PIU LUNGA DIVIDERLA IN DUE RIGHE
          pw.Text('Tel. 0123.4567890', style: pw.TextStyle(fontSize: 8)),
          pw.Text('Cod.Fisc.:01234567890', style: pw.TextStyle(fontSize: 8)),
          pw.Text('P.Iva:01234567890', style: pw.TextStyle(fontSize: 8)),
        ];
        break;
    }
  }
}
