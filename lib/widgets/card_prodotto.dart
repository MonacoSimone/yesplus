import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/ordine_controller.dart';
import '../models/catalogo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/flavor_scripts.dart';

class CardProdotto extends StatelessWidget {
  const CardProdotto({
    Key? key,
    required this.desc,
    required this.id,
    required this.matricola,
    required this.classe,
    required this.uniMis,
    required this.prezzo,
    required this.stato,
    required this.idIva,
    required this.serverApi,
    required this.sconto1,
    required this.sconto2,
    required this.sconto3,
  }) : super(key: key);

  final desc;
  final id;
  final matricola;
  final classe;
  final uniMis;
  final double prezzo;
  final stato;
  final int idIva;
  final String serverApi;
  final double sconto1;
  final double sconto2;
  final double sconto3;

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Log dettagliato
    switch (connectivityResult) {
      case [ConnectivityResult.mobile]:
        debugPrint('Connesso a rete mobile');
        return true;
      case [ConnectivityResult.wifi]:
        debugPrint('Connesso a rete Wi-Fi');
        return true;
      case [ConnectivityResult.none]:
        debugPrint('Nessuna connessione a Internet');
        return false;
      default:
        debugPrint('Stato della connessione sconosciuto');
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();
    final OrdineController ordineCt = Get.put(OrdineController());
    final ClientiController _clientiCt = Get.find<ClientiController>();
    ordineCt.isKeyboardOpen.value =
        (MediaQuery.of(context).viewInsets.bottom > 0);
    // Calcola l'altezza disponibile per il dialogo
    final height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () async {
        await ordineCt.getInfoProdotto(
            id, _clientiCt.clienteSelezionato.value.mbpcId);
        // Recupera le scontistiche predefinite del cliente per il prodotto specifico
        /* List<double?> sconti = await DatabaseHelper().getScontiCliente(
          _clientiCt.clienteSelezionato.value.mbpcId,
          id, // ID del prodotto
        ); */
        bool res = await isConnected();
        debugPrint('result $res');
        if (res) {
          await ordineCt.geDisponibilita(id);
        }
        debugPrint(sconto1.toString());
        // Aggiorna i TextField con i valori di sconto se disponibili
        ordineCt.textSc1.text =
            sconto1 != 0 ? sconto1.toStringAsFixed(2) : 'Sconto 1';
        ordineCt.textSc2.text =
            sconto2 != 0 ? sconto2.toStringAsFixed(2) : 'Sconto 2';
        ordineCt.textSc3.text =
            sconto3 != 0 ? sconto3.toStringAsFixed(2) : 'Sconto 3';

        // Calcola l'altezza della tastiera
        ordineCt.dialogHeight.value = height * 0.65;
        Get.defaultDialog(
            barrierDismissible: false,
            title: 'Info Prodotto',
            backgroundColor: Colors.white,
            content: Obx(
              () => SizedBox(
                height: ordineCt.dialogHeight.value,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: context.width * 0.65,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined),
                                iconSize: 30,
                                onPressed: () {
                                  Get.back();
                                  ordineCt.qtaProdotto.value = 1;
                                  ordineCt.textQta.text = '1.0';
                                },
                              )
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(10), // Image border
                                  child: SizedBox(
                                    width: context.width * 0.18,
                                    height: (context.height * 0.25),
                                    child: FutureBuilder<bool>(
                                      future: isConnected(),
                                      builder: (context, snapshot) {
                                        debugPrint(snapshot.connectionState
                                            .toString());

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError ||
                                            !snapshot.data!) {
                                          debugPrint(
                                              'sto in snapshot.hasError');
                                          return Image.asset(
                                              flavorScripts.getAssetImagePath(
                                                  'EMPTY_NORM.png'));
                                        } else {
                                          debugPrint(
                                              'Sto nella costruzine dell\'immagine');
                                          return FadeInImage.assetNetwork(
                                            fit: BoxFit.cover,
                                            placeholder:
                                                flavorScripts.getAssetImagePath(
                                                    'EMPTY_NORM.png'),
                                            imageErrorBuilder:
                                                (BuildContext context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                              debugPrint(exception.toString());
                                              debugPrint(
                                                  'error builder: ${exception.toString()}');
                                              if (exception
                                                  .toString()
                                                  .contains('404')) {
                                                debugPrint('sto in 404');
                                                return Image.asset(flavorScripts
                                                    .getAssetImagePath(
                                                        'EMPTY_NORM.png'));
                                              }
                                              debugPrint('sto sotto il 404');
                                              debugPrint(
                                                  '$serverApi/images/${matricola}_NORM.jpg');
                                              return Image.asset(flavorScripts
                                                  .getAssetImagePath(
                                                      'EMPTY_NORM.png'));
                                            },
                                            image:
                                                '$serverApi/images/${matricola}_NORM.jpg',
                                          );
                                        }
                                      },
                                    ),
                                  )),
                              /* FadeInImage.assetNetwork(
                                        fit: BoxFit.cover,
                                        placeholder:
                                            flavorScripts.getAssetImagePath('EMPTY_NORM.png'),
                                        imageErrorBuilder:
                                            (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                          return Image.asset(
                                              flavorScripts.getAssetImagePath('EMPTY_NORM.png'));
                                        },
                                        image:
                                            '$serverApi/images/${matricola}_NORM.jpg'),
                                  ) ),*/
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: context.width * 0.35,
                                    child: Text(
                                      desc,
                                      maxLines: 3,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Container(
                                      width: context.width * 0.35,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              width: 1.0, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child:
                                          DataTable(columns: const <DataColumn>[
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Doc.',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Data',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Qta',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Prezzo',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Unitario',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                      ], rows: ordineCt.righeStorico),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10),
                          child: Row(
                            children: [
                              Container(
                                width: context.width * 0.15,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.black, width: 0.5)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          /* if (ordineCt.qtaProdotto.value > 1) {
                                            ordineCt.qtaProdotto.value--;
                                          } */
                                          if (double.parse(
                                                  ordineCt.textQta.text) >
                                              1) {
                                            ordineCt
                                                .textQta.text = (double.parse(
                                                        ordineCt.textQta.text) -
                                                    1)
                                                .toString();
                                          }
                                        },
                                        child: const SizedBox(
                                          height: 50,
                                          width: 40,
                                          child: Text(
                                            '-',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 35,
                                                fontWeight: FontWeight.w200),
                                          ),
                                        )),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: TextField(
                                          onChanged: (newvalue) {
                                            ordineCt.textQta.text = newvalue;
                                          },
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide
                                                  .none, // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                                              borderRadius: BorderRadius.circular(
                                                  5), // Personalizza il raggio del bordo arrotondato se necessario
                                            ),
                                          ),
                                          controller: ordineCt.textQta,
                                          autocorrect: false,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          ordineCt.textQta.text = (double.parse(
                                                      ordineCt.textQta.text) +
                                                  1)
                                              .toString();
                                          //ordineCt.qtaProdotto.value++;
                                        },
                                        child: const SizedBox(
                                          height: 50,
                                          width: 40,
                                          child: Text(
                                            '+',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 35,
                                                fontWeight: FontWeight.w200),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Text(
                                'Omaggio',
                                style: TextStyle(fontSize: 18),
                              ),
                              Transform.scale(
                                scale: 1.4,
                                child: Obx(
                                  () => Checkbox(
                                      checkColor: Colors.black,
                                      fillColor:
                                          WidgetStateProperty.all(Colors.white),
                                      value: ordineCt.omaggio.value,
                                      onChanged: (bool? value) {
                                        ordineCt.switchOmaggio();
                                      },
                                      side: WidgetStateBorderSide.resolveWith(
                                        (states) => const BorderSide(
                                            width: 1.0, color: Colors.black),
                                      )),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: ordineCt.textSc1,
                                  focusNode: ordineCt.textSc1Node,
                                  onChanged: (newvalue) {
                                    ordineCt.textSc1.text = newvalue;
                                  },
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                                      borderRadius: BorderRadius.circular(
                                          5), // Personalizza il raggio del bordo arrotondato se necessario
                                    ),
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: ordineCt.textSc2,
                                  focusNode: ordineCt.textSc2Node,
                                  onChanged: (newvalue) {
                                    ordineCt.textSc2.text = newvalue;
                                  },
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                                      borderRadius: BorderRadius.circular(
                                          5), // Personalizza il raggio del bordo arrotondato se necessario
                                    ),
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: ordineCt.textSc3,
                                  focusNode: ordineCt.textSc3Node,
                                  onChanged: (newvalue) {
                                    ordineCt.textSc3.text = newvalue;
                                  },
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                                      borderRadius: BorderRadius.circular(
                                          5), // Personalizza il raggio del bordo arrotondato se necessario
                                    ),
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.number,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            width: context.width,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  ordineCt.qtaProdotto.value =
                                      double.parse(ordineCt.textQta.text);
                                  await ordineCt.addInCart(
                                      Prodotto(
                                          id: id,
                                          classe: classe,
                                          matricola: matricola,
                                          descrizione: desc,
                                          unMis: uniMis,
                                          prezzo: prezzo,
                                          stato: 1,
                                          idIva: idIva,
                                          sconto1: sconto1,
                                          sconto2: sconto2,
                                          sconto3: sconto3),
                                      ordineCt.qtaProdotto);
                                  ordineCt.qtaProdotto.value = 1;
                                  ordineCt.textQta.text = '1.0';
                                  ordineCt.textSc1.text = 'Sconto 1';
                                  ordineCt.textSc2.text = 'Sconto 2';
                                  ordineCt.textSc3.text = 'Sconto 3';
                                  ordineCt.omaggio.value = false;
                                  Get.back();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8AD9F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 50,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Aggiungi',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Disponibilta: ${ordineCt.disponibilita.value}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prezzo:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Obx(
                                    () => RichText(
                                      text: TextSpan(
                                          text: '€ ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 30),
                                          children: [
                                            TextSpan(
                                                text: (prezzo *
                                                        ordineCt
                                                            .qtaProdotto.value)
                                                    .toStringAsFixed(2),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 30))
                                          ]),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 6.0,
                    right: 6.0,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Image border
                      child: SizedBox(
                        width: context.width,
                        height: (context.height / 4) * 0.7,
                        child: FutureBuilder<bool>(
                          future: isConnected(),
                          builder: (context, snapshot) {
                            debugPrint(snapshot.connectionState.toString());
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError || !snapshot.data!) {
                              return Image.asset(flavorScripts
                                  .getAssetImagePath('EMPTY_NORM.png'));
                            } else {
                              return FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                placeholder: flavorScripts
                                    .getAssetImagePath('EMPTY_NORM.png'),
                                imageErrorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  if (exception.toString().contains('404')) {
                                    return Image.asset(flavorScripts
                                        .getAssetImagePath('EMPTY_NORM.png'));
                                  }
                                  return Image.asset(flavorScripts
                                      .getAssetImagePath('EMPTY_NORM.png'));
                                },
                                image:
                                    '$serverApi/images/${matricola}_NORM.jpg',
                              );
                            }
                          },
                        ),
                      )),
                  /* ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Image border
                      child: SizedBox(
                        width: context.width,
                        height: (context.height / 4) * 0.7,
                        child: FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            placeholder: flavorScripts.getAssetImagePath('EMPTY_NORM.png'),
                            imageErrorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                  flavorScripts.getAssetImagePath('EMPTY_NORM.png'));
                            },
                            image: '$serverApi/images/${matricola}_NORM.jpg'),
                      )), */
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    desc,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€ ${prezzo.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text('($uniMis)',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15))
                      ],
                    ))
              ]),
        ),
      ),
    );
  }
}
