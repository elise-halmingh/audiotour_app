import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? selectedTheme;
  TextEditingController ageController = TextEditingController();
  String? ageGroup;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Functie om voorkeuren (gebruiker leeftijd en thema) op te halen als JSON
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      // Als er data is, veranderen we de JSON-string naar een Map
      Map<String, dynamic> userData = json.decode(userDataJson);
      setState(() {
        ageController.text = userData['age'] ?? '';
        selectedTheme = userData['theme'];
        _setAgeGroup(ageController.text);
      });
    }
  }

  // Functie om leeftijd om te zetten naar leeftijdsgroep
  void _setAgeGroup(String age) {
    int? ageInt = int.tryParse(age);
    if (ageInt != null) {
      if (ageInt < 3) {
        ageGroup = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leeftijd mag niet lager zijn dan 3.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (ageInt > 127) {
        ageGroup = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leeftijd mag niet hoger zijn dan 127.'),
            backgroundColor: Colors.red,
          ),
        );
        ageController.text = '';
      } else if (ageInt <= 13) {
        ageGroup = '0-13';
      } else if (ageInt <= 30) {
        ageGroup = '14-30';
      } else {
        ageGroup = '31+';
      }
    } else {
      ageGroup = null;
    }
  }

  // Functie om voorkeuren op te slaan als JSON
  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String?> userData = {
      'age': ageController.text,
      'theme': selectedTheme,
    };
    // Omzetten naar JSON-string
    String userDataJson = json.encode(userData);
    await prefs.setString('user_data', userDataJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f0ea),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ExpoSound',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff82A790),
                  ),
                ),
                const Text(
                  'Selecteer je leeftijd en thema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff82A790),
                  ),
                ),
                const SizedBox(height: 35),

                // Leeftijd invoeren
                _buildTextField(
                  controller: ageController,
                  labelText: 'Leeftijd',
                  onChanged: (value) {
                    _setAgeGroup(value);
                  },
                  keyboardType: TextInputType.number,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // Thema dropdown
                _buildDropdownMenu(
                  title: 'Thema',
                  placeholder: 'Selecteer Thema',
                  value: selectedTheme,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTheme = newValue;
                    });
                  },
                  items: ['Geschiedenis', 'Natuur', 'Conflict'],
                ),
                const SizedBox(height: 30),

                // Doorgaan button
                ElevatedButton(
                  onPressed: () {
                    if (ageGroup != null && selectedTheme != null) {
                      _savePreferences();
                      Navigator.pushReplacementNamed(
                        context,
                        '/home',
                        arguments: {
                          'ageGroup': ageGroup,
                          'theme': selectedTheme,
                        },
                      );
                    } else {
                      showDialog(
                        // Alert pop up
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color(0xfff1f0ea),
                            title: const Text('Missing Information'),
                            content: const Text('Vul de benodigde informatie in alstublieft.'),
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
                    }
                  },
                  // Doorgaan button
                  child: const Text('Doorgaan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff82A790),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    foregroundColor: const Color(0xfff1f0ea),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text Styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
    required TextInputType keyboardType, required TextStyle labelStyle,
  }) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Color(0xff82A790),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 20,
            color: Color(0xff82A790),
          ),
          filled: true,
          fillColor: const Color(0xfff1f0ea),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff82A790), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff82A790), width: 2),
          ),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  // Dropdown Styling
  Widget _buildDropdownMenu({
    required String title,
    required String placeholder,
    required String? value,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff82A790),
          ),
          filled: true,
          fillColor: const Color(0xfff1f0ea),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff82A790), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff82A790), width: 2),
          ),
        ),
        value: value,
        hint: Text(
          placeholder,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xff82A790),
          ),
        ),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Color(0xff82A790)),
            ),
          );
        }).toList(),
        style: const TextStyle(
          color: Color(0xff82A790),
          fontSize: 18,
        ),
        dropdownColor: const Color(0xfff1f0ea),
        iconEnabledColor: const Color(0xff82A790),
        iconDisabledColor: Colors.grey,
      ),
    );
  }
}
