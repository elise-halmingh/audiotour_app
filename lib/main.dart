import 'package:flutter/material.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/photo_play_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  runApp(PhotoTourApp());
}

class PhotoTourApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/profile': (context) => ProfileSetupScreen(),
        '/home': (context) => HomeScreen(),
        '/qrScanner': (context) => const QRScannerScreen(nextQRCode: 1),
        '/photoPlay': (context) => const PhotoPlayScreen(currentQR: 1),
        '/map': (context) => MapScreen(),
        '/profileEdit': (context) => ProfileEditScreen(),
      },
    );
  }
}
