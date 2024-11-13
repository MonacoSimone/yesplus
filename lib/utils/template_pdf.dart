import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/anagrafica.dart';
import '../models/documento.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'flavor_scripts.dart';

Future<Uint8List> loadImageAsset(String path) async {
  final data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

Future<void> generaFattura(pw.Document pdf, Cliente cli, DocumentoShort doc,
    FlavorScripts flavorScripts) async {
  final image = pw.MemoryImage(
    await loadImageAsset(flavorScripts.getAssetImagePath('applogo.png')),
  );
  // Variabili per i totali
  double totaleOmaggi = 0.0;
  double totaleImponibile = 0.0;
  double totaleImposta = 0.0;
  double totaleDocumento = 0.0;
  // Mappa per memorizzare i valori per ogni aliquota IVA
  Map<String, Map<String, double>> aliquoteMap = {};

  List<pw.Widget> aliquote = [
    pw.Text('ALIQ.', style: pw.TextStyle(fontSize: 4))
  ];
  List<pw.Widget> imponibili = [
    pw.Text('IMPONIBILE', style: pw.TextStyle(fontSize: 4)),
  ];
  List<pw.Widget> imposte = [
    pw.Text('IMPOSTA', style: pw.TextStyle(fontSize: 4))
  ];

  String ora = DateFormat('kk:mm').format(DateTime.now());
  List<List<String>> righe = [
    <String>[
      'CODICE ARTICOLO',
      'DESCRIZIONE DEI BENI',
      'U.M.',
      'QTA\'',
      'PR.',
      'IMP. AMM.',
      'ALIQ. VAT'
    ],
  ];
  List<Map<String, dynamic>> mapRighe =
      await DatabaseHelper().getRigheDocumento(doc.id, doc.prefisso);
//  List<Map<String, dynamic>> sortedMapRighe = mapRighe.toList();
  //sortedMapRighe.sort((a, b) => a["MBIV_IVA"].compareTo(b["MBIV_IVA"]));

// Ciclo per le righe prodotto
  for (var mapRiga in mapRighe) {
    // Calcolo totale omaggi
    if (mapRiga["FTAR_MBTA_Codice"] == 5) {
      totaleOmaggi += mapRiga["FTAR_Prezzo"];
    }

    // Calcolo imponibile e imposta

    double imponibileRiga = mapRiga["FTAR_Prezzo"] * mapRiga["FTAR_Quantita"];
    double scontoRiga = mapRiga["FTAR_TotSconti"];
    double imponibileNettoRiga = imponibileRiga - scontoRiga;
    double impostaRiga = imponibileNettoRiga * (mapRiga["MBIV_IVA"] / 100);

    // Aggiornamento totali
    totaleImponibile += imponibileNettoRiga;
    totaleImposta += impostaRiga;

    // Gestione aliquote
    String aliquota = mapRiga["MBIV_IVA"].toString();
    if (!aliquoteMap.containsKey(aliquota)) {
      aliquoteMap[aliquota] = {"imponibile": 0.0, "imposta": 0.0};
    }

    aliquoteMap[aliquota]!["imponibile"] =
        aliquoteMap[aliquota]!["imponibile"]! + imponibileNettoRiga;
    aliquoteMap[aliquota]!["imposta"] =
        aliquoteMap[aliquota]!["imposta"]! + impostaRiga;
    totaleDocumento += imponibileNettoRiga + impostaRiga;
    debugPrint('tipoRiga: ${mapRiga["FTAR_MBTA_Codice"]}');
    righe.add([
      mapRiga["MGAA_Matricola"]?.toString() ??
          '', // Usa ?.toString() per convertire in stringa e ?? '' per gestire i null
      mapRiga["FTAR_Descr"]?.toString() ?? '',
      mapRiga["FTAR_MBUM_Codice"]?.toString() ?? '',
      mapRiga["FTAR_Quantita"]?.toString() ?? '',
      mapRiga["FTAR_MBTA_Codice"] == 5
          ? 'Omaggio'
          : mapRiga["FTAR_Prezzo"]?.toString() ?? '',
      imponibileNettoRiga.toStringAsFixed(2),

      '${mapRiga["MBIV_IVA"] ?? '0'} %',
    ]);
  }

// Riempimento liste aliquote, imponibili e imposte
  for (var aliquota in aliquoteMap.keys) {
    aliquote.add(pw.Text(aliquota, style: pw.TextStyle(fontSize: 6)));
    imponibili.add(pw.Text(
        aliquoteMap[aliquota]!["imponibile"]!.toStringAsFixed(2),
        style: pw.TextStyle(fontSize: 6)));
    imposte.add(pw.Text(aliquoteMap[aliquota]!["imposta"]!.toStringAsFixed(2),
        style: pw.TextStyle(fontSize: 6)));
  }

  List<Map<String, dynamic>> testata =
      await DatabaseHelper().getTestataDocumento(doc.id, doc.prefisso);
  List<Map<String, dynamic>> agente = await DatabaseHelper().getAgente();
  return pdf.addPage(
    pw.MultiPage(
      header: (pw.Context context) {
        return pw.Header(
            level: 0,
            child: pw.SizedBox(
                height: 65,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Container(
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color:
                                          const PdfColor.fromInt(0xFF000000))),
                              child: pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Column(
                                    children:
                                        flavorScripts.getIntestazioneDoc(),
                                  )))),
                      pw.SizedBox(width: 2),
                      pw.Expanded(
                        child: pw.Image(
                          image,
                          fit: pw.BoxFit.scaleDown,
                          alignment: pw.Alignment.center,
                        ),
                      )
                    ])));
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.SizedBox(
              height: 40,
              child: pw.Row(children: [
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: <pw.Widget>[
                              ...aliquote
                              // pw.Text('ALIQ.',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('10%', style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imponibili
                              // pw.Text('IMPONIBILE',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('383,80',
                              //     style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imposte
                              /*  pw.Text('IMPOSTA',
                                  style: pw.TextStyle(fontSize: 4)),
                              pw.Text('38,38', style: pw.TextStyle(fontSize: 6)) */
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE OMAGGI',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleOmaggi.toString(),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPONIBILE',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleImponibile.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPOSTA',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleImposta.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('IMPORTO PAGATO',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text('0,0',
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                            ])))),
              ])),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ORA CONSEGNA',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(ora, style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('COLLI', style: pw.TextStyle(fontSize: 4)),
                          pw.Text('-', style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ASPETTO BENI',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text('-', style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('TOTALE DOCUMENTO',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(totaleDocumento.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 6))
                        ])))),
          ]),
          pw.SizedBox(height: 3),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Conducente',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Mancato Pagamento',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Destinatario',
                                style: pw.TextStyle(fontSize: 4))))))
          ]),
          pw.SizedBox(height: 2),
          pw.Text('Pagina ${context.pageNumber} di ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6))
        ]);
      },
      pageFormat: const PdfPageFormat(
        105 * PdfPageFormat.mm, // larghezza
        297 * PdfPageFormat.mm, // altezza
        marginAll: 0.5 * PdfPageFormat.cm, // Imposta un margine, opzionale
      ),
      build: (context) => [
        pw.Text('Fattura in Regime di Tentata Vendita',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Row(children: [
          pw.Expanded(
              child: pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            height: 70,
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Fattura N. - Invoice N.',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(testata[0]['FTAN_NumFatt'],
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Data - Date',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(
                                DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(testata[0]["FTAN_DataIns"])),
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
              ]),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Pagamento - Payment Terms',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.SizedBox(height: 2),
                          pw.Text(testata[0]['pagamento'],
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Destinazione - Ship To',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(testata[0]['Dest'] ?? '',
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
            ]),
          )),
          pw.SizedBox(width: 10),
          pw.Expanded(
              child: pw.Container(
                  height: 70,
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFF000000),
                          width: 0.5)),
                  child: pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('SPETT.LE',
                                  style: pw.TextStyle(
                                    fontSize: 3,
                                  )),
                              pw.Text('Cod. ${testata[0]['Cod']}',
                                  style: pw.TextStyle(
                                      fontSize: 4,
                                      fontWeight: pw.FontWeight.bold))
                            ],
                          ),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_RagSoc'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_Indirizzo'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 3),
                          pw.Text('Part.Iva: ${testata[0]['MBAN_PartitaIVA']}',
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold))
                        ],
                      )))),
        ]),
        pw.SizedBox(height: 5),
        pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFc2c2c2),
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            child: pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Column(children: [
                  pw.Text('Agente - Agent', style: pw.TextStyle(fontSize: 4)),
                  pw.Text(agente[0]['MBAN_RagSoc'],
                      style: pw.TextStyle(fontSize: 6))
                ]))),
        pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(width: 0.5),
            context: context,
            cellAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FixedColumnWidth(
                  45.0), // Fissa la larghezza della prima colonna a 100.0
              1: pw
                  .FlexColumnWidth(), // Lascia che la seconda colonna si espanda per riempire lo spazio disponibile
              2: pw.FixedColumnWidth(20.0),
              3: pw.FixedColumnWidth(20.0),
              4: pw.FixedColumnWidth(30.0),
              5: pw.FixedColumnWidth(30.0),
              6: pw.FixedColumnWidth(
                  25.0), // Fissa la larghezza della terza colonna a 80.0
            },
            headerStyle:
                pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 5.5),
            data: righe),
      ],
    ),
  );
}

