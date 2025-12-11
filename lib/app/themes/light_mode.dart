import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serfix/app/themes/app_colors.dart';

final ColorScheme serfixLightColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.light,
);

final ThemeData serfixLightTheme = ThemeData().copyWith(
  colorScheme: serfixLightColorScheme,
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: AppBarTheme(
    toolbarHeight: 65,
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryLight,
    iconTheme: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.white)
          : const IconThemeData(color: AppColors.textSecondary),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            )
          : const TextStyle(color: AppColors.textSecondary),
    ),
  ),
  scaffoldBackgroundColor: AppColors.background,
  cardTheme: const CardThemeData(
    color: AppColors.surface,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
