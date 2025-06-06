import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_style.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    scaffoldBackgroundColor: AppColors.bgPrimary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgSecondary,
      elevation: 0,
      titleTextStyle: AppStyles.headline6.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyles.headline1,
      headlineMedium: AppStyles.headline2,
      headlineSmall: AppStyles.headline3,
      titleLarge: AppStyles.headline4,
      titleMedium: AppStyles.headline5,
      titleSmall: AppStyles.headline6,
      bodyLarge: AppStyles.bodyText1,
      bodyMedium: AppStyles.bodyText2,
      labelLarge: AppStyles.button,
      bodySmall: AppStyles.caption,
      labelSmall: AppStyles.overline,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSecondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.bgTertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
    ),
    scaffoldBackgroundColor: AppColors.bgPrimaryDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgSecondaryDark,
      elevation: 0,
      titleTextStyle: AppStyles.headline6.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyles.headline1.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppStyles.headline2.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: AppStyles.headline3.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: AppStyles.headline4.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: AppStyles.headline5.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: AppStyles.headline6.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: AppStyles.bodyText1.copyWith(color: AppColors.textPrimaryDark),
      bodyMedium: AppStyles.bodyText2.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelLarge: AppStyles.button.copyWith(color: AppColors.textPrimaryDark),
      bodySmall: AppStyles.caption.copyWith(color: AppColors.textSecondaryDark),
      labelSmall: AppStyles.overline.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.bgSecondaryDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSecondaryDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.bgTertiaryDark),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryDark),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
