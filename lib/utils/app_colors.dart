import 'package:flutter/material.dart';

import 'flavor_scripts.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color.fromARGB(255, 255, 157, 59);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
  static const Color contentColorBlue2 = Color.fromARGB(255, 40, 79, 255);

  List<Color> getBackrouondSplashColor(String flavor) {
    switch (flavor) {
      case 'standard':
        return [
          const Color.fromARGB(255, 255, 211, 161),
          const Color.fromARGB(255, 255, 166, 0),
          const Color.fromARGB(255, 255, 220, 145)
        ];
      case 'gelomare':
        return [
          const Color.fromARGB(255, 197, 239, 251),
          const Color(0xFF8AD9F2),
          const Color.fromARGB(255, 200, 242, 255)
        ];
      case 'mcfood':
        return [
          const Color.fromARGB(255, 255, 211, 161),
          const Color.fromARGB(255, 255, 143, 143),
          const Color.fromARGB(255, 254, 255, 255)
        ];
      default:
        return [];
    }
  }
}
