import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serfix/app/themes/app_colors.dart';

final ColorScheme serfixDarkColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,
);

final ThemeData serfixDarkTheme = ThemeData.dark().copyWith(
  colorScheme: serfixDarkColorScheme,
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  appBarTheme: AppBarTheme(
    toolbarHeight: 65,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: AppColors.primaryDark,
    iconTheme: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? const IconThemeData(color: AppColors.white)
          : const IconThemeData(color: AppColors.textSecondaryDark),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? const TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            )
          : const TextStyle(color: AppColors.textSecondaryDark),
    ),
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  cardTheme: const CardThemeData(
    color: AppColors.surfaceDark,
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
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDarkElevated,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightGrayDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  dividerColor: AppColors.lightGrayDark,
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
  ),
);