Future<void> generaOrdine(pw.Document pdf, Cliente cli, DocumentoShort doc,
    FlavorScripts flavorScripts) async {
  debugPrint('cliente: $cli - documento: ${doc.numero}');
  final image = pw.MemoryImage(
    await loadImageAsset(flavorScripts.getAssetImagePath('applogo.png')),
  );

// Variabili per i totali
  double totaleOmaggi = 0.0;
  double totaleImponibile = 0.0;
  double totaleImposta = 0.0;
  double totaleDocumento = 0.0;
  // Mappa per memorizzare i valori per ogni aliquota IVA
  Map<String, Map<String, double>> aliquoteMap = {};

  List<pw.Widget> aliquote = [
    pw.Text('ALIQ.', style: pw.TextStyle(fontSize: 4))
  ];
  List<pw.Widget> imponibili = [
    pw.Text('IMPONIBILE', style: pw.TextStyle(fontSize: 4)),
  ];
  List<pw.Widget> imposte = [
    pw.Text('IMPOSTA', style: pw.TextStyle(fontSize: 4))
  ];

  String ora = DateFormat('kk:mm').format(DateTime.now());
  List<List<String>> righe = [
    <String>[
      'CODICE ARTICOLO',
      'DESCRIZIONE DEI BENI',
      'U.M.',
      'QTA\'',
      'PR.',
      'IMP. AMM.',
      'ALIQ. VAT'
    ],
  ];
  List<Map<String, dynamic>> mapRighe =
      await DatabaseHelper().getRigheDocumento(doc.id, doc.prefisso);
//  List<Map<String, dynamic>> sortedMapRighe = mapRighe.toList();
  //sortedMapRighe.sort((a, b) => a["MBIV_IVA"].compareTo(b["MBIV_IVA"]));

// Ciclo per le righe prodotto
  for (var mapRiga in mapRighe) {
    // Calcolo totale omaggi
    if (mapRiga["OCAR_MBTA_Codice"] == 5) {
      totaleOmaggi += mapRiga["OCAR_Prezzo"];
    }

    // Calcolo imponibile e imposta
    double imponibileRiga =
        double.parse(mapRiga["OCAR_Prezzo"].toStringAsFixed(2)) *
            mapRiga["OCAR_Quantita"];
    //double scontoRiga = mapRiga["OCAR_TotSconti"];
    double imponibileNettoRiga = imponibileRiga;
    double impostaRiga = imponibileNettoRiga * (mapRiga["MBIV_IVA"] / 100);

    // Aggiornamento totali
    totaleImponibile += imponibileNettoRiga;
    totaleImposta += impostaRiga;

    // Gestione aliquote
    String aliquota = mapRiga["MBIV_IVA"].toString();
    if (!aliquoteMap.containsKey(aliquota)) {
      aliquoteMap[aliquota] = {"imponibile": 0.0, "imposta": 0.0};
    }

    aliquoteMap[aliquota]!["imponibile"] =
        aliquoteMap[aliquota]!["imponibile"]! + imponibileNettoRiga;
    aliquoteMap[aliquota]!["imposta"] =
        aliquoteMap[aliquota]!["imposta"]! + impostaRiga;
    totaleDocumento += imponibileNettoRiga + impostaRiga;
    debugPrint('tipoRiga: ${mapRiga["OCAR_MBTA_Codice"]}');
    righe.add([
      mapRiga["MGAA_Matricola"]?.toString() ??
          '', // Usa ?.toString() per convertire in stringa e ?? '' per gestire i null
      mapRiga["OCAR_DescrArt"]?.toString() ?? '',
      mapRiga["OCAR_MBUM_Codice"]?.toString() ?? '',
      mapRiga["OCAR_Quantita"]?.toString() ?? '',
      mapRiga["OCAR_MBTA_Codice"] == 5
          ? 'Omaggio'
          : mapRiga["OCAR_Prezzo"].toStringAsFixed(2).toString(),
      imponibileNettoRiga.toStringAsFixed(2),

      '${mapRiga["MBIV_IVA"] ?? '0'} %',
    ]);
  }

// Riempimento liste aliquote, imponibili e imposte
  for (var aliquota in aliquoteMap.keys) {
    aliquote.add(pw.Text(aliquota, style: pw.TextStyle(fontSize: 6)));
    imponibili.add(pw.Text(
        aliquoteMap[aliquota]!["imponibile"]!.toStringAsFixed(2),
        style: pw.TextStyle(fontSize: 6)));
    imposte.add(pw.Text(aliquoteMap[aliquota]!["imposta"]!.toStringAsFixed(2),
        style: pw.TextStyle(fontSize: 6)));
  }

  List<Map<String, dynamic>> testata =
      await DatabaseHelper().getTestataDocumento(doc.id, doc.prefisso);
  debugPrint(testata.toString());
  List<Map<String, dynamic>> agente = await DatabaseHelper().getAgente();
  return pdf.addPage(
    pw.MultiPage(
      header: (pw.Context context) {
        return pw.Header(
            level: 0,
            child: pw.SizedBox(
                height: 65,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Container(
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color:
                                          const PdfColor.fromInt(0xFF000000))),
                              child: pw.Padding(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Column(
                                    children:
                                        flavorScripts.getIntestazioneDoc(),
                                  )))),
                      pw.SizedBox(width: 2),
                      pw.Expanded(
                        child: pw.Image(
                          image,
                          fit: pw.BoxFit.scaleDown,
                          alignment: pw.Alignment.center,
                        ),
                      )
                    ])));
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.SizedBox(
              height: 40,
              child: pw.Row(children: [
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: <pw.Widget>[
                              ...aliquote
                              // pw.Text('ALIQ.',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('10%', style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imponibili
                              // pw.Text('IMPONIBILE',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('383,80',
                              //     style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imposte
                              /*  pw.Text('IMPOSTA',
                                  style: pw.TextStyle(fontSize: 4)),
                              pw.Text('38,38', style: pw.TextStyle(fontSize: 6)) */
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE OMAGGI',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleOmaggi.toString(),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPONIBILE',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleImponibile.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPOSTA',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totaleImposta.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('IMPORTO PAGATO',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text('0,0',
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                            ])))),
              ])),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ORA CONSEGNA',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(ora, style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('COLLI', style: pw.TextStyle(fontSize: 4)),
                          pw.Text(/* colli.toString() */ '-',
                              style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ASPETTO BENI',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text('-', style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('TOTALE DOCUMENTO',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(totaleDocumento.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 6))
                        ])))),
          ]),
          pw.SizedBox(height: 3),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Conducente',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Mancato Pagamento',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Destinatario',
                                style: pw.TextStyle(fontSize: 4))))))
          ]),
          pw.SizedBox(height: 2),
          pw.Text('Pagina ${context.pageNumber} di ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6))
        ]);
      },
      pageFormat: const PdfPageFormat(
        105 * PdfPageFormat.mm, // larghezza
        297 * PdfPageFormat.mm, // altezza
        marginAll: 0.5 * PdfPageFormat.cm, // Imposta un margine, opzionale
      ),
      build: (context) => [
        /*  pw.Text('Fattura in Regime di Tentata Vendita',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)), */
        pw.SizedBox(height: 4),
        pw.Row(children: [
          pw.Expanded(
              child: pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            height: 70,
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Ordine N. - Order N.',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(testata[0]['OCAN_NumOrd'].toString(),
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Data - Date',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(
                                DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(testata[0]["OCAN_DataIns"])),
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
              ]),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Pagamento - Payment Terms',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.SizedBox(height: 2),
                          pw.Text(testata[0]['pagamento'],
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Destinazione - Ship To',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(testata[0]['Dest'] ?? '',
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
            ]),
          )),
          pw.SizedBox(width: 10),
          pw.Expanded(
              child: pw.Container(
                  height: 70,
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFF000000),
                          width: 0.5)),
                  child: pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('SPETT.LE',
                                  style: pw.TextStyle(
                                    fontSize: 3,
                                  )),
                              pw.Text('Cod. ${testata[0]['Cod']}',
                                  style: pw.TextStyle(
                                      fontSize: 4,
                                      fontWeight: pw.FontWeight.bold))
                            ],
                          ),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_RagSoc'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_Indirizzo'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 3),
                          pw.Text('Part.Iva: ${testata[0]['MBAN_PartitaIVA']}',
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold))
                        ],
                      )))),
        ]),
        pw.SizedBox(height: 5),
        pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFc2c2c2),
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            child: pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Column(children: [
                  pw.Text('Agente - Agent', style: pw.TextStyle(fontSize: 4)),
                  pw.Text(agente[0]['MBAN_RagSoc'],
                      style: pw.TextStyle(fontSize: 6))
                ]))),
        pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(width: 0.5),
            context: context,
            cellAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FixedColumnWidth(
                  40.0), // Fissa la larghezza della prima colonna a 100.0
              1: pw
                  .FlexColumnWidth(), // Lascia che la seconda colonna si espanda per riempire lo spazio disponibile
              2: pw.FixedColumnWidth(20.0),
              3: pw.FixedColumnWidth(25.0),
              4: pw.FixedColumnWidth(30.0),
              5: pw.FixedColumnWidth(30.0),
              6: pw.FixedColumnWidth(
                  25.0), // Fissa la larghezza della terza colonna a 80.0
            },
            headerStyle:
                pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 5.5),
            data: righe),
      ],
    ),
  );
}

