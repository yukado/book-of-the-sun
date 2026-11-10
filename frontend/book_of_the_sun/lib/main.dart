import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'services/auth_service.dart';
import 'services/slot_service.dart';
import 'services/user_service.dart'; // 1. IMPORT HINZUGEFÜGT

import 'screens/login_screen.dart';
import 'screens/slot_screen.dart';

void main() {
  final api = ApiClient(
    baseUrl: 'http://localhost:8080',
  );

  final authService = AuthService(api);
  final slotService = SlotService(api);
  final userService = UserService(api); // 2. INITIALISIERUNG HINZUGEFÜGT

  runApp(
    MyApp(
      authService: authService,
      slotService: slotService,
      userService: userService, // 3. AN MYAPP ÜBERGEBEN
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final SlotService slotService;
  final UserService userService; // 4. IM WIDGET REGISTRIERT

  const MyApp({
    super.key,
    required this.authService,
    required this.slotService,
    required this.userService, // 5. IM KONSTRUKTOR ERZWUNGEN
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Book of the Sun',

      theme: ThemeData(
        useMaterial3: true,

        brightness: Brightness.dark,

        scaffoldBackgroundColor: const Color(0xFF0C0C0C),

        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.orange,
          surface: Color(0xFF1A1A1A),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.amber,
          centerTitle: true,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.amber,
            side: const BorderSide(
              color: Colors.amber,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),

      routes: {
        '/': (_) => LoginScreen(
          authService: authService,
        ),
        '/slot': (_) => SlotScreen(
          slotService: slotService,
          userService: userService, // 6. JETZT REIBUNGSLOS VERFÜGBAR!
        ),
      },
    );
  }
}
