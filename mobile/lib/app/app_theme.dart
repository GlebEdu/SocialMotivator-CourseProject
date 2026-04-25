import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class HabitBetTheme {
  static const Color _base = Color(0xFF173642);
  static const Color _surface = Color(0xFFF1F4F2);
  static const Color _primary = Color(0xFF264653);
  static const Color _accent = Color(0xFF9A6A00);
  static const Color _danger = Color(0xFFC96B5C);
  static const Color _success = Color(0xFF2A9D8F);
  static const Color _inkSoft = Color(0xFF6A7C81);
  static const Color _canvas = Color(0xFFFCFBF7);
  static const Color _surfaceAlt = Color(0xFFE7ECE8);
  static const Color _line = Color(0xFFD7DFDB);

  static ThemeData lightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _accent,
      onSecondary: _base,
      error: _danger,
      onError: Colors.white,
      surface: _surface,
      onSurface: _base,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _canvas,
      canvasColor: _canvas,
      splashFactory: InkSparkle.splashFactory,
    );

    final uiTextTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: _base, displayColor: _base);
    final titleTextTheme = GoogleFonts.spaceGroteskTextTheme(uiTextTheme);

    return base.copyWith(
      textTheme: uiTextTheme.copyWith(
        displayLarge: titleTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        displayMedium: titleTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineLarge: titleTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineSmall: titleTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.9,
        ),
        titleLarge: titleTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleMedium: titleTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyLarge: uiTextTheme.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: uiTextTheme.bodyMedium?.copyWith(height: 1.4),
        labelLarge: uiTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelMedium: uiTextTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        foregroundColor: Colors.white,
        titleTextStyle: titleTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: _surface.withValues(alpha: 0.98),
        shadowColor: _base.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: _line, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _line, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF6E7BA),
        selectedColor: _accent,
        disabledColor: _surfaceAlt,
        secondarySelectedColor: _primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: uiTextTheme.labelMedium?.copyWith(
          color: _base,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: uiTextTheme.labelMedium?.copyWith(
          color: _base,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: _line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            uiTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          side: const WidgetStatePropertyAll(BorderSide.none),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _base;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return _inkSoft;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _success.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: titleTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _base,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          side: const BorderSide(color: _line, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: titleTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: uiTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        hintStyle: uiTextTheme.bodyMedium?.copyWith(
          color: _inkSoft.withValues(alpha: 0.65),
        ),
        labelStyle: uiTextTheme.bodyMedium?.copyWith(
          color: _inkSoft,
          fontWeight: FontWeight.w600,
        ),
        prefixStyle: titleTextTheme.bodyLarge?.copyWith(
          color: _base,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface.withValues(alpha: 0.98),
        surfaceTintColor: Colors.transparent,
        indicatorColor: _success.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return uiTextTheme.labelSmall?.copyWith(
            color: isSelected ? _success : _inkSoft,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? _success : _inkSoft,
            size: 22,
          );
        }),
        height: 78,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _success,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _base,
        contentTextStyle: uiTextTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primary),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        headerBackgroundColor: _base,
        headerForegroundColor: Colors.white,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.22);
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _base;
          }
          return _base;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.18);
          }
          return null;
        }),
        todayForegroundColor: const WidgetStatePropertyAll(_base),
        yearForegroundColor: const WidgetStatePropertyAll(_base),
        dividerColor: _line,
      ),
    );
  }

  static BoxDecoration scaffoldDecoration() {
    return const BoxDecoration(color: _canvas);
  }

  static List<BoxShadow> softShadow() {
    return const <BoxShadow>[
      BoxShadow(
        color: Color(0x0F1D2236),
        blurRadius: 28,
        offset: Offset(0, 14),
      ),
    ];
  }

  static LinearGradient panelGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Color(0xFF264653), Color(0xFF173642)],
    );
  }

  static LinearGradient accentGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[_success, Color(0xFF53B8AC)],
    );
  }

  static Color get ink => _base;
  static Color get inkSoft => _inkSoft;
  static Color get canvas => _canvas;
  static Color get surface => _surface;
  static Color get primary => _primary;
  static Color get accent => _accent;
  static Color get success => _success;
  static Color get danger => _danger;
  static Color get surfaceAlt => _surfaceAlt;
  static Color get line => _line;
}
