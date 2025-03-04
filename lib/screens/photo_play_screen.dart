import 'dart:convert';
import 'dart:io';
import 'package:audiotour_apps/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PhotoPlayScreen extends StatefulWidget {
  final int currentQR;

  const PhotoPlayScreen({super.key, required this.currentQR});

  @override
  _PhotoPlayScreenState createState() => _PhotoPlayScreenState();
}

class _PhotoPlayScreenState extends State<PhotoPlayScreen> {
  late Map<String, dynamic> selectedPhoto;
  List<Map<String, dynamic>> photos = [];
  bool isAudioPlaying = false;
  String userAgeGroup = '';
  String userTheme = '';
  final String apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  final String voiceId = "21m00Tcm4TlvDq8ikWAM";

  // Audioplayers speler
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    loadPhotos();
    loadUserPreferences();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Functie om de leeftijd om te zetten naar leeftijdsgroep
  String getAgeGroup(int age) {
    if (age <= 18) return '0-18';
    if (age <= 50) return '19-50';
    return '51+';
  }

  // Laad de gekozen leeftijd en thema van de gebruiker
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
  }

  // Verkrijg de beschrijving op basis van de leeftijd en het thema
  String getDescriptionForAgeAndTheme(Map<String, dynamic> photo) {
    if (userAgeGroup.isEmpty || userTheme.isEmpty) {
      return 'Kies een thema en leeftijdsgroep om een beschrijving te tonen.';
    }

    var themeDescriptions = photo['descriptions'][userTheme];

    if (themeDescriptions != null) {
      String description = themeDescriptions[userAgeGroup] ?? 'Geen beschrijving beschikbaar voor deze leeftijdsgroep.';
      return description;
    }

    return 'Geen beschrijving beschikbaar voor dit thema.';
  }

  // Laad de foto's van JSON bestand
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

  // Tekst afspelen
  Future<void> _speakText(String text) async {
    // Als er geen beschrijving is gevonden, toon foutmelding
    if (text.isEmpty) {
      print("Geen tekst om af te spelen.");
      return;
    }
    print("Bezig met afspelen van tekst: $text");

    final response = await http.post(
      Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$voiceId"),
      headers: {
        "Content-Type": "application/json",
        "xi-api-key": apiKey,
      },
      // ElevenLabs instellingen
      body: jsonEncode({
        "text": text,
        "voice_id": "nl-voice-id",
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.8}}),
    );

    if (response.statusCode == 200) {
      print("Audio gegenereerd.");

      try {
        // Verkrijg de path voor tijdelijke opslag
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/audio.mp3');

        // Schrijf de inhoud naar een bestand
        await file.writeAsBytes(response.bodyBytes);

        // Speel het bestand af met audioplayers
        await _audioPlayer.play(DeviceFileSource(file.path));
      } catch (e) {
        print("Fout bij het afspelen van audio: $e");
      }
    } else {
      print("Fout bij het genereren van audio: ${response.body}");
    }
  }

  // Naar volgende QR code gaan.
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
        backgroundColor: const Color(0xfff1f0ea),
        title: Text(
          "Scan de volgende QR-code: $nextQR",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff5A7364),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/map');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xff82A790),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      "Plattegrond",
                      style: TextStyle(
                        color: Color(0xff82A790),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerScreen(nextQRCode: nextQR),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff82A790),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "QR Scanner",
                      style: TextStyle(
                        color: Color(0xfff1f0ea),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                    if (_audioPlayer.state == PlayerState.playing) {
                      await _audioPlayer.pause();
                      setState(() {
                        isAudioPlaying = false;
                      });
                    } else if (_audioPlayer.state == PlayerState.paused) {
                      await _audioPlayer.resume();
                      setState(() {
                        isAudioPlaying = true;
                      });
                    } else {
                      setState(() {
                        isAudioPlaying = true;
                      });
                      await _speakText(photoText);
                      setState(() {
                        isAudioPlaying = false;
                      });
                    }
                    _audioPlayer.onPlayerComplete.listen((event) {
                      setState(() {
                        isAudioPlaying = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF82A790),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _audioPlayer.state == PlayerState.playing
                        ? 'Pauzeren'
                        : 'Afspelen',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff1f0ea),
                    ),
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
