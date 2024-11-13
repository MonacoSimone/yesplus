import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../controllers/ordine_controller.dart';
import '../controllers/documenti_controller.dart';
import 'package:get/get.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/fatt_mensi_controller.dart';
import '../controllers/incassi_controller.dart';
import '../widgets/fl_chart.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RicercaClienti extends StatelessWidget {
  const RicercaClienti({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = context.width - (context.width * 0.06) - 40;

    final ClientiController cc = Get.put(ClientiController());
    final IncassiController ic = Get.put(IncassiController());
    final DocumentiController dc = Get.put(DocumentiController());
    final oc = Get.put(OrdineController(), permanent: true);
    final FatturatoController fatturatoController =
        Get.put(FatturatoController());
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.2,
                              child: TextField(
                                controller: cc.nomeController,
                                focusNode: cc.nomeNode,
                                onChanged: (value) {
                                  cc.nome.value = value;
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.15,
                              child: TextField(
                                controller: cc.comuneController,
                                focusNode: cc.comuneNode,
                                onChanged: (value) {
                                  cc.comune.value = value;
                                },
                              ),
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              cc.filtraClienti();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: const Text('Cerca'))
                      ],
                    ),
                  )),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xDDffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => cc.clienteSelezionato.value.mbanId == 0
                      ? ListView.builder(
                          itemCount: cc.anagrafica.clienti.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () async {
                                      cc.clienteSelezionato.value =
                                          cc.anagrafica.clienti[index];
                                      cc.nomeController.text = 'Nome Cliente';
                                      cc.comuneController.text = 'Comune';
                                      ic.filtraIncassi(
                                          cc.clienteSelezionato.value.mbpcId);
                                      debugPrint(
                                          'MBPC_ID: ${cc.clienteSelezionato.value.mbpcId}');
                                      fatturatoController.getFatturatoAnno(
                                          DateTime.now().year,
                                          cc.clienteSelezionato.value.mbpcId);
                                      dc.getNumDocumenti(
                                          cc.clienteSelezionato.value.mbpcId);
                                      await oc
                                          .caricaProdotti(cc
                                              .clienteSelezionato.value.mbpcId)
                                          .then((value) {
                                        for (var prodotto in value) {
                                          oc.prodotti.add(prodotto);
                                          oc.prodottiOri.add(prodotto);

                                          oc.classi.add(prodotto.classe);
                                          oc.classi.insert(0, 'TUTTI');
                                          oc.classi =
                                              oc.classi.toSet().toList();
                                        }
                                        //debugdebugPrint(oc.prodotti.toString());
                                      });

                                      /* await cc.fatturatoMensilizzato(
                                          DateTime.now().year, 9240); */
                                      //cc.clienteSelezionato.value.mbpcId);
                                    },
                                    leading: const CircleAvatar(
                                        child: Icon(Icons.person)),
                                    title: Text(
                                      cc.anagrafica.clienti[index].mbanRagSoc,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      cc.anagrafica.clienti[index]
                                          .mbanIndirizzo,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                                const Divider(height: 0),
                              ],
                            );
                          },
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 300,
                                        width: (width),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8AD9F2)
                                              .withAlpha(70),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: FatturatoChart(
                                            annoIniziale:
                                                DateTime.now().year - 1)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.euro_rounded,
                                            testo:
                                                '€ ${ic.totale_residuo.toStringAsFixed(2)}',
                                            intestazione: 'Saldo',
                                            testoSize: 35,
                                            color: const Color(0xFF6EE6ED),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.bar_chart_rounded,
                                            testo:
                                                '${fatturatoController.anno_1}: € ${fatturatoController.mediaOrd1}',
                                            testo2:
                                                '${fatturatoController.anno_2}: € ${fatturatoController.mediaOrd2}',
                                            intestazione: 'Media Ordinato',
                                            testoSize: 20,
                                            testo2Size: 20,
                                            color: const Color(0xFF6DF2D9),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.bar_chart_rounded,
                                            testo:
                                                '${fatturatoController.anno_1}: € ${fatturatoController.mediaFat1.toStringAsFixed(2)}',
                                            testo2:
                                                '${fatturatoController.anno_2}: € ${fatturatoController.mediaFat2.toStringAsFixed(2)}',
                                            intestazione: 'Media Fatturato',
                                            testoSize: 20,
                                            testo2Size: 20,
                                            color: const Color(0xFFBFFC91),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon:
                                                Icons.stacked_bar_chart_rounded,
                                            testo:
                                                '€ ${fatturatoController.trimestre.value.toStringAsFixed(2)}',
                                            intestazione: 'Fatturato 3 Mesi',
                                            testoSize: 28,
                                            color: const Color(0xFF88F9BA),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.euro_rounded,
                                            testo:
                                                '€  ${fatturatoController.totale.toStringAsFixed(2)}',
                                            intestazione: 'Fatturato Totale',
                                            testoSize: 28,
                                            color: const Color(0xFF4EBF85),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: (width - 40) * 0.25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F871),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Doc. ${fatturatoController.anno_1}',
                                                        style: const TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .format_list_bulleted_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.fattAnno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      intestazione: 'Fatture',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                      showIcon: false,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.ordAnno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: 'Ordini',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll1Anno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr1
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll2Anno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr2
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: (width - 40) * 0.25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F871),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Doc. ${fatturatoController.anno_2}',
                                                        style: const TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .format_list_bulleted_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.fattAnno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      intestazione: 'Fatture',
                                                      intestazioneSize: 13,
                                                      showIcon: false,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.ordAnno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: 'Ordini',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll1Anno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr1
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll2Anno2
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr2
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class rettangoloDasboard extends StatelessWidget {
  const rettangoloDasboard(
      {super.key,
      required this.width,
      this.color = const Color(0xFF8AD9F2),
      required this.icon,
      required this.testo,
      this.testoSize = 20.0,
      this.testo2 = '',
      this.testo2Size = 20,
      this.height = 150,
      this.intestazioneSize = 17,
      this.iconSize = 30,
      this.showIcon = true,
      required this.intestazione});

  final double width;
  final Color color;
  final IconData icon;
  final String testo;
  final String testo2;
  final String intestazione;
  final double iconSize;
  final double intestazioneSize;
  final double testoSize;
  final double testo2Size;
  final double height;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showIcon
                  ? AutoSizeText(
                      minFontSize: 4,
                      maxFontSize: intestazioneSize,
                      maxLines: 1,
                      intestazione,
                      //style: TextStyle(fontSize: intestazioneSize),
                    )
                  : SizedBox(
                      width: width / 1.2,
                      child: AutoSizeText(
                        minFontSize: 4,
                        maxFontSize: intestazioneSize,
                        maxLines: 1,
                        intestazione,
                        //style: TextStyle(fontSize: intestazioneSize),
                      ),
                    ),
              showIcon
                  ? Icon(
                      icon,
                      size: iconSize,
                    )
                  : const SizedBox(width: 0, height: 0)
            ],
          ),
        ),
        Text(
          testo,
          style: TextStyle(fontSize: testoSize, fontWeight: FontWeight.w700),
        ),
        testo2 == ''
            ? Container(width: 0, height: 0)
            : Text(
                testo2,
                style: TextStyle(
                    fontSize: testo2Size, fontWeight: FontWeight.w700),
              ),
      ]),
    );
  }
}


