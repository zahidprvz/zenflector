import 'package:flutter/material.dart';
import 'package:zenflector/utils/constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch:
        createMaterialColor(AppColors.primary), // Use custom function
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBackground,
      titleTextStyle: TextStyle(
        color: AppColors.appBarText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.appBarIcon),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      titleLarge: TextStyle(
          // Add titleLarge and titleMedium
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: AppColors.buttonPrimary,
    )),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorderFocused),
      ),
      hintStyle: const TextStyle(color: AppColors.inputHint),
      fillColor: AppColors.inputBackground,
      filled: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBarBackground,
      selectedItemColor: AppColors.bottomNavBarSelected,
      unselectedItemColor: AppColors.bottomNavBarUnselected,
      type: BottomNavigationBarType.fixed, // Important for more than 3 items
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // Add more theme properties as needed
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: createMaterialColor(AppColors.primaryDark),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBackgroundDark,
      titleTextStyle: TextStyle(
        color: AppColors.appBarTextDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.appBarIconDark),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondaryDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondaryDark,
      ),
      headlineSmall: TextStyle(
          // Added headlineSmall for headings
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark),
      titleLarge: TextStyle(
        // Add titleLarge and titleMedium
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimaryDark,
        foregroundColor: AppColors.buttonTextDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.buttonPrimaryDark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorderFocusedDark),
      ),
      hintStyle: const TextStyle(color: AppColors.inputHintDark),
      fillColor: AppColors.inputBackgroundDark,
      filled: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBarBackgroundDark,
      selectedItemColor: AppColors.bottomNavBarSelectedDark,
      unselectedItemColor: AppColors.bottomNavBarUnselectedDark,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBackgroundDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Function to create a MaterialColor from a single color (no changes needed)
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
