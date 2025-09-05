import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/fatturatoMensilizzato.dart';
import '../controllers/fatt_mensi_controller.dart';
import '../utils/app_colors.dart';

class FatturatoChart extends StatelessWidget {
  final int annoIniziale;
  FatturatoChart({required this.annoIniziale});

  @override
  Widget build(BuildContext context) {
    // Otteniamo il controller
    final controller = Get.put(FatturatoController());

    return Obx(() {
      // Assicurati che ci siano dati da visualizzare
      if (controller.anno1.isEmpty &&
          controller.anno2.isEmpty &&
          controller.anno3.isEmpty) {
        return Center(child: Text("Nessun dato disponibile"));
      }

      return AspectRatio(
        aspectRatio: 1.23,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Venduto Cliente',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 6),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: controller.maxVal + (controller.maxVal * 0.05),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          // Configurazione per l'asse X
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  30, // Spazio riservato per i titoli in basso
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const texts = [
                                  'Gen',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'Mag',
                                  'Giu',
                                  'Lug',
                                  'Ago',
                                  'Set',
                                  'Ott',
                                  'Nov',
                                  'Dic'
                                ];
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 6.0, // Spazio tra i titoli e gli assi
                                  child:
                                      Text(texts[value.toInt() % texts.length]),
                                );
                              },
                              interval: 1, // Intervallo tra i titoli
                            ),
                          ),
                          // Configurazione per l'asse Y
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (/*controller.yValues.contains(value)*/ controller
                                    .yValues
                                    .any((yValue) => isClose(yValue, value))) {
                                  debugPrint(value.toStringAsFixed(2));
                                  return Text(
                                      '${value.toStringAsFixed(1)}'); // Mostra il valore con una cifra decimale
                                }
                                return Text(
                                    ''); // Non mostrare titoli per valori non specificati
                              },
                              interval: 1,
                              // getTitlesWidget: (double value, TitleMeta meta) {
                              //   return Text('${value.toInt()} k');
                              // },
                              // interval:
                              //     1000, // Definisci un intervallo appropriato per i tuoi dati
                              reservedSize:
                                  60, // Spazio riservato per i titoli a sinistra
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                                color: const Color(0xff37434d), width: 1)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.anno1.isEmpty
                                ? [0, 0, 0, 0, 0, 0, 0]
                                    .map((e) => const FlSpot(0.0, 0.0))
                                    .toList()
                                : controller.anno1
                                    .map((e) => FlSpot(
                                        controller.anno1.indexOf(e).toDouble(),
                                        e.fatturato))
                                    .toList(),
                            isCurved: true,
                            color: Colors.yellowAccent,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: controller.anno2.isEmpty
                                ? [0, 0, 0, 0, 0, 0, 0]
                                    .map((e) => const FlSpot(0.0, 0.0))
                                    .toList()
                                : controller.anno2
                                    .map((e) => FlSpot(
                                        controller.anno2.indexOf(e).toDouble(),
                                        e.fatturato))
                                    .toList(),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                          LineChartBarData(
                            spots: controller.anno3.isEmpty
                                ? [0, 0, 0, 0, 0, 0, 0]
                                    .map((e) => const FlSpot(0.0, 0.0))
                                    .toList()
                                : controller.anno3
                                    .map((e) => FlSpot(
                                        controller.anno3.indexOf(e).toDouble(),
                                        e.fatturato))
                                    .toList(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 15,
                        height: 15,
                        color: Colors.yellowAccent,
                      ),
                    ),
                    Text(controller.anno_1.value.toString()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 15,
                        height: 15,
                        color: Colors.redAccent,
                      ),
                    ),
                    Text(controller.anno_2.value.toString()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 15,
                        height: 15,
                        color: AppColors.contentColorOrange,
                      ),
                    ),
                    Text(controller.anno_3.value.toString()),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}

bool isClose(double a, double b, [double tolerance = 0.5]) =>
    (a - b).abs() <= tolerance;

Color getAnnoColor(int anno) {
  switch (anno % 3) {
    case 0:
      return Colors.blue;
    case 1:
      return Colors.green;
    case 2:
      return Colors.red;
    default:
      return Colors.black;
  }
}
