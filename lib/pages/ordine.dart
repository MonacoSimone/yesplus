import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../controllers/controller_soket.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/ordine_controller.dart';
import '../utils/flavor_scripts.dart';
import '../widgets/card_prodotto.dart';

class Ordine extends StatelessWidget {
  const Ordine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = context.width - (context.width * 0.06) - 24;
    final OrdineController ordineCt = Get.find<OrdineController>();
    final ClientiController _clienteCt = Get.find<ClientiController>();
    final WebSocketController wc = Get.find<WebSocketController>();
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              /* Container(
                width: width * 0.25,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownSearch<String>(
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        hintText: 'Classi Prodotto',
                        border: InputBorder.none,
                      ),
                    ),
                    onChanged: (s) {
                      ordineCt.filtraProdotti(s!);
                    },
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: (filter, infiniteScrollProps) => ordineCt.classi,
                  ),
                ),
              ), */
              Gap(10),
              Container(
                width: width * 0.25,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      onChanged: (val) {
                        if (val.length > 3 || val.isEmpty) {
                          ordineCt.filtraProdottiDescr(val);
                        }
                      },
                      textInputAction: TextInputAction.done,
                      controller: ordineCt.textDescr,
                      focusNode: ordineCt.textDescrNode,
                      onTapOutside: (pointerDownEvent) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide
                              .none, // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                          borderRadius: BorderRadius.circular(
                              5), // Personalizza il raggio del bordo arrotondato se necessario
                        ),
                      ),
                    )),
              ),
              Gap(10),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Gap(10),
                    const Text(
                      'Già Acquistati',
                      style: TextStyle(fontSize: 15),
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: Obx(
                        () => Checkbox(
                            checkColor: Colors.black,
                            fillColor: WidgetStateProperty.all(Colors.white),
                            value: ordineCt.acquistati.value,
                            onChanged: (bool? value) async {
                              await ordineCt.switchAcquistati();
                              if (ordineCt.acquistati.value) {
                                ordineCt.filtraProdottiAcquistati(
                                    _clienteCt.clienteSelezionato.value.mbpcId);
                              } else {
                                ordineCt.resetProdotti();
                              }
                            },
                            side: WidgetStateBorderSide.resolveWith(
                              (states) => const BorderSide(
                                  width: 1.0, color: Colors.black),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Container(
                width: width * 0.10,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag),
                    Text('Carrello'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width * 0.65,
                height: context.height - 146,
                child: AnimationLimiter(
                  child: Obx(
                    () => GridView.builder(
                      itemCount: ordineCt.prodotti.length,
                      itemBuilder: (context, index) => CardProdotto(
                        id: ordineCt.prodotti[index].id,
                        desc: ordineCt.prodotti[index].descrizione,
                        matricola: ordineCt.prodotti[index].matricola,
                        uniMis: ordineCt.prodotti[index].unMis,
                        prezzo: ordineCt.prodotti[index].prezzo,
                        stato: ordineCt.prodotti[index].stato,
                        classe: ordineCt.prodotti[index].classe,
                        idIva: ordineCt.prodotti[index].idIva,
                        serverApi: ordineCt.serverApi.value,
                        sconto1: ordineCt.prodotti[index].sconto1,
                        sconto2: ordineCt.prodotti[index].sconto2,
                        sconto3: ordineCt.prodotti[index].sconto3,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.70,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Container(
                  alignment: Alignment.topCenter,
                  width: width * 0.35,
                  margin: const EdgeInsets.only(bottom: 146),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1.0, color: Colors.grey.shade400),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Prodotti',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                iconSize: 30,
                                onPressed: () {
                                  ordineCt.prodottiCarrello.clear();
                                  ordineCt.totale.value = 0;
                                  ordineCt.subTotale.value = 0;
                                  ordineCt.sconto.value = 0;
                                  ordineCt.tasse.value = 0;
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      /* Expanded(
                        child: Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            itemCount: ordineCt.prodottiCarrello.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ordineCt.prodottiCarrello.isEmpty
                                  ? SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.asset(
                                        'assets/common/images/shopping-cart-empty.jpeg',
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : ListOrderElement(
                                      ordineCt: ordineCt,
                                      index: index,
                                    );
                            },
                          ),
                        ),
                      ), */
                      SizedBox(
                        height: 300, // Assegna un'altezza fissa o dinamica
                        child: Obx(
                          () => ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: ordineCt.prodottiCarrello.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ordineCt.prodottiCarrello.isEmpty
                                  ? SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.asset(
                                        'assets/common/images/shopping-cart-empty.jpeg',
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : ListOrderElement(
                                      ordineCt: ordineCt,
                                      index: index,
                                    );
                            },
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 1.0, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotale',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Obx(
                                  () => RichText(
                                    text: TextSpan(
                                        text: '€ ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 20),
                                        children: [
                                          TextSpan(
                                              text: ordineCt.subTotale.value
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20))
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tasse',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Obx(
                                  () => RichText(
                                    text: TextSpan(
                                        text: '€ ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 20),
                                        children: [
                                          TextSpan(
                                              text: ordineCt.tasse.value
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 20))
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sconto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Obx(
                                  () => RichText(
                                    text: TextSpan(
                                        text: '€ ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 20),
                                        children: [
                                          TextSpan(
                                              text: ordineCt.sconto.value
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20))
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1.0, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Totale',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30)),
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
                                              text: ordineCt.totale.value
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      await ordineCt.resetDestinatari();
                                      await ordineCt.loadDestinatari(_clienteCt
                                          .clienteSelezionato.value.mbanId);
                                      _clienteCt.clienteSelezionato.value
                                                  .mbanId ==
                                              0
                                          ? Get.defaultDialog(
                                              title: 'Attenzione',
                                              content: const Text(
                                                'Selezionare un cliente',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              confirm: ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: const Text('ok')))
                                          : Get.defaultDialog(
                                              title:
                                                  'Confermi la creazione dell\'ordine?',
                                              titleStyle: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w700),
                                              content: SizedBox(
                                                width: context.width * 0.6,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                        height:
                                                            20), // Aggiungi spazio sopra il campo di testo
                                                    TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Note',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      controller: ordineCt
                                                          .noteController, // Aggiungi un controller per il campo di testo
                                                    ),
                                                    Gap(40),
                                                    const Text(
                                                        'Scegli la Destinazione'),
                                                    Gap(5),
                                                    DropdownButtonFormField<
                                                        String>(
                                                      value: ordineCt
                                                          .selectedValue.value,
                                                      onChanged: (newValue) {
                                                        if (newValue != null) {
                                                          ordineCt.selectedValue
                                                              .value = newValue;
                                                        }
                                                      },
                                                      items: ordineCt
                                                          .destinatari
                                                          .map((item) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: item,
                                                          child: Text(item),
                                                        );
                                                      }).toList(),
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            40), // Aggiungi spazio sotto il campo di testo
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0,
                                                              bottom: 40.0,
                                                              left: 8.0,
                                                              right: 8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          SizedBox(
                                                            width: 150,
                                                            height: 50,
                                                            child: FilledButton(
                                                              onPressed:
                                                                  () async {
                                                                // Passa le note al metodo salvaOrdine
                                                                await ordineCt
                                                                    .salvaOrdine(
                                                                  _clienteCt
                                                                      .clienteSelezionato
                                                                      .value
                                                                      .mbpcId,
                                                                  _clienteCt
                                                                      .clienteSelezionato
                                                                      .value
                                                                      .mbanId,
                                                                  ordineCt
                                                                      .totale
                                                                      .value,
                                                                  wc,
                                                                  ordineCt
                                                                      .noteController
                                                                      .text, // Passa il testo delle note
                                                                );
                                                                ordineCt
                                                                    .prodottiCarrello
                                                                    .clear();
                                                                ordineCt.totale
                                                                    .value = 0;
                                                                ordineCt
                                                                    .subTotale
                                                                    .value = 0;
                                                                ordineCt.sconto
                                                                    .value = 0;
                                                                ordineCt.tasse
                                                                    .value = 0;
                                                                ordineCt
                                                                    .noteController
                                                                    .clear(); // Cancella il testo delle note
                                                              },
                                                              child: const Text(
                                                                  'Conferma',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 150,
                                                            height: 50,
                                                            child: FilledButton(
                                                              style:
                                                                  const ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStatePropertyAll<
                                                                            Color>(
                                                                        Colors
                                                                            .red),
                                                              ),
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: const Text(
                                                                  'Chiudi',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8AD9F2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      height: 50,
                                      child: const Text(
                                        'Procedi',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}

class ListOrderElement extends StatelessWidget {
  final OrdineController ordineCt;
  final int index;
  const ListOrderElement(
      {super.key, required this.ordineCt, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            heightFactor: 2,
            alignment: Alignment.centerLeft,
            child: Text(ordineCt.prodottiCarrello[index].nomeProdotto)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color(0xFF8AD9F2),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Obx(
                    () => RichText(
                      text: TextSpan(
                          text: ordineCt.prodottiCarrello[index].quantita.value
                              .toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 17),
                          children: const [
                            TextSpan(
                                text: 'x',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 17))
                          ]),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Row(
                  children: [
                    ButtonTheme(
                        child: ElevatedButton(
                      child: const Text(
                        '-',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        ordineCt.menoProdotto(index);
                      },
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    ButtonTheme(
                        child: ElevatedButton(
                      child: const Text('+', style: TextStyle(fontSize: 20)),
                      onPressed: () {
                        ordineCt.piuProdotto(index);
                      },
                    )),
                  ],
                ),
              ],
            ),
            Obx(
              () => RichText(
                text: TextSpan(
                    text: '€ ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 20),
                    children: [
                      TextSpan(
                          text: ordineCt.prodottiCarrello[index].totale
                              .toStringAsFixed(2),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 20))
                    ]),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
