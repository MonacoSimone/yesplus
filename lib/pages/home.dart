import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // <-- Aggiungi questo import
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../controllers/clienti_controller.dart';
import '../controllers/controller_soket.dart';
import '../controllers/documenti_controller.dart';
import '../controllers/fatt_mensi_controller.dart';
import '../controllers/incassi_controller.dart';
import '../controllers/ordine_controller.dart';
import '../controllers/page_controller.dart';
import '../controllers/sidebar_controller.dart';
import '../database/db_helper.dart';
import '../models/anagrafica.dart';
import '../pages/connessioni.dart';
import '../pages/documenti.dart';
import '../pages/incassi.dart';
import '../pages/ordine.dart';
import '../pages/parametri.dart';
import '../pages/ricerca_clienti.dart';
import '../utils/flavor_scripts.dart';

// 1. Convertito in StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. Spostiamo i controller nello State per accedervi facilmente
  final PagineController pageController = Get.put(PagineController());
  final SidebarController sidbarController = Get.put(SidebarController());
  final IncassiController ic = Get.find<IncassiController>();
  final ClientiController cc = Get.find<ClientiController>();
  final DocumentiController dc = Get.put(DocumentiController());
  final FatturatoController fc = Get.put(FatturatoController());
  final OrdineController oc = Get.put(OrdineController());
  final WebSocketController wsc = Get.find<WebSocketController>();

  // 3. Aggiungiamo initState per avviare il listener una sola volta
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _setupBackgroundSyncListener();
    });
  }

  // 4. NUOVO: Metodo per impostare il listener che reagisce ai cambi
  void _setupBackgroundSyncListener() {
    // Questo "worker" di GetX ascolterà per sempre i cambiamenti della variabile
    // nel WebSocketController e reagirà di conseguenza.
    ever(wsc.backgroundSyncResult, (Map<String, dynamic> result) {
      if (result.isEmpty || !mounted) return;

      final bool success = result['success'] ?? false;
      final String message = result['message'] ?? 'Operazione completata.';
      final String type = result['type'] ?? '';

      // Mostra una snackbar per notificare l'utente dell'esito
      Get.snackbar(
        success ? 'Sincronizzazione Completata' : 'Errore di Sincronizzazione',
        message,
        backgroundColor: success ? Colors.green : Colors.red,
        colorText: Colors.white,
      );

      // Se la sincronizzazione ha avuto successo, aggiorna i dati pertinenti!
      if (success && cc.clienteSelezionato.value.mbpcId != 0) {
        if (type == 'payment') {
          // Se era un pagamento, ricarica la lista delle partite!
          ic.filtraIncassi(cc.clienteSelezionato.value.mbpcId);
        }
        if (type == 'order') {
          // Se era un ordine, ricarica la lista documenti
          dc.getDocumenti(cc.clienteSelezionato.value.mbpcId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: context.width * 0.06,
        leading: Center(
          child: Image.asset(
            'assets/common/images/shopping-cart-empty.jpeg',
            height: 50,
          ),
        ),
        title: const Text('ORDER ENTRY (v 1.0.5)'),
        actions: [
          Obx(
            () => cc.clienteSelezionato.value.mbanId != 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(cc.clienteSelezionato.value.mbanRagSoc),
                        const SizedBox(width: 10),
                        IconButton(
                            onPressed: () {
                              cc.clienteSelezionato.value = Cliente(
                                  mbpcId: 0,
                                  mbanId: 0,
                                  mbanRagSoc: 'mbanRagSoc',
                                  mbanIndirizzo: 'mbanIndirizzo',
                                  mbanComune: 'mbanComune',
                                  mbanCodFiscale: 'mbanCodFiscale',
                                  mbanPartitaIva: 'mbanPartitaIva',
                                  mbpcConto: '',
                                  mbpcSottoConto: '',
                                  mbanTelefono: 'null',
                                  mbanEmail: '',
                                  mbanEmail2: 'null',
                                  mbanGpse: 'null',
                                  mbanGpsn: 'null',
                                  mbanDataFineVal: 'null',
                                  sconto1: 0.0,
                                  sconto2: 0.0,
                                  sconto3: 0.0);
                              ic.resetFiltroIncassi();
                              dc.resetDocumenti();
                              cc.resetClienti();
                              fc.resetFatturato();
                              oc.resetOrdine();
                              oc.clearProdotti();
                              ic.importoselezionatodapagare=0.0;
                            },
                            icon: const Icon(
                              Icons.highlight_off,
                              color: Colors.red,
                            )),
                        const Gap(15),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Parametri());
                            },
                            icon: const Icon(LineIcons.cog)),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Connessioni());
                            },
                            icon: const Icon(LineIcons.globe)),
                        // Usiamo wsc invece di WebSocketController per coerenza
                        Obx(() => WebSocketController.isConnected.value
                            ? const Icon(
                                Icons.sync,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.sync_disabled,
                                color: Colors.red,
                              ))
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const Gap(15),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Parametri());
                            },
                            icon: const Icon(LineIcons.cog)),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Connessioni());
                            },
                            icon: const Icon(LineIcons.globe)),
                        // Usiamo wsc invece di WebSocketController per coerenza
                        Obx(() => WebSocketController.isConnected.value
                            ? const Icon(
                                Icons.sync,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.sync_disabled,
                                color: Colors.red,
                              )),
                      ],
                    )),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: context.width * 0.06,
            height: context.height,
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        width: 1, color: Color.fromARGB(255, 205, 205, 205)))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Obx(
                () => Column(
                  children: [
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.person_search),
                      isSelected: sidbarController.pulsantiPagine[0].value,
                      selectedIcon:
                          const Icon(Icons.person_search, color: Colors.black),
                      onPressed: () {
                        navigateToPage(0, pageController);
                        sidbarController.onPageChanged(0);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.shopping_cart),
                      isSelected: sidbarController.pulsantiPagine[1].value,
                      selectedIcon:
                          const Icon(Icons.shopping_cart, color: Colors.black),
                      onPressed: () async {
                        navigateToPage(1, pageController);
                        sidbarController.onPageChanged(1);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.payments),
                      isSelected: sidbarController.pulsantiPagine[2].value,
                      selectedIcon:
                          const Icon(Icons.payments, color: Colors.black),
                      onPressed: () {
                        navigateToPage(2, pageController);
                        sidbarController.onPageChanged(2);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      isSelected: sidbarController.pulsantiPagine[3].value,
                      icon: const Icon(Icons.receipt_long),
                      selectedIcon:
                          const Icon(Icons.receipt_long, color: Colors.black),
                      onPressed: () {
                        navigateToPage(3, pageController);
                        sidbarController.onPageChanged(3);
                      },
                    ),
                    SizedBox(
                      height: context.height * 0.09,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(children: [
              SizedBox(
                width: context.width,
                height: context.height,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    flavorScripts.getAssetImagePath('applogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PageView(
                controller: pageController.pageController.value,
                pageSnapping: false,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RicercaClienti(),
                  Ordine(),
                  Incassi(),
                  Documenti(),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void navigateToPage(int input, PagineController pgsController) {
    pgsController.animateTo(input);
    pgsController.onPageChanged(input);
  }
}

/* import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../controllers/controller_soket.dart';
import '../controllers/documenti_controller.dart';
import '../controllers/fatt_mensi_controller.dart';
import '../controllers/ordine_controller.dart';
import '../database/db_helper.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/incassi_controller.dart';
import '../controllers/page_controller.dart';
import '../controllers/sidebar_controller.dart';
import '../models/anagrafica.dart';
import '../pages/connessioni.dart';
import '../pages/documenti.dart';
import '../pages/incassi.dart';
import '../pages/ordine.dart';
import '../pages/parametri.dart';
import '../pages/ricerca_clienti.dart';
import '../utils/flavor_scripts.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PagineController pageController = Get.put(PagineController());
    final SidebarController sidbarController = Get.put(SidebarController());
    final IncassiController ic = Get.find<IncassiController>();
    final ClientiController cc = Get.find<ClientiController>();
    final DocumentiController dc = Get.put(DocumentiController());
    final FatturatoController fc = Get.put(FatturatoController());
    final OrdineController oc = Get.put(OrdineController());
    final WebSocketController wsc = Get.find<WebSocketController>();
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: context.width * 0.06,
        leading: Center(
          child: Image.asset(
            'assets/common/images/shopping-cart-empty.jpeg',
            height: 50,
          ),
        ),
        title: const Text('ORDER ENTRY (v 1.0.5)'),
        actions: [
          Obx(
            () => cc.clienteSelezionato.value.mbanId != 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(cc.clienteSelezionato.value.mbanRagSoc),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                            onPressed: () {
                              cc.clienteSelezionato.value = Cliente(
                                  mbpcId: 0,
                                  mbanId: 0,
                                  mbanRagSoc: 'mbanRagSoc',
                                  mbanIndirizzo: 'mbanIndirizzo',
                                  mbanComune: 'mbanComune',
                                  mbanCodFiscale: 'mbanCodFiscale',
                                  mbanPartitaIva: 'mbanPartitaIva',
                                  mbpcConto: '',
                                  mbpcSottoConto: '',
                                  mbanTelefono: 'null',
                                  mbanEmail: '',
                                  mbanEmail2: 'null',
                                  mbanGpse: 'null',
                                  mbanGpsn: 'null',
                                  mbanDataFineVal: 'null',
                                  sconto1: 0.0,
                                  sconto2: 0.0,
                                  sconto3: 0.0);
                              ic.resetFiltroIncassi();
                              dc.resetDocumenti();
                              cc.resetClienti();
                              fc.resetFatturato();
                              oc.resetOrdine();
                              oc.clearProdotti();
                            },
                            icon: const Icon(
                              Icons.highlight_off,
                              color: Colors.red,
                            )),
                        const Gap(15),
                        IconButton(
                            onPressed: () async {
                              List<Map<String, dynamic>> agente =
                                  await DatabaseHelper().getAgente();

                              if (agente[0]["MBAN_RagSoc"] != null) {
                                Get.to(() => const Parametri());
                              }
                            },
                            icon: const Icon(LineIcons.cog)),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Connessioni());
                            },
                            icon: const Icon(LineIcons.globe)),
                        WebSocketController.isConnected.value
                            ? const Icon(
                                Icons.sync,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.sync_disabled,
                                color: Colors.red,
                              )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const Gap(15),
                        IconButton(
                            onPressed: () async {
                              Get.to(() => const Parametri());
                            },
                            icon: const Icon(LineIcons.cog)),
                        IconButton(
                            onPressed: () {
                              Get.to(() => const Connessioni());
                            },
                            icon: const Icon(LineIcons.globe)),
                        WebSocketController.isConnected.value
                            ? const Icon(
                                Icons.sync,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.sync_disabled,
                                color: Colors.red,
                              ),
                      ],
                    )),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: context.width * 0.06,
            height: context.height,
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        width: 1, color: Color.fromARGB(255, 205, 205, 205)))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Obx(
                () => Column(
                  children: [
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.person_search),
                      isSelected: sidbarController.pulsantiPagine[0].value,
                      selectedIcon: const Icon(
                        Icons.person_search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        navigateToPage(0, pageController);
                        sidbarController.onPageChanged(0);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.shopping_cart),
                      isSelected: sidbarController.pulsantiPagine[1].value,
                      selectedIcon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        navigateToPage(1, pageController);
                        sidbarController.onPageChanged(1);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      icon: const Icon(Icons.payments),
                      isSelected: sidbarController.pulsantiPagine[2].value,
                      selectedIcon: const Icon(
                        Icons.payments,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        navigateToPage(2, pageController);
                        sidbarController.onPageChanged(2);
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      color: Colors.black45,
                      isSelected: sidbarController.pulsantiPagine[3].value,
                      icon: const Icon(Icons.receipt_long),
                      selectedIcon: const Icon(
                        Icons.receipt_long,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        navigateToPage(3, pageController);
                        sidbarController.onPageChanged(3);
                      },
                    ),
                    SizedBox(
                      height: context.height * 0.09,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(children: [
              SizedBox(
                width: context.width,
                height: context.height,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    flavorScripts.getAssetImagePath('applogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PageView(
                controller: pageController.pageController.value,
                pageSnapping: false,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RicercaClienti(),
                  Ordine(),
                  Incassi(),
                  Documenti(),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  navigateToPage(int input, PagineController pgsController) {
    pgsController.animateTo(input);
    pgsController.onPageChanged(input);
  }
}


/*

Expanded(
            child: Stack(children: [
              Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    flavorScripts.getAssetImagePath('applogo.png'),
                  ),
                ),
              ),
              PageView(
                controller: pageController.pageController.value,
                pageSnapping: false,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RicercaClienti(),
                  Ordine(),
                  Incassi(),
                  Documenti(),
                ],
              ),
            ]),
          ) */ */
