import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/documenti_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../utils/flavor_scripts.dart';
import '../utils/template_pdf.dart';

class Documenti extends StatelessWidget {
  const Documenti({super.key});

  @override
  Widget build(BuildContext context) {
    final DocumentiController _documentiCt = Get.put(DocumentiController());
    final ClientiController _clientiCt = Get.find<ClientiController>();
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: DropdownMenu<String>(
                      enableFilter: true,
                      enableSearch: true,
                      width: 250,
                      label: const Text('Tipo documento'),
                      onSelected: (String? value) {
                        // This is called when the user selects an item.
                        _documentiCt.cambiaTipo(value);
                      },
                      dropdownMenuEntries: _documentiCt.tipi
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                    ),
                  ),
                ),
                const Gap(8),
                Container(
                    height: 62,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 10.0),
                      child: TextField(
                        onChanged: (newvalue) {
                          _documentiCt.numeroDoc.text = newvalue;
                        },
                        focusNode: _documentiCt.numeroDocNode,
                        textAlign: TextAlign.left,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide
                                .none, // Rimuove solo il bordo sottostante mantenendo il bordo arrotondato
                            borderRadius: BorderRadius.circular(
                                5), // Personalizza il raggio del bordo arrotondato se necessario
                          ),
                        ),
                        controller: _documentiCt.numeroDoc,
                        autocorrect: false,
                        onTapOutside: (pointerDownEvent) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    )),
                Gap(8),
                InkWell(
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            _documentiCt.picked.value ?? DateTime.now(),
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                        fieldHintText: 'Data1',
                        fieldLabelText: 'Data2');
                    if (selectedDate != null) {
                      // Controlla se è stata selezionata una data
                      _documentiCt.picked.value = selectedDate;
                    }
                  },
                  child: Container(
                    height: 62,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Obx(() => Center(
                            child: Text(
                          _documentiCt.picked.value == null
                              ? 'Data'
                              : DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                  _documentiCt.picked.value.toString())),
                          style: const TextStyle(fontSize: 16),
                        ))),
                  ),
                ),
                Gap(10),
                ElevatedButton(
                    onPressed: () {
                      if (_clientiCt.clienteSelezionato.value.mbpcId == 0) {
                        Get.defaultDialog(
                            title: 'Attenzione',
                            content: const Text(
                              'Selezionare un cliente',
                              style: TextStyle(fontSize: 20),
                            ),
                            confirm: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('ok')));
                      } else {
                        _documentiCt.getDocumenti(
                            _clientiCt.clienteSelezionato.value.mbpcId);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(
                          top: 20, bottom: 20, left: 10, right: 10),
                      child: Text('Cerca'),
                    ))
              ],
            ),
            Row(
              children: [
                /* ElevatedButton(
                    onPressed: () {},
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 20, bottom: 20, left: 10, right: 10),
                      child: Text('Apri'),
                    )),
                Gap(20), */
                Obx(
                  () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _documentiCt.idDocSel.value == -1
                              ? Colors.grey
                              : null),
                      onPressed: () async {
                        if (_documentiCt.idDocSel.value == -1) {
                          Get.defaultDialog(
                              title: 'Attenzione',
                              content: const Text(
                                'Selezionare un documento!',
                                style: TextStyle(fontSize: 20),
                              ),
                              confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text('ok')));
                        } else {
                          final pdf = pw.Document();
                          String prefDoc = _documentiCt
                              .documenti[_documentiCt.idDocSel.value].prefisso;
                          switch (prefDoc) {
                            case 'FTAN':
                              debugPrint('Genero fattura');
                              await generaFattura(
                                  pdf,
                                  _clientiCt.clienteSelezionato.value,
                                  _documentiCt
                                      .documenti[_documentiCt.idDocSel.value],
                                  flavorScripts);
                              break;
                            case 'OCAN':
                              debugPrint('Genero ordine');
                              await generaOrdine(
                                  pdf,
                                  _clientiCt.clienteSelezionato.value,
                                  _documentiCt
                                      .documenti[_documentiCt.idDocSel.value],
                                  flavorScripts);
                              break;
                            case 'BLAN':
                              debugPrint('Genero bolla');
                              await generaBolla(
                                  pdf,
                                  _clientiCt.clienteSelezionato.value,
                                  _documentiCt
                                      .documenti[_documentiCt.idDocSel.value],
                                  flavorScripts);
                              break;
                            default:
                              break;
                          }

                          final output = await getTemporaryDirectory();
                          final file = File(
                              "${output.path}/doc_${_documentiCt.documenti[_documentiCt.idDocSel.value].numero}.pdf");
                          await file.writeAsBytes(await pdf.save());
                          await OpenFile.open(file.path);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        child: Text('Genera PDF'),
                      )),
                ),
                Gap(10)
              ],
            )
          ],
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: GetBuilder<DocumentiController>(
                  builder: (_documentiCt) => (DataTable(
                    onSelectAll: (val) {
                      _documentiCt.idDocSel.value = -1;
                      _documentiCt.update();
                    },
                    columns: _documentiCt.header,
                    rows: List.generate(
                        _documentiCt.documenti.length,
                        (index) => DataRow(
                              selected: _documentiCt.idDocSel.value == index,
                              onSelectChanged: (isSelected) {
                                if (isSelected == true) {
                                  _documentiCt.idDocSel.value =
                                      index; // Seleziona il nuovo documento
                                } else if (_documentiCt.idDocSel.value ==
                                    index) {
                                  _documentiCt.idDocSel.value =
                                      -1; // Deseleziona se è lo stesso documento
                                }
                                debugPrint(
                                    _documentiCt.documenti[index].cliente);
                                _documentiCt.update();
                              },
                              cells: <DataCell>[
                                DataCell(
                                    Text(_documentiCt.documenti[index].tipo)),
                                DataCell(
                                    Text(_documentiCt.documenti[index].numero)),
                                DataCell(Text(DateFormat('dd/MM/yyyy')
                                    .format(_documentiCt.documenti[index].data)
                                    .toString())),
                                DataCell(Text(
                                    _documentiCt.documenti[index].cliente)),
                                DataCell(
                                    Text(_documentiCt.documenti[index].stato)),
                              ],
                            )),
                  )),
                )),
          ),
        ))
      ],
    );
  }
}
