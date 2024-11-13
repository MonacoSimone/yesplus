import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/fatturatoMensilizzato.dart';

class FatturatoController extends GetxController {
  // Lista osservabile di fatturati
  RxList<FatturatoMensilizzato> anno1 =
      <FatturatoMensilizzato>[FatturatoMensilizzato(mese: 0, fatturato: 0)].obs;
  RxList<FatturatoMensilizzato> anno2 =
      <FatturatoMensilizzato>[FatturatoMensilizzato(mese: 0, fatturato: 0)].obs;
  RxList<FatturatoMensilizzato> anno3 =
      <FatturatoMensilizzato>[FatturatoMensilizzato(mese: 0, fatturato: 0)].obs;

  RxInt anno_1 = 0.obs;
  RxInt anno_2 = 0.obs;
  RxInt anno_3 = 0.obs;
  double minVal = 0;
  double maxVal = 0;
  double media = 0;
  RxDouble mediaFat1 = 0.0.obs;
  RxDouble mediaFat2 = 0.0.obs;
  RxString mediaOrd1 = '0.0'.obs;
  RxString mediaOrd2 = '0.0'.obs;
  RxDouble trimestre = 0.0.obs;
  RxDouble totale = 0.0.obs;
  List<double> yValues = [];

  Future<void> getMediaOrdinato(int cliente) async {
    mediaOrd1.value =
        await DatabaseHelper().getMediaOrdinato(anno_1.value, cliente);
    mediaOrd2.value =
        await DatabaseHelper().getMediaOrdinato(anno_2.value, cliente);
  }

  Future<void> getUltimoTrimestre() async {
    trimestre.value = 0.0;
    totale.value = 0.0;
    var mese = DateTime.now().month;
    for (FatturatoMensilizzato val in anno1) {
      totale.value += val.fatturato;
      if (mese == val.mese || mese - 1 == val.mese || mese - 2 == val.mese) {
        trimestre.value += val.fatturato;
      }
    }
  }

  Future<void> calcolaAsseY() async {
    // Calcola il valore minimo e massimo nella lista dei dati
    FatturatoMensilizzato a1 =
        anno1.reduce((a, b) => a.fatturato > b.fatturato ? a : b);
    FatturatoMensilizzato a2 =
        anno2.reduce((a, b) => a.fatturato > b.fatturato ? a : b);
    FatturatoMensilizzato a3 =
        anno3.reduce((a, b) => a.fatturato > b.fatturato ? a : b);

    if (a1.fatturato > a2.fatturato) {
      if (a1.fatturato > a3.fatturato) {
        maxVal = a1.fatturato;
      } else {
        maxVal = a3.fatturato;
      }
    } else {
      if (a2.fatturato > a3.fatturato) {
        maxVal = a2.fatturato;
      } else {
        maxVal = a3.fatturato;
      }
    }

    // Se tutti i valori sono uguali, aggiungi un piccolo offset per evitare una divisione per zero
    if (minVal == maxVal) {
      minVal -= 1; // O un valore appropriato per i tuoi dati
      maxVal += 1;
    }

    // Calcola tre valori intermedi
    yValues = [
      minVal,
      minVal + (maxVal - minVal) / 4,
      minVal + (maxVal - minVal) / 2,
      minVal + 3 * (maxVal - minVal) / 4,
      maxVal,
    ];

    media = calcolaMediaFatturatoAlto(anno1, anno2, anno3);
    debugPrint('media: $yValues');
  }

  Future<void> calcolaMediaFatturato() async {
    for (FatturatoMensilizzato val in anno1) {
      mediaFat1.value += val.fatturato;
    }
    mediaFat1.value = mediaFat1.value / 12;

    for (FatturatoMensilizzato val in anno2) {
      mediaFat2.value += val.fatturato;
    }
    mediaFat2.value = mediaFat2.value / 12;
  }

  // Simula il recupero dei dati
  Future<List<FatturatoMensilizzato>> getFatturatoMensilizzato(
      int anno, int cliente) async {
    // Qui dovresti chiamare la tua funzione e aggiornare 'fatturati'
    // Per ora, utilizzeremo dati fittizi
    List<FatturatoMensilizzato> dati = [];
    List<Map<String, dynamic>> res =
        await DatabaseHelper().getFatturatoMensilizzato(anno, cliente);
    const mesi = [
      '01',
      '02',
      '03',
      '04',
      '05',
      '06',
      '07',
      '08',
      '09',
      '10',
      '11',
      '12'
    ];
    // Supponendo che 'res' sia ordinato per 'Mese'
    for (var mese in mesi) {
      bool meseTrovato = false;
      // Cerca il mese corrente in 'res'
      for (var val in res) {
        if (val["Mese"] == mese) {
          dati.add(FatturatoMensilizzato(
              mese: double.parse(val["Mese"].toString()),
              fatturato: double.parse(val["FATT"].toString())));
          meseTrovato = true;
          break; // Interrompe il ciclo interno una volta trovato il mese
        }
      }
      // Se il mese non è stato trovato in 'res', aggiungi un fatturato di 0.0
      if (!meseTrovato) {
        dati.add(FatturatoMensilizzato(
            mese: double.parse(mese.toString()), fatturato: 0.0));
      }
    }

// Stampa i dati per debug
    /* for (var dato in dati) {
      debugPrint('Mese:${dato.mese}, Fatturato: ${dato.fatturato}');
    } */
    debugPrint(dati[0].toString());
    return dati;
  }

  Future<void> getFatturatoAnno(anno, cliente) async {
    anno_1.value = anno;
    anno_2.value = anno - 1;
    anno_3.value = anno - 2;
    anno1.value = await getFatturatoMensilizzato(anno, cliente);
    anno2.value = await getFatturatoMensilizzato(anno - 1, cliente);
    anno3.value = await getFatturatoMensilizzato(anno - 2, cliente);

    await calcolaAsseY();
    await calcolaMediaFatturato();
    await getMediaOrdinato(cliente);
    await getUltimoTrimestre();
    return;
  }

  void resetFatturato() {
    anno_1 = 0.obs;
    anno_2 = 0.obs;
    anno_3 = 0.obs;
    anno1.clear();
    anno2.clear();
    anno3.clear();
    mediaFat1 = 0.0.obs;
    mediaFat2 = 0.0.obs;
    mediaOrd1 = '0.0'.obs;
    mediaOrd2 = '0.0'.obs;
    trimestre = 0.0.obs;
    totale = 0.0.obs;
  }
}
