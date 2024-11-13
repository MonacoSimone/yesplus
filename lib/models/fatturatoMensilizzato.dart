import 'dart:math';

class FatturatoMensilizzato {
  final double mese;
  final double fatturato;

  FatturatoMensilizzato({required this.mese, required this.fatturato});
}

double calcolaMediaFatturatoAlto(List<FatturatoMensilizzato> lista1,
    List<FatturatoMensilizzato> lista2, List<FatturatoMensilizzato> lista3) {
  // Calcola il totale del fatturato per ogni lista
  double totale1 = lista1.fold(0, (sum, current) => sum + current.fatturato);
  double totale2 = lista2.fold(0, (sum, current) => sum + current.fatturato);
  double totale3 = lista3.fold(0, (sum, current) => sum + current.fatturato);

  // Trova il totale più alto e la lista corrispondente
  List<double> totali = [totale1, totale2, totale3];
  double maxTotale = totali.reduce(max);

  // Seleziona la lista con il totale più alto
  List<FatturatoMensilizzato> listaMax;
  if (maxTotale == totale1) {
    listaMax = lista1;
  } else if (maxTotale == totale2) {
    listaMax = lista2;
  } else {
    listaMax = lista3;
  }

  // Calcola la media per la lista selezionata
  if (listaMax.isNotEmpty) {
    return maxTotale / listaMax.length;
  } else {
    return 0; // Gestisce il caso di lista vuota
  }
}
