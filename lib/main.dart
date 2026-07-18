import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool useFirebase = false;
  try {
    // Attempt Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    useFirebase = true;
  } catch (e) {
    // Graceful fallback to mock mode
    debugPrint("Firebase could not be initialized. Running in MOCK/OFFLINE mode: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const ColitasPetshopApp(),
    ),
  );
}

class ColitasPetshopApp extends StatelessWidget {
  const ColitasPetshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición del tema de color
    const Color brandPurple = Color(0xFF7C5CBF);
    const Color brandOrange = Color(0xFFE8935A);
    const Color brandCream = Color(0xFFFBF7F1);
    const Color textDark = Color(0xFF382B4A);

    return MaterialApp(
      title: 'Colitas Petshop – Mascotas Perdidas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPurple,
          primary: brandPurple,
          secondary: brandOrange,
          background: brandCream,
          surface: Colors.white,
          onBackground: textDark,
          onSurface: textDark,
        ),
        scaffoldBackgroundColor: brandCream,
        
        // Configuración de Tipografías
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          // Encabezados con Baloo 2
          headlineLarge: GoogleFonts.baloo2(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.baloo2(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.baloo2(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Estilo de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        
        // Estilo de inputs (Form Fields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: brandPurple, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: brandPurple),
          hintStyle: TextStyle(color: textDark.withOpacity(0.4)),
        ),
        
        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: brandPurple,
          disabledColor: Colors.grey,
          labelStyle: const TextStyle(color: textDark),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}
