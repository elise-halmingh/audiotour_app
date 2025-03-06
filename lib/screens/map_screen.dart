import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MapScreen extends StatelessWidget {
  //Locatie cirkels
  final List<Map<String, double>> positions = [
    {'top': 60, 'left': 75},
    {'top': 60, 'left': 200},
    {'top': 150, 'left': 280},
    {'top': 240, 'left': 200},
    {'top': 325, 'left': 10},
    {'top': 350, 'left': 125},
    {'top': 370, 'left': 365},
    {'top': 585, 'left': 100},
    {'top': 500, 'left': 365},
    {'top': 500, 'left': 10},
  ];

  // Functie om de foto-gegevens te laden uit photos.json
  Future<List<Map<String, dynamic>>> loadPhotos() async {
    String jsonString = await rootBundle.loadString('assets/photos.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<Map<String, dynamic>> loadedPhotos = (jsonData['photos'] as List)
        .map((photo) => Map<String, dynamic>.from(photo))
        .toList();
    return loadedPhotos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar
      backgroundColor: const Color(0xfff1f0ea),
      appBar: AppBar(
        backgroundColor: const Color(0xfff1f0ea),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(14.0),
            child: Center(
              child: Column(
                children: [
                  // Titel
                  Text(
                    'Plattegrond',
                    style: TextStyle(
                      color: Color(0xff5A7364),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Ondertitel
                  Text(
                    'Klik op de nummers om de foto te zien',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff82A790),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  // De plattegrond svg
                  SvgPicture.asset(
                    'assets/images/plattegrond.svg',
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Genummerde cirkels die worden gepositioneerd op de plattegrond
                  for (int i = 0; i < 10; i++)
                    Positioned(
                      top: positions[i]['top']!,
                      left: positions[i]['left']!,
                      child: GestureDetector(
                        // Wanneer er op een cirkel wordt geklikt, wordt _showPopup aangeroepen
                        onTap: () {
                          _showPopup(context, i + 1);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF82A790),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Functie om de pop-up te tonen voor de geselecteerde cirkel
  void _showPopup(BuildContext context, int photoNumber) async {
    final photos = await loadPhotos();
    final photo = photos.firstWhere(
          (photo) => photo['id'] == photoNumber,
      orElse: () => {},
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFf1f0ea),
          // Titel ophalen
          title: photo.isNotEmpty
              ? Text(photo['title'] ?? 'Geen titel beschikbaar')
              : const Text('Coming Soon'),
          content: photo.isNotEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Laad de afbeelding uit assets
              photo['imagePath'] != null
                  ? Image.asset(
                photo['imagePath'],
                errorBuilder: (context, error, stackTrace) {
                  return Text('Afbeelding niet gevonden!');
                },
              )
                  : Text('Geen afbeelding beschikbaar'),
            ],
          )
              : const Text('Coming Soon'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sluiten'),
              style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF82A790),
              ),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}
