import 'package:flutter/material.dart';


class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Reference Colors
  static const Color limeAccent = Color(0xFFC7F25E); // The vibrant lime green
  static const Color darkGreen = Color(0xFF132C19); // The dark button/text color
  static const Color greyText = Color(0xFF8E8E93);
  static const Color cardWhite = Colors.white;
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color backgroundDark = Color(0xFF000000);
  
  // Semantic Aliases
  static const Color primary = darkGreen; 
  static const Color accent = limeAccent;
  static const Color destructive = Color(0xFFFF3B30);
  
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1C1C1E);

  // Gradients (Green-ish for charts/accents)
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [limeAccent, Color(0xFFADE33A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // Typography
  static TextTheme textTheme(bool isDark) {
    Color mainColor = isDark ? Colors.white : darkGreen;
    Color subColor = isDark ? Colors.white60 : greyText;

    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 42, fontWeight: FontWeight.w600, color: mainColor, letterSpacing: -1.0), // Balance
      displayMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 32, fontWeight: FontWeight.bold, color: mainColor),
      displaySmall: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 24, fontWeight: FontWeight.w600, color: mainColor), // Headings
      headlineMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 18, fontWeight: FontWeight.w600, color: mainColor), // Section Titles
      bodyLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 16, fontWeight: FontWeight.w500, color: mainColor),
      bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 14, fontWeight: FontWeight.w500, color: mainColor),
      titleMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 16, fontWeight: FontWeight.w600, color: mainColor),
      bodySmall: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 13, fontWeight: FontWeight.w500, color: subColor),
      labelSmall: TextStyle(fontFamily: 'Plus Jakarta Sans',fontSize: 11, fontWeight: FontWeight.w600, color: subColor),
    );
  }

  // Convenience Aliases for UI Code
  static const Color darkBackground = Color(0xFF000000);
  static const Color lightBackground = Color(0xFFF7F7F7);

  static const TextStyle heading2 = TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 24, fontWeight: FontWeight.w600);
  static const TextStyle heading3 = TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle bodyText1 = const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle bodyText2 = const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle caption = const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w500);
  static TextStyle bodySmall = const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w500);
  static TextStyle labelSmall = const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w600);

  // ThemeData Builders
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      textTheme: textTheme(false),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: darkGreen),
      ),
      iconTheme: const IconThemeData(color: darkGreen),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surfaceLight,
        background: backgroundLight,
        error: destructive,
      ),
      useMaterial3: true,
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary, // Still use darkGreen as primary brand color
      scaffoldBackgroundColor: const Color(0xFF000000), // Pitch black or very dark grey
      cardColor: surfaceDark,
      textTheme: textTheme(true), // Pass true for dark mode text
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: limeAccent),
      colorScheme: const ColorScheme.dark(
        primary: accent, // Use Lime Accent as primary in Dark Mode for visibility
        secondary: accent,
        surface: surfaceDark,
        background: Color(0xFF000000),
        error: destructive,
      ),
      useMaterial3: true,
    );
  }
}

// Spacing Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  
  static const double cardRadius = 24.0; // More rounded as per image
  static const double buttonRadius = 30.0; // Pill shape
}
