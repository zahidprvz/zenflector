import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Based on provided Blue and Purple)
  static const Color primary = Color(0xFF529BEA); // Blue
  static const Color secondary = Color(0xFF616FE9); // Purple
  static const Color tertiary = Color(0xFF7D5260); // Keeping this as is.
  //You can keep it or can also remove it.

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F); // Nearly black
  static const Color textSecondary =
      Color(0xFF49454F); // Slightly lighter, for body text
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Background Colors
  static const Color background = Color(0xFFF7F7FA); // Blue Sky
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color error = Color(0xFFB3261E); // Standard error

  // Button Colors
  static const Color buttonPrimary = Color(0xFF529BEA); // Blue
  static const Color buttonText = Color(0xFFFFFFFF);

  // Input Field Colors
  static const Color inputBackground = Color(0xFFFFFFFF); // White
  static const Color inputBorder = Color(0xFF79747E); // Grey
  static const Color inputBorderFocused = Color(0xFF529BEA); // Blue
  static const Color inputHint = Color(0xFF79747E);

  // App Bar Colors
  static const Color appBarBackground = Color(0xFFFFFFFF); // White
  static const Color appBarText = Color(0xFF1C1B1F); // Nearly black
  static const Color appBarIcon =
      Color(0xFF49454F); // Slightly lighter than textPrimary

  // Bottom Navigation Bar Colors
  static const Color bottomNavBarBackground = Color(0xFFFFFFFF);
  static const Color bottomNavBarSelected = Color(0xFF529BEA); // Blue
  static const Color bottomNavBarUnselected = Color(0xFF79747E);

  // Card Color
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Highlight color
  static const Color highlightColor = Color(0xFFD0BCFF);

//------- Now for the dark mode --------//

  static const Color primaryDark =
      Color(0xFFB1CFF5); // Light Blue (Lighter shade of Blue)
  static const Color secondaryDark =
      Color(0xFFC4C6F4); // Light Purple (Lighter shade of Purple)
  static const Color textPrimaryDark =
      Color(0xFFE5E1E6); // Light Grey (for text on dark backgrounds)
  static const Color textSecondaryDark =
      Color(0xFFC9C5CA); // Slightly darker grey
  static const Color textOnPrimaryDark =
      Color(0xFF003354); // Dark Blue (for text on primary color)

  static const Color backgroundDark =
      Color(0xFF1C1B1F); // Very Dark Grey (Almost Black)
  static const Color surfaceDark =
      Color(0xFF1C1B1F); // Same as background for cards/surfaces
  static const Color errorDark = Color(0xFFF2B8B5); // Lighter Red

  static const Color buttonPrimaryDark =
      Color(0xFFB1CFF5); // Light Blue (for buttons)
  static const Color buttonTextDark =
      Color(0xFF003354); // Dark Blue (for text on buttons)

  static const Color inputBackgroundDark =
      Color(0xFF49454F); // Dark Grey (for input fields)
  static const Color inputBorderDark =
      Color(0xFF938F99); // Lighter Grey (for input borders)
  static const Color inputBorderFocusedDark =
      Color(0xFFB1CFF5); // Light Blue (for focused input borders)
  static const Color inputHintDark =
      Color(0xFF938F99); // Lighter Grey (for input hints)

  static const Color appBarBackgroundDark =
      Color(0xFF49454F); // Dark Grey (for app bar)
  static const Color appBarTextDark =
      Color(0xFFE5E1E6); // Light Grey (for app bar text)
  static const Color appBarIconDark =
      Color(0xFFCAC4D0); // Light Grey (for app bar icons)

  static const Color bottomNavBarBackgroundDark =
      Color(0xFF1C1B1F); // Very Dark Grey
  static const Color bottomNavBarSelectedDark = Color(0xFFB1CFF5); // Light Blue
  static const Color bottomNavBarUnselectedDark =
      Color(0xFF938F99); // Lighter Grey

  static const Color cardBackgroundDark =
      Color(0xFF49454F); // Dark Grey (for cards)
  static const Color highlightColorDark =
      Color(0xFF381E72); // Dark Purple (for highlights)
}

class AppConstants {
  static const String appName = 'Zenflector';
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
}