Future<void> generaBolla(pw.Document pdf, Cliente cli, DocumentoShort doc,
    FlavorScripts flavorScripts) async {
  final image = pw.MemoryImage(
    await loadImageAsset(flavorScripts.getAssetImagePath('applogo.png')),
  );
  double colli = 0;
  String controlloAliquota = '';
  double imponibile = 0.0;
  List<pw.Widget> aliquote = [
    pw.Text('ALIQ.', style: pw.TextStyle(fontSize: 4))
  ];
  List<pw.Widget> imponibili = [
    pw.Text('IMPONIBILE', style: pw.TextStyle(fontSize: 4)),
  ];
  List<pw.Widget> imposte = [
    pw.Text('IMPOSTA', style: pw.TextStyle(fontSize: 4))
  ];
  double omaggi = 0.0;
  double totale_imponibile = 0.0;
  double totale_imposta = 0.0;
  double importo_pagato = 0.0;
  double totale_documento = 0.0;
  String ora = DateFormat('kk:mm').format(DateTime.now());

  List<List<String>> righe = [
    <String>[
      'CODICE ARTICOLO',
      'DESCRIZIONE DEI BENI',
      'U.M.',
      'QTA\'',
      'PR.',
      'IMP. AMM.',
      'ALIQ. VAT'
    ],
  ];
  List<Map<String, dynamic>> mapRighe =
      await DatabaseHelper().getRigheDocumento(doc.id, doc.prefisso);

  if (mapRighe.isNotEmpty) {
    for (var mapRiga in mapRighe) {
      if (controlloAliquota == '') {
        controlloAliquota = mapRiga["MBIV_IVA"].toString();
        aliquote
            .add(pw.Text(controlloAliquota, style: pw.TextStyle(fontSize: 6)));
      }

      if (mapRiga["MBIV_IVA"].toString() != controlloAliquota) {
        double i = imponibile * (mapRiga["MBIV_IVA"] / 100);
        totale_imposta += i;
        imposte.add(
            pw.Text((i).toStringAsFixed(2), style: pw.TextStyle(fontSize: 6)));
        controlloAliquota = mapRiga["MBIV_IVA"].toString();
        totale_imponibile += imponibile;
        aliquote
            .add(pw.Text(controlloAliquota, style: pw.TextStyle(fontSize: 6)));
        imponibili.add(pw.Text(imponibile.toStringAsFixed(2),
            style: pw.TextStyle(fontSize: 6)));

        imponibile = 0.0;
      } else {
        imponibile += mapRiga["BLAR_Prezzo"];
      }

      colli += mapRiga["BLAR_Quantita"];
      if (mapRiga["BLAR_MBTA_Codice"] == 5) {
        omaggi = omaggi + mapRiga["BLAR_Prezzo"];
      }
      // Assumi che ogni mappa abbia tutte le chiavi necessarie.
      // Aggiungi controlli se non sei sicuro.
      righe.add([
        mapRiga["MGAA_Matricola"]?.toString() ??
            '', // Usa ?.toString() per convertire in stringa e ?? '' per gestire i null
        mapRiga["BLAR_DescrArt"]?.toString() ?? '',
        mapRiga["BLAR_MBUM_Codice"]?.toString() ?? '',
        mapRiga["BLAR_Quantita"]?.toString() ?? '',
        mapRiga["BLAR_MBTA_Codice"] == 5
            ? 'Omaggio'
            : mapRiga["BLAR_Prezzo"].toStringAsFixed(2).toString(),
        (mapRiga["BLAR_Quantita"] *
                    (mapRiga["BLAR_Prezzo"] - mapRiga["BLAR_TotSconti"]))
                ?.toString() ??
            '',
        '${mapRiga["MBIV_IVA"] ?? '0'} %',
      ]);
    }
    // Dopo l'ultimo ciclo, assicurati di aggiungere l'imponibile calcolato per l'ultima aliquota
    if (imponibile != 0.0) {
      double i = imponibile * (int.parse(controlloAliquota) / 100);
      totale_imposta += i;
      imposte.add(
          pw.Text((i).toStringAsFixed(2), style: pw.TextStyle(fontSize: 6)));
      totale_imponibile += imponibile;
      imponibili.add(pw.Text(imponibile.toStringAsFixed(2),
          style: pw.TextStyle(fontSize: 6)));
    }

    totale_documento = totale_imposta + totale_imponibile;
  }

  List<Map<String, dynamic>> testata =
      await DatabaseHelper().getTestataDocumento(doc.id, doc.prefisso);
  List<Map<String, dynamic>> agente = await DatabaseHelper().getAgente();
  return pdf.addPage(
    pw.MultiPage(
      header: (pw.Context context) {
        return pw.Header(
            level: 0,
            child: pw.SizedBox(
                height: 65,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: const PdfColor.fromInt(0xFF000000))),
                          child: pw.Padding(
                              padding: pw.EdgeInsets.all(3),
                              child: pw.Column(
                                children: flavorScripts.getIntestazioneDoc(),
                              ))),
                      pw.Image(
                        image,
                        fit: pw.BoxFit.scaleDown,
                        alignment: pw.Alignment.center,
                      ),
                    ])));
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.SizedBox(
              height: 40,
              child: pw.Row(children: [
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: <pw.Widget>[
                              ...aliquote
                              // pw.Text('ALIQ.',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('10%', style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imponibili
                              // pw.Text('IMPONIBILE',
                              //     style: pw.TextStyle(fontSize: 4)),
                              // pw.Text('383,80',
                              //     style: pw.TextStyle(fontSize: 6))
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              ...imposte
                              /*  pw.Text('IMPOSTA',
                                  style: pw.TextStyle(fontSize: 4)),
                              pw.Text('38,38', style: pw.TextStyle(fontSize: 6)) */
                            ])))),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: const PdfColor.fromInt(0xFF000000),
                                width: 0.5)),
                        child: pw.Padding(
                            padding: pw.EdgeInsets.all(2),
                            child: pw.Column(children: [
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE OMAGGI',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(omaggi.toString(),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPONIBILE',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(
                                        totale_imponibile.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('TOTALE IMPOSTA',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text(totale_imposta.toStringAsFixed(2),
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('IMPORTO PAGATO',
                                        style: pw.TextStyle(fontSize: 4)),
                                    pw.Text('0,0',
                                        style: pw.TextStyle(fontSize: 6))
                                  ]),
                            ])))),
              ])),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ORA CONSEGNA',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(ora, style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('COLLI', style: pw.TextStyle(fontSize: 4)),
                          pw.Text(colli.toString(),
                              style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('ASPETTO BENI',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text('-', style: pw.TextStyle(fontSize: 6))
                        ])))),
            pw.Expanded(
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('TOTALE DOCUMENTO',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(totale_documento.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 6))
                        ])))),
          ]),
          pw.SizedBox(height: 3),
          pw.Row(children: [
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Conducente',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Mancato Pagamento',
                                style: pw.TextStyle(fontSize: 4)))))),
            pw.SizedBox(width: 5),
            pw.Expanded(
                child: pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Align(
                            alignment: pw.Alignment.topCenter,
                            child: pw.Text('Firma del Destinatario',
                                style: pw.TextStyle(fontSize: 4))))))
          ]),
          pw.SizedBox(height: 2),
          pw.Text('Pagina ${context.pageNumber} di ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6))
        ]);
      },
      pageFormat: const PdfPageFormat(
        105 * PdfPageFormat.mm, // larghezza
        297 * PdfPageFormat.mm, // altezza
        marginAll: 0.5 * PdfPageFormat.cm, // Imposta un margine, opzionale
      ),
      build: (context) => [
        pw.Row(children: [
          pw.Expanded(
              child: pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            height: 70,
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Bolla N. - Delivery Note N.',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(testata[0]['BLAN_NumBol'],
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF000000),
                              width: 0.5)),
                      child: pw.Padding(
                          padding: pw.EdgeInsets.all(2),
                          child: pw.Column(children: [
                            pw.Text('Data - Date',
                                style: pw.TextStyle(fontSize: 4)),
                            pw.Text(
                                DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(testata[0]["BLAN_DataIns"])),
                                style: pw.TextStyle(fontSize: 5))
                          ]))),
                ),
              ]),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF000000),
                            width: 0.5)),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Pagamento - Payment Terms',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.SizedBox(height: 2),
                          pw.Text(testata[0]['pagamento'],
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                    child: pw.Padding(
                        padding: pw.EdgeInsets.all(2),
                        child: pw.Column(children: [
                          pw.Text('Destinazione - Ship To',
                              style: pw.TextStyle(fontSize: 4)),
                          pw.Text(testata[0]['Dest'] ?? '',
                              style: pw.TextStyle(fontSize: 5))
                        ]))),
              ),
            ]),
          )),
          pw.SizedBox(width: 10),
          pw.Expanded(
              child: pw.Container(
                  height: 70,
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFF000000),
                          width: 0.5)),
                  child: pw.Padding(
                      padding: pw.EdgeInsets.all(2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('SPETT.LE',
                                  style: pw.TextStyle(
                                    fontSize: 3,
                                  )),
                              pw.Text('Cod. ${testata[0]['Cod']}',
                                  style: pw.TextStyle(
                                      fontSize: 4,
                                      fontWeight: pw.FontWeight.bold))
                            ],
                          ),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_RagSoc'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2.5),
                          pw.Text(testata[0]['MBAN_Indirizzo'],
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 3),
                          pw.Text('Part.Iva: ${testata[0]['MBAN_PartitaIVA']}',
                              style: pw.TextStyle(
                                  fontSize: 5.5,
                                  fontWeight: pw.FontWeight.bold))
                        ],
                      )))),
        ]),
        pw.SizedBox(height: 5),
        pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFc2c2c2),
                border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF000000), width: 0.5)),
            child: pw.Padding(
                padding: pw.EdgeInsets.all(2),
                child: pw.Column(children: [
                  pw.Text('Agente - Agent', style: pw.TextStyle(fontSize: 4)),
                  pw.Text(agente[0]['MBAN_RagSoc'],
                      style: pw.TextStyle(fontSize: 6))
                ]))),
        pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(width: 0.5),
            context: context,
            cellAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FixedColumnWidth(
                  45.0), // Fissa la larghezza della prima colonna a 100.0
              1: pw
                  .FlexColumnWidth(), // Lascia che la seconda colonna si espanda per riempire lo spazio disponibile
              2: pw.FixedColumnWidth(20.0),
              3: pw.FixedColumnWidth(20.0),
              4: pw.FixedColumnWidth(30.0),
              5: pw.FixedColumnWidth(30.0),
              6: pw.FixedColumnWidth(
                  25.0), // Fissa la larghezza della terza colonna a 80.0
            },
            headerStyle:
                pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 5.5),
            data: righe),
      ],
    ),
  );
}
