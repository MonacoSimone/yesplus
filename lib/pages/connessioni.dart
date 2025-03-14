import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../controllers/clienti_controller.dart';
import '../pages/messaggi.dart';
import '../controllers/controller_soket.dart';
import '../pages/query.dart';
import '../controllers/connessione_controller.dart';
import '../database/db_helper.dart';

class Connessioni extends StatelessWidget {
  const Connessioni({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnessioneController coc = Get.put(ConnessioneController());
    final ClientiController cc = Get.find<ClientiController>();
    //final WebSocketController ws = Get.put(WebSocketController());
    //final WebSocketController ws = Get.find<WebSocketController>();
    //debugPrint('isConnected: ${ws.isConnected.value}');
    coc.getServerAddressApi();
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONNESSIONE AL SERVER'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => WebSocketController.isConnected.value
                  ? const Icon(
                      Icons.sync,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.sync_disabled,
                      color: Colors.red,
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Prima di procedere allo step 1 è necessario inserire gli indirizzi dei server nella sezione parametri.',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent),
            ),
            const Gap(10),
            Container(
              width: context.width,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(30),
                  InkWell(
                    onTap: () async {
                      //await ws.connectToWebSocket();
                      debugPrint(
                          'isConnected: ${WebSocketController.isConnected.value}');
                      debugPrint(
                          'isConnected: ${WebSocketController.socket?.connected}');
                      if (WebSocketController.socket?.connected ?? false) {
                        String res =
                            await WebSocketController.disconnectSocket();
                        debugPrint('Disconnesso: $res');
                        coc.stato.add(res.obs);
                        coc.connesione.value = 'Connetti';
                      } else {
                        await coc.connectToServer();
                        coc.connesione.value = 'Disconnetti';
                      }

                      //await coc.initMB_Anag(31, 6);
                      //await coc.initZprezziTv();
                      //await DatabaseHelper().mod();
                      //await coc.initOC_Anagr(32, 6);
                      //await coc.initOC_Arti(32, 6);
                      //await ws.sendPendingMessages();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AD9F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                      child: Obx(
                        () => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            coc.connesione.value,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      //debugdebugPrint(coc.indirizzo.value);
                      /* final ret = await DatabaseHelper()
                          .saveServerAPI(coc.indirizzoServer.text);
                      if (ret == 1) {
                        //coc.connectToServer();
                        coc.connectToServer();
                      } */
                      //Get.to(Messaggi());
                      if (await coc.step1() == 0) {
                        coc.initDB1();
                      } else {
                        Get.snackbar('Esito', 'Dispositivo Già Inizializzato',
                            colorText: Colors.white,
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.TOP);
                      }
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
                          'Step 1',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      //debugdebugPrint(coc.indirizzo.value);
                      if (await coc.step2() == 1) {
                        int idOCTipo = await DatabaseHelper().getTipoOrdine();
                        int idFTTipo = await DatabaseHelper().getTipoFattura();
                        int idBLTipo1 = await DatabaseHelper().getTipoBolla1();
                        int idBLTipo2 = await DatabaseHelper().getTipoBolla2();

                        int idAge = await DatabaseHelper().getIdAgente();
                        int idTipoConto =
                            await DatabaseHelper().getIdTipoConto();
                        coc.initDB2(idAge, idOCTipo, idFTTipo, idBLTipo1,
                            idBLTipo1, idTipoConto);
                      } else {
                        Get.snackbar('Esito', 'Dispositivo Già Inizializzato',
                            colorText: Colors.white,
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.TOP);
                      }
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
                          'Step 2',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      await cc.caricaClienti().then((anagrafica) {
                        //debugPrint(anagrafica);
                        cc.anagrafica.clienti.clear();
                        cc.anagraficaOriginale.clienti.clear();
                        for (var cliente in anagrafica) {
                          cc.anagrafica.clienti.add(cliente);
                          cc.anagraficaOriginale.clienti.add(cliente);
                        }
                      });
                      coc.stato.add(
                          'Cliente Caricati, puoi tornare alla pagina principale'
                              .obs);
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
                          'Carica Clienti',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      Get.to(() => QueryPage());
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
                          'Query',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      //Get.to(() => MessagesPage());
                      coc.showImei();
                      //await coc.initOC_Anagr(33, 6);
                      //await coc.initOC_Arti(33, 6);
                      //await coc.initZprezziTv();
                      //await coc.getMBDiv();
                      //await coc.getMBSoc();
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
                          'Codice Dispositivo',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      //DatabaseHelper().exportDatabase1();
                      Get.to(() => MessagesPage());
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
                          'Messaggi',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      DatabaseHelper().exportDatabase1();
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
                          'Scarica DB',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),
                  InkWell(
                    onTap: () async {
                      Get.defaultDialog(
                        title: 'Reinizializzazione',
                        content: Container(
                          width: 600,
                          height: 200,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Scegli tabella da reinizializzare'),
                              Gap(20),
                              DropdownButtonFormField<String>(
                                value: coc.selectedTable.value,
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    coc.selectedTable.value = newValue;
                                  }
                                },
                                items: coc.tables.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                              ),
                              Gap(30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      coc.executeAction();
                                      Get.back();
                                    },
                                    child: const Center(child: Text('Esegui')),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Center(child: Text('Chiudi')),
                                  ),
                                ],
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Reinizializza',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            Expanded(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => ListView.builder(
                      controller: coc.scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: coc.stato.length,
                      itemBuilder: (BuildContext context, int index) {
                        // WidgetsBinding.instance
                        //   .addPostFrameCallback((_) => coc.scrollToEnd());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            child: Text(
                              coc.stato[index].value,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