/*
Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.2,
                              child: TextField(
                                controller: cc.nomeController,
                                focusNode: cc.nomeNode,
                                onChanged: (value) {
                                  cc.nome.value = value;
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: width * 0.15,
                              child: TextField(
                                controller: cc.comuneController,
                                focusNode: cc.comuneNode,
                                onChanged: (value) {
                                  cc.comune.value = value;
                                },
                              ),
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              cc.filtraClienti();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: const Text('Cerca'))
                      ],
                    ),
                  )),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xDDffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => cc.clienteSelezionato.value.mbanId == 0
                      ? ListView.builder(
                          itemCount: cc.anagrafica.clienti.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () async {
                                      cc.clienteSelezionato.value =
                                          cc.anagrafica.clienti[index];
                                      cc.nomeController.text = 'Nome Cliente';
                                      cc.comuneController.text = 'Comune';
                                      ic.filtraIncassi(
                                          cc.clienteSelezionato.value.mbpcId);
                                      debugPrint(
                                          'MBPC_ID: ${cc.clienteSelezionato.value.mbpcId}');
                                      fatturatoController.getFatturatoAnno(
                                          DateTime.now().year,
                                          cc.clienteSelezionato.value.mbpcId);
                                      dc.getNumDocumenti(
                                          cc.clienteSelezionato.value.mbpcId);
                                      await oc
                                          .caricaProdotti(cc
                                              .clienteSelezionato.value.mbpcId)
                                          .then((value) {
                                        for (var prodotto in value) {
                                          oc.prodotti.add(prodotto);
                                          oc.prodottiOri.add(prodotto);

                                          oc.classi.add(prodotto.classe);
                                          oc.classi.insert(0, 'TUTTI');
                                          oc.classi =
                                              oc.classi.toSet().toList();
                                        }
                                        //debugdebugPrint(oc.prodotti.toString());
                                      });

                                      /* await cc.fatturatoMensilizzato(
                                          DateTime.now().year, 9240); */
                                      //cc.clienteSelezionato.value.mbpcId);
                                    },
                                    leading: const CircleAvatar(
                                        child: Icon(Icons.person)),
                                    title: Text(
                                      cc.anagrafica.clienti[index].mbanRagSoc,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      cc.anagrafica.clienti[index]
                                          .mbanIndirizzo,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                                const Divider(height: 0),
                              ],
                            );
                          },
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 300,
                                        width: (width + 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8AD9F2)
                                              .withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: FatturatoChart(
                                            annoIniziale:
                                                DateTime.now().year - 1)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.euro_rounded,
                                            testo:
                                                '€ ${ic.totale_residuo.toStringAsFixed(2)}',
                                            intestazione: 'Saldo',
                                            testoSize: 35,
                                            color: const Color(0xFF6EE6ED),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.bar_chart_rounded,
                                            testo:
                                                '${fatturatoController.anno_1}: € ${fatturatoController.mediaOrd1}',
                                            testo2:
                                                '${fatturatoController.anno_2}: € ${fatturatoController.mediaOrd2}',
                                            intestazione: 'Media Ordinato',
                                            testoSize: 20,
                                            testo2Size: 20,
                                            color: const Color(0xFF6DF2D9),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.bar_chart_rounded,
                                            testo:
                                                '${fatturatoController.anno_1}: € ${fatturatoController.mediaFat1.toStringAsFixed(2)}',
                                            testo2:
                                                '${fatturatoController.anno_2}: € ${fatturatoController.mediaFat2.toStringAsFixed(2)}',
                                            intestazione: 'Media Fatturato',
                                            testoSize: 20,
                                            testo2Size: 20,
                                            color: const Color(0xFFBFFC91),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon:
                                                Icons.stacked_bar_chart_rounded,
                                            testo:
                                                '€ ${fatturatoController.trimestre.value.toStringAsFixed(2)}',
                                            intestazione: 'Fatturato 3 Mesi',
                                            testoSize: 28,
                                            color: const Color(0xFF88F9BA),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          rettangoloDasboard(
                                            width: (width - 40) * 0.166,
                                            icon: Icons.euro_rounded,
                                            testo:
                                                '€  ${fatturatoController.totale.toStringAsFixed(2)}',
                                            intestazione: 'Fatturato Totale',
                                            testoSize: 28,
                                            color: const Color(0xFF4EBF85),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: (width - 40) * 0.25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F871),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Doc. ${fatturatoController.anno_1}',
                                                        style: const TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .format_list_bulleted_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.fattAnno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      intestazione: 'Fatture',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                      showIcon: false,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.ordAnno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: 'Ordini',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll1Anno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr1
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll2Anno1.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr2
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: (width - 40) * 0.25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F871),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Doc. ${fatturatoController.anno_2}',
                                                        style: const TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .format_list_bulleted_rounded,
                                                        size: 30,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.fattAnno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      intestazione: 'Fatture',
                                                      intestazioneSize: 13,
                                                      showIcon: false,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.ordAnno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: 'Ordini',
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll1Anno2.value
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr1
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                    rettangoloDasboard(
                                                      width: ((width - 40) *
                                                              0.25) *
                                                          0.43,
                                                      height: 110,
                                                      icon: Icons.api_rounded,
                                                      testo: dc.boll2Anno2
                                                          .toString(),
                                                      testoSize: 40,
                                                      showIcon: false,
                                                      intestazione: dc
                                                          .tipoBollaDescr2
                                                          .value,
                                                      intestazioneSize: 13,
                                                      iconSize: 20,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),    
 */