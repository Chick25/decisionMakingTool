// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkMode = false;
//   bool get isDarkMode => _isDarkMode;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     _isDarkMode = !_isDarkMode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', _isDarkMode);
//     notifyListeners();
//   }

//   ThemeData get lightTheme => ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.light,
//         fontFamily: 'Poppins',
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         scaffoldBackgroundColor: const Color(0xFFF8F9FA),
//         dividerColor: const Color(0xFFE2E8F0),
//         colorScheme: ColorScheme.light(
//           primary: const Color(0xFF4F46E5),
//           primaryContainer: const Color(0xFFEEF2FF),
//           surface: Colors.white,
//           onSurface: const Color(0xFF0F172A),
//           onSurfaceVariant: const Color(0xFF64748B),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black87,
//           elevation: 1,
//         ),
//         cardColor: Colors.white,
//       );

//   ThemeData get darkTheme => ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         fontFamily: 'Poppins',
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         scaffoldBackgroundColor: const Color(0xFF121212),
//         dividerColor: const Color(0xFF334155),
//         colorScheme: ColorScheme.dark(
//           primary: const Color(0xFF6366F1),
//           primaryContainer: const Color(0xFF4338CA),
//           surface: const Color(0xFF1E2937),
//           onSurface: Colors.white,
//           onSurfaceVariant: const Color(0xFF94A3B8),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: const Color(0xFF1F1F1F),
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         cardColor: const Color(0xFF1F1F1F),
//         listTileTheme: const ListTileThemeData(
//           textColor: Colors.white,
//           iconColor: Colors.white70,
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: WidgetStateProperty.resolveWith((states) => 
//               states.contains(WidgetState.selected) ? Colors.blue : null),
//         ),
//       );
// // 

// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() { _loadTheme(); }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE2E8F0),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF4F46E5),
          primaryContainer: const Color(0xFFEEF2FF),
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
          onSurfaceVariant: const Color(0xFF64748B),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E2937),
        dividerColor: const Color(0xFF334155),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6366F1),
          primaryContainer: const Color(0xFF4338CA),
          surface: const Color(0xFF1E2937),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFF94A3B8),
        ),
      );
}