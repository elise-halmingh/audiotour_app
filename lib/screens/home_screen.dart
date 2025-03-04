import 'package:flutter/material.dart';
import 'package:audiotour_apps/screens//profile_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String?>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;

    final String? ageGroup = arguments?['ageGroup'];
    final String? theme = arguments?['theme'];

    if (ageGroup == null || theme == null) {
      return Scaffold(
        backgroundColor: const Color(0xfff1f0ea),
        body: Center(
          child: ElevatedButton(
            // Als er niets is ingevuld toon foutmelding
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('Missing Age Group or Theme information.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Show Error'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xfff1f0ea),
              backgroundColor: const Color(0xff82A790),
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // Profile Edit openen
      backgroundColor: const Color(0xfff1f0ea),
      appBar: AppBar(
        backgroundColor: const Color(0xfff1f0ea),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welkom bij ExpoSound!',
                style: TextStyle(
                  color: Color(0xff5A7364),
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              const Text(
                'Scan een QR-Code om te beginnen!',
                style: TextStyle(
                  color: Color(0xff82A790),
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              //QR Scanner Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/qrScanner',
                    arguments: {'ageGroup': ageGroup, 'theme': theme},
                  );
                },
                child: const Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xfff1f0ea),
                  backgroundColor: const Color(0xff82A790),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 6,
                ),
              ),
              // Map bekijken Button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: {'ageGroup': ageGroup, 'theme': theme},
                  );
                },
                child: const Text('Map bekijken'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xfff1f0ea),
                  backgroundColor: const Color(0xff82A790),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
