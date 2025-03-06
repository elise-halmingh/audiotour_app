import 'dart:async';
import '/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // Stel een timer in van 3 seconden voor de splash scherm animatie
    Timer(const Duration(seconds: 3), () {
      // Na de 3 seconden veranderd de tekst naar onzichtbaar
      setState(() {
        _visible = false;
      });
      // Na 500ms doorgestuurd naar het Profiel setup scherm
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
        );
      });
    });
  }

  // User interface styling en bouwen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f0ea),
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Text(
            'ExpoSound',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: const Color(0xff82A790),
            ),
          ),
        ),
      ),
    );
  }
}
