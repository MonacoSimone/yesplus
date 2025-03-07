import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../controllers/controller_soket.dart';
import '../controllers/parametri_controller.dart';
import '../database/db_helper.dart';
import '../widgets/campo_di_testo.dart';

class Parametri extends StatelessWidget {
  const Parametri({super.key});

  @override
  Widget build(BuildContext context) {
    var width = context.width;
    final ParametriController pc = Get.put(ParametriController());
    //final WebSocketController ws = Get.put(WebSocketController());
    final WebSocketController ws = Get.find<WebSocketController>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('PARAMETRI'),
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
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            width: width - 10,
            height: context.height,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 30),
                    child: Text(
                      'Info Server',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 62,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextField(
                          controller: pc.serverAPI,
                          onChanged: (newvalue) {
                            pc.serverAPI.text = newvalue;
                          },
                          focusNode: pc.serverAPINode,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                              borderRadius: BorderRadius.circular(
                                  5), // Personalizza il raggio del bordo arrotondato se necessario
                            ),
                          ),
                          autocorrect: false,
                          onTapOutside: (pointerDownEvent) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                      const Gap(10),
                      Container(
                        height: 62,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextField(
                          controller: pc.serverWSK,
                          onChanged: (newvalue) {
                            pc.serverWSK.text = newvalue;
                          },
                          focusNode: pc.serverWSKNode,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                              borderRadius: BorderRadius.circular(
                                  5), // Personalizza il raggio del bordo arrotondato se necessario
                            ),
                          ),
                          autocorrect: false,
                          onTapOutside: (pointerDownEvent) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                      const Gap(10),
                      Container(
                        height: 62,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextField(
                          controller: pc.imeiTxtCT,
                          onChanged: (newvalue) {
                            pc.imeiTxtCT.text = newvalue;
                          },
                          focusNode: pc.imeiTxtCTNode,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                              borderRadius: BorderRadius.circular(
                                  5), // Personalizza il raggio del bordo arrotondato se necessario
                            ),
                          ),
                          autocorrect: false,
                          onTapOutside: (pointerDownEvent) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                      const Gap(20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await DatabaseHelper()
                                .saveServerAPI(pc.serverAPI.text);
                            await DatabaseHelper()
                                .saveServerWSK(pc.serverWSK.text);
                            await DatabaseHelper().saveIMEI(pc.imeiTxtCT.text);
                            Get.snackbar('Esito', 'Salvataggio Riuscito',
                                colorText: Colors.white,
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.TOP);
                          } catch (e) {
                            debugPrint('errore: $e');
                          }
                        },
                        child: const Text('Salva'),
                      ),
                    ],
                  ),
                  const Gap(20),
                  const Divider(),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Agente: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemAgente.value.toString(),
                                onChanged: (newValue) {
                                  debugPrint(newValue);
                                  pc.selectedItemAgente.value =
                                      int.parse(newValue!);
                                },
                                items: pc.agenti.map<DropdownMenuItem<String>>(
                                    (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['MBAG_ID']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'MBAN_RagSoc']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      ),
                      CampoDiTesto(
                          text: 'Password: ',
                          controller: pc.passwordCT,
                          val: pc.password,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Gap(40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tipo Ordine: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemIdOC.value.toString(),
                                onChanged: (newValue) {
                                  pc.selectedItemIdOC.value =
                                      int.parse(newValue!);
                                },
                                items: pc.octipi.map<DropdownMenuItem<String>>(
                                    (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['OCTI_ID']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'OCTI_Descr']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Tipo Conto: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemConto.value.toString(),
                                onChanged: (newValue) {
                                  pc.selectedItemConto.value =
                                      int.parse(newValue!);
                                },
                                items: pc.tipiConto
                                    .map<DropdownMenuItem<String>>(
                                        (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['MBTC_TipoConto']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'MBTC_Descr']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      )
                    ],
                  ),
                  const Gap(40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tipo Fattura: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemIdFT.value.toString(),
                                onChanged: (newValue) {
                                  pc.selectedItemIdFT.value =
                                      int.parse(newValue!);
                                },
                                items: pc.fttipi.map<DropdownMenuItem<String>>(
                                    (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['FTTI_ID']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'FTTI_Descr']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Tipo Bolla 1: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemIdBL1.value.toString(),
                                onChanged: (newValue) {
                                  pc.selectedItemIdBL1.value =
                                      int.parse(newValue!);
                                },
                                items: pc.bltipi1.map<DropdownMenuItem<String>>(
                                    (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['BLTI_ID']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'BLTI_Descr']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Tipo Bolla 2: ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Obx(() => DropdownButton<String>(
                                value: pc.selectedItemIdBL2.value.toString(),
                                onChanged: (newValue) {
                                  pc.selectedItemIdBL2.value =
                                      int.parse(newValue!);
                                },
                                items: pc.bltipi2.map<DropdownMenuItem<String>>(
                                    (Map<String, dynamic> value) {
                                  return DropdownMenuItem<String>(
                                    value: value['BLTI_ID']
                                        .toString(), // Assumi che esista una chiave 'id' in ogni elemento della mappa
                                    child: Text(value[
                                        'BLTI_Descr']), // Assumi che esista una chiave 'name' per la descrizione da mostrare
                                  );
                                }).toList(),
                              ))
                        ],
                      )
                    ],
                  ),
                  const Gap(30),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await DatabaseHelper().saveParameters(
                            pc.passwordCT.text,
                            pc.selectedItemIdOC.value,
                            pc.selectedItemAgente.value,
                            pc.selectedItemIdBL1.value,
                            pc.selectedItemIdBL2.value,
                            pc.selectedItemIdFT.value,
                            pc.selectedItemConto.value);
                        ws.updateParameters(
                            pc.selectedItemConto.value,
                            pc.selectedItemIdOC.value,
                            pc.selectedItemIdFT.value,
                            pc.selectedItemIdBL1.value,
                            pc.selectedItemIdBL2.value,
                            pc.selectedItemAgente.value);
                        Get.snackbar('Esito', 'Salvataggio Riuscito',
                            colorText: Colors.white,
                            backgroundColor: Colors.green,
                            snackPosition: SnackPosition.TOP);
                      } catch (e) {
                        debugPrint('errore: $e');
                      }
                    },
                    child: const Text('salva'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
