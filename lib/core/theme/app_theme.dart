import 'package:flutter/material.dart';

class MarketTheme {
  MarketTheme._();
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: const Color.fromARGB(
        255,
        0,
        0,
        0,
      ), // Your desired color
    ),
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 255, 255, 255), //BG
      onPrimary: const Color.fromARGB(255, 150, 150, 150), //Border
      onSecondaryContainer: const Color.fromARGB(
        255,
        225,
        225,
        225,
      ), //TextField BG / Card BG
      onPrimaryContainer: const Color.fromARGB(255, 0, 0, 255), //Button 1
      onSecondary: const Color.fromARGB(255, 0, 255, 0), //Button 2
      onSurface: const Color.fromARGB(255, 255, 0, 0), //Button 3
      onSurfaceVariant: const Color.fromARGB(255, 255, 200, 0), //Rating Bar
      onInverseSurface: const Color.fromARGB(255, 0, 0, 0), //
      onTertiary: const Color.fromARGB(255, 225, 225, 225),
    ),
    splashColor: const Color.fromARGB(0, 0, 0, 0),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(const Color.fromARGB(255, 0, 0, 0)),
      trackColor: WidgetStateProperty.all(const Color.fromARGB(255, 0, 0, 0)),
    ),
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Your desired color
    ),
    colorScheme: ColorScheme.dark(
      primary: const Color.fromARGB(255, 0, 0, 0), //BG
      onPrimary: const Color.fromARGB(255, 150, 150, 150), //Border
      onSecondaryContainer: const Color.fromARGB(
        255,
        66,
        66,
        66,
      ), //TextField BG / Card BG
      onPrimaryContainer: const Color.fromARGB(255, 0, 0, 255), //Button 1
      onSecondary: const Color.fromARGB(255, 0, 255, 0), //Button2
      onSurface: const Color.fromARGB(255, 255, 0, 0), //Button 3
      onSurfaceVariant: const Color.fromARGB(255, 255, 200, 0), //Rating Bar
      onInverseSurface: const Color.fromARGB(255, 255, 255, 255), //
      onTertiary: const Color.fromARGB(255, 225, 225, 225),
    ),
    splashColor: const Color.fromARGB(0, 0, 0, 0),

    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        const Color.fromARGB(255, 255, 255, 255),
      ),
      trackColor: WidgetStateProperty.all(
        const Color.fromARGB(255, 255, 255, 255),
      ),
    ),
    useMaterial3: true,
  );
}
