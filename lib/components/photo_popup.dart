import 'package:flutter/material.dart';

class PhotoPopup extends StatelessWidget {
  final Map<String, dynamic> photo;

  PhotoPopup({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(photo['imagePath']),
            const SizedBox(height: 16),
            Text(
              photo['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fotograaf: ${photo['photographer']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Beschrijving:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Toon de beschrijving op basis van de leeftijd en thema
            Text(photo['descriptions']['Conflict']['0-18']),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sluit'),
            ),
          ],
        ),
      ),
    );
  }
}