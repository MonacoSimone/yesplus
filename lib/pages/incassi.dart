import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/controller_soket.dart';
import '../controllers/incassi_controller.dart';

class Incassi extends StatelessWidget {
  const Incassi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IncassiController ic = Get.put(IncassiController());
    final ClientiController cc = Get.put(ClientiController());
    final WebSocketController wc = Get.find<WebSocketController>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Obx(
                      () => Text(
                        'Totale da Pagare: € ${cc.clienteSelezionato.value.mbpcId == 0 ? 0.00 : ic.totale_residuo.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                    ),
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Contanti: '),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: ic.contantiController,
                              onChanged: (value) {
                                ic.contanti.value = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Assegni: '),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: ic.assegniController,
                              onChanged: (value) {
                                ic.assegni.value = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Titoli: '),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: ic.titoliController,
                              onChanged: (value) {
                                ic.titoli.value = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            //SE HAI SELEZIONATO ALMENO UNA RIGA
                            if (ic.countSelectedRows() > 0) {
                              //SE IL VALORE RESIDUO DELLE RIGHE SELEZIONATE E' MAGGIORE O UGUALE AL VALORE CHE SI STA PAGANDO
                              if (ic.sommaImportoPartiteSelezionate() >=
                                  ic.getValorePagamentoTotale()) {
                                if (await ic.paga(
                                        cc.clienteSelezionato.value.mbpcId,
                                        wc) >
                                    0) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  ic.resetSelection();
                                  snackBar("Avviso", "Pagamento inviato",
                                      Colors.green);
                                }
                              } else {
                                snackBar(
                                    "Attenzione!!",
                                    "Il totale selezionato è minore del totale pagato, selezionare altre righe",
                                    Colors.red);
                              }
                            } else {
                              snackBar(
                                  "Attenzione!!",
                                  "Non è sata selezionata nessuna riga.",
                                  Colors.red);
                            }
                          },
                          child: Text('Paga')),
                    )
                  ]),
                ))
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(10),
              ),
              child: cc.clienteSelezionato.value.mbanId != 0
                  ? SingleChildScrollView(
                      child: GetBuilder<IncassiController>(
                        builder: (ic) => (DataTable(
                          columns: ic.header,
                          rows: List.generate(
                              ic.scadenziario.length,
                              (index) => DataRow(
                                      selected: ic.selectedRows.contains(
                                          ic.scadenziario[index].capaId),
                                      onSelectChanged: (isSelected) {
                                        ic.toggleRowSelection(
                                            ic.scadenziario[index].capaId,
                                            isSelected ?? false);
                                      },
                                      cells: <DataCell>[
                                        DataCell(Text(ic
                                            .scadenziario[index].capaNumDoc
                                            .toString())),
                                        DataCell(Text(ic
                                            .scadenziario[index].capaAnnoDoc
                                            .toString())),
                                        DataCell(Text(ic.getScadenza(index))),
                                        DataCell(Text(
                                            '€ ${ic.scadenziario[index].capaImportoDare.toStringAsFixed(2)}')),
                                        DataCell(Text(
                                            '€ ${ic.scadenziario[index].capaImportoAvere.toStringAsFixed(2)}')),
                                        DataCell(Text(
                                            '€ ${ic.scadenziario[index].capaResiduo.toStringAsFixed(2)}'))
                                      ])),
                        )),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Seleziona un cliente',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          )),
        )
      ],
    );
  }

  SnackbarController snackBar(String title, String message, Color color) {
    return Get.snackbar(
      title, // Titolo
      message, // Messaggio
      snackPosition:
          SnackPosition.TOP, // Posizione dello Snackbar (TOP o BOTTOM)
      colorText: Colors.white, // Colore del testo
      backgroundColor: color, // Colore di sfondo dello Snackbar
      borderRadius: 20, // Raggio del bordo dello Snackbar
      margin: const EdgeInsets.all(10), // Margine intorno allo Snackbar
      duration: const Duration(
          seconds: 5), // Durata della visualizzazione dello Snackbar
      isDismissible: true, // Permette di scorrere via lo Snackbar
      dismissDirection:
          DismissDirection.endToStart, // Direzione in cui può essere scartato
      forwardAnimationCurve:
          Curves.easeOutBack, // Curva di animazione dell'entrata dello Snackbar
    );
  }
}



/* GetBuilder<IncassiController>(
                    builder: (ic) => ListView.separated(
                      itemCount: ic.scadenziario.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            ic.switchSelection(index);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Documento',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ic.scadenziario[index].colore.value,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      ic.scadenziario[index].capaNumDoc
                                          .toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Data Documento',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ic.scadenziario[index].colore.value,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      ic.scadenziario[index].capaAnnoDoc
                                          .toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Scadenza',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ic.scadenziario[index].colore.value,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      ic.getScadenza(index),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Dare',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ic.scadenziario[index].colore.value,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '€ ${ic.scadenziario[index].capaImportoDare.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Avere',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            ic.scadenziario[index].colore.value,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '€ ${ic.scadenziario[index].capaImportoAvere.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Residuo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ic.scadenziario[index].colore
                                              .value),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      '€ ${ic.scadenziario[index].capaResiduo.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                              /* Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DoppioTesto(
                            testo1: 'Doc: ',
                            fontSize1: 15,
                            testo2: '9525',
                            fontSize2: 15,
                          ),
                                              ),
                                              Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DoppioTesto(
                            testo1: 'Del: ',
                            fontSize1: 15,
                            testo2: '02/05/2023',
                            fontSize2: 15,
                          ),
                                              ), */
                            ],
                          ),
                        );
                      },
                    ),
                  ) */