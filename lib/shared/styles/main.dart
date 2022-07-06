import 'package:flutter/material.dart' hide Colors;

class SharedStyles {
  static InputDecoration textInputStyle(String hint, Widget suffixIcon) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide.none,
      ),
      hintText: hint,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      filled: true,
      fillColor: const Color(0xFFDFDFDF),
      suffixIcon: suffixIcon,
    );
  }

  static MaterialColor encryptoBlue = const MaterialColor(
    0xFF3262FB,
    <int, Color>{
      50: Color(0xFF3262FB),
      100: Color(0xFF3262FB),
      200: Color(0xFF3262FB),
      300: Color(0xFF3262FB),
      400: Color(0xFF3262FB),
      500: Color(0xFF3262FB),
      600: Color(0xFF3262FB),
      700: Color(0xFF3262FB),
      800: Color(0xFF3262FB),
      900: Color(0xFF3262FB),
    },
  );

  static MaterialColor fluentBlue = const MaterialColor(
    0xFF0063B1,
    <int, Color>{
      50: Color(0xFF0063B1),
      100: Color(0xFF0063B1),
      200: Color(0xFF0063B1),
      300: Color(0xFF0063B1),
      400: Color(0xFF0063B1),
      500: Color(0xFF0063B1),
      600: Color(0xFF0063B1),
      700: Color(0xFF0063B1),
      800: Color(0xFF0063B1),
      900: Color(0xFF0063B1),
    },
  );

  static double kTopBarHeight = 45.0;
  static double kLeftBarWidth = 60.0;
  static double kSideBarWidth = 310.0;
}
