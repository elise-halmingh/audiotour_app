import 'dart:convert';
import 'package:audiotour_apps/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoPlayScreen extends StatefulWidget {
  final int currentQR;

  const PhotoPlayScreen({Key? key, required this.currentQR}) : super(key: key);

  @override
  _PhotoPlayScreenState createState() => _PhotoPlayScreenState();
}

class _PhotoPlayScreenState extends State<PhotoPlayScreen> {
  late Map<String, dynamic> selectedPhoto;
  List<Map<String, dynamic>> photos = [];
  bool isAudioPlaying = false;
  String userAgeGroup = '';
  String userTheme = '';
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    loadPhotos();
    loadUserPreferences();
  }

  // Functie om de leeftijd om te zetten naar leeftijdsgroep
  String getAgeGroup(int age) {
    if (age <= 18) return '0-18';
    if (age <= 50) return '19-50';
    return '51+';
  }

  // Laad de voorkeuren van de gebruiker
  Future<void> loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      Map<String, dynamic> userData = json.decode(userDataJson);
      setState(() {
        int age = int.tryParse(userData['age'] ?? '0') ?? 0;
        userAgeGroup = userData['ageGroup'] ?? getAgeGroup(age);
        userTheme = userData['theme'] ?? '';
      });
    } else {
      setState(() {
        userAgeGroup = '';
        userTheme = '';
      });
    }

    print('Leeftijdsgroep: $userAgeGroup, Thema: $userTheme');
  }

  // Verkrijg de beschrijving op basis van de leeftijd en het thema
  String getDescriptionForAgeAndTheme(Map<String, dynamic> photo) {
    // Check of de thema beschrijving beschikbaar is voor de gekozen leeftijdsgroep en thema
    if (userAgeGroup.isEmpty || userTheme.isEmpty) {
      return 'Kies een thema en leeftijdsgroep om een beschrijving te tonen.';
    }

    var themeDescriptions = photo['descriptions'][userTheme];

    print('Huidige thema: $userTheme, Leeftijdsgroep: $userAgeGroup');

    if (themeDescriptions != null) {
      String description = themeDescriptions[userAgeGroup] ?? 'Geen beschrijving beschikbaar voor deze leeftijdsgroep.';
      print('Beschrijving: $description');
      return description;
    }

    return 'Geen beschrijving beschikbaar voor dit thema.';
  }

  // Laad de foto's van het bestand
  Future<void> loadPhotos() async {
    String jsonString = await rootBundle.loadString('assets/photos.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<Map<String, dynamic>> loadedPhotos = (jsonData['photos'] as List)
        .map((photo) => Map<String, dynamic>.from(photo))
        .toList();

    setState(() {
      photos = loadedPhotos;
      selectedPhoto = photos.firstWhere(
            (photo) => photo['id'] == widget.currentQR,
        orElse: () => {},
      );
    });
  }

  // Functie om naar de volgende QR-code te gaan
  void _goToNextQRCode() {
    int nextQR = widget.currentQR + 1;
    if (nextQR > 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Alle QR-codes zijn gescand!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scan de volgende QR-code"),
        content: Text("Scan de volgende QR-code: $nextQR"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(nextQRCode: nextQR),
                ),
              );
            },
            child: const Text("QR Scanner openen"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Plattegrond openen"),
          ),
        ],
      ),
    );
  }

  // Functie om de tekst af te spelen met TTS
  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      print("Bezig met afspelen van tekst: $text");
      await flutterTts.speak(text);
    } else {
      print("Geen tekst om af te spelen.");
    }
  }

  @override
  Widget build(BuildContext context) {
    String photographer = selectedPhoto['photographer'] ?? 'Onbekend';
    String photoText = getDescriptionForAgeAndTheme(selectedPhoto);

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(selectedPhoto['imagePath'], fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(
                selectedPhoto['title'] ?? 'Geen titel',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Gemaakt door: $photographer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff9E9999)),
              ),
              const SizedBox(height: 16),
              Text(
                photoText,
                style: const TextStyle(fontSize: 16, color: Color(0xff5A7364)),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isAudioPlaying = true;
                    });
                    // Roep de functie aan om de tekst af te spelen
                    await _speakText(photoText);
                    setState(() {
                      isAudioPlaying = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF82A790),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    isAudioPlaying ? 'Afspelen...' : 'Tekst afspelen',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.currentQR > 1)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf1f0ea),
                        side: const BorderSide(color: Color(0xFF82A790), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'Vorige',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF82A790)),
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: widget.currentQR == 5
                        ? () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    }
                        : _goToNextQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf1f0ea),
                      side: const BorderSide(color: Color(0xFF82A790), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      widget.currentQR == 5 ? 'Klaar' : 'Volgende',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF82A790)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
