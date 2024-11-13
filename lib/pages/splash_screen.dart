import 'package:get/get.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import '../controllers/clienti_controller.dart';
import '../controllers/controller_soket.dart';
import '../controllers/incassi_controller.dart';
import '../controllers/ordine_controller.dart';
import '../pages/home.dart';
import '../utils/app_colors.dart';
import '../utils/flavor_scripts.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final cc = Get.put(ClientiController(), permanent: true);
  final oc = Get.put(OrdineController(), permanent: true);
  final ic = Get.put(IncassiController(), permanent: true);
  final sc = Get.put(WebSocketController(), permanent: true);
  FlavorScripts flavorScripts = Get.find<FlavorScripts>();
  AppColors appColors = AppColors();
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      useImmersiveMode: false,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: appColors.getBackrouondSplashColor(flavorScripts.getFlavor()),
      ),
      onInit: () async {},
      childWidget: SizedBox(
        height: 300,
        width: 300,
        child: Image.asset(flavorScripts.getAssetImagePath('applogo.png')),
      ),
      onAnimationEnd: () => Get.to(() => const HomePage()),
      asyncNavigationCallback: () async {
        await cc.caricaClienti().then((anagrafica) {
          //debugPrint(anagrafica);
          for (var cliente in anagrafica) {
            cc.anagrafica.clienti.add(cliente);
            cc.anagraficaOriginale.clienti.add(cliente);
          }
        });

        /* await oc.caricaProdotti().then((value) {
          for (var prodotto in value) {
            oc.prodotti.add(prodotto);
            oc.prodottiOri.add(prodotto);

            oc.classi.add(prodotto.classe);
            oc.classi.insert(0, 'TUTTI');
            oc.classi = oc.classi.toSet().toList();
          }
          //debugdebugPrint(oc.prodotti.toString());
        }); */
      },
    );
  }
}
