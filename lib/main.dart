import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
//import 'package:yesplus/base_app/routes/app_pages.dart';
//import '../routes/app_pages.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:logger/web.dart';
import 'routes/app_pages.dart';
import 'utils/color_schemes.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'utils/flavor_scripts.dart';

void main() async {
  var logger = Logger();
  // Dichiaro la variabile di classe FlavorScripts per accedere allo script di settaggio dei flavors
  FlavorScripts flavorScripts = FlavorScripts();
  WidgetsFlutterBinding.ensureInitialized();
  // Ottengo le info del pacchetto
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // Ottengo il nome del pacchetto
  String packageName = packageInfo.packageName;

  // Setto il flavor in base al nome del pacchetto e carico il file di configurazione per il flavor
  await flavorScripts.setFlavor(packageName);
  await flavorScripts.loadConfig();
  logger.d(flavorScripts.getMaxItems());
  // aggiungo l'istanza di FlavorScripts a Get.put per permettere la persistenza delle impostazioni
  Get.put(flavorScripts);

  logger.i('Package Name: $packageName');
  logger.d('LOOOG');
  debugPrint('LOOG2');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlavorScripts flavorScripts = Get.find<FlavorScripts>();
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        // Otherwise, use fallback schemes.
        lightScheme = lightColorScheme;
        darkScheme = darkColorScheme;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          title: 'Flutter Demo',
          themeMode: ThemeMode.light,
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightScheme,
              scaffoldBackgroundColor:
                  flavorScripts.getScaffoldBackgroundColor()),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
          ),
        );
      },
    );
  }
}
