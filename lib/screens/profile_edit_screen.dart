import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String? selectedTheme;
  TextEditingController ageController = TextEditingController();
  String? ageGroup;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
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
        ageGroup = '3-13';
      } else if (ageInt <= 30) {
        ageGroup = '14-30';
      } else {
        ageGroup = '31+';
      }
    } else {
      ageGroup = null;
    }
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String?> userData = {
      'age': ageController.text,
      'theme': selectedTheme,
      'ageGroup': ageGroup,
    };
    String userDataJson = json.encode(userData);
    await prefs.setString('user_data', userDataJson);
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titel "Profiel Bewerken"
                const Text(
                  'Profiel Bewerken',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff82A790),
                  ),
                ),
                const SizedBox(height: 30),

                // Leeftijd invoeren
                _buildTextField(
                  controller: ageController,
                  labelText: 'Leeftijd',
                  onChanged: (value) {
                    _setAgeGroup(value);
                  },
                  keyboardType: TextInputType.number,
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

                // Opslaan button
                ElevatedButton(
                  onPressed: () {
                    if (ageGroup != null && selectedTheme != null) {
                      _savePreferences();
                      Navigator.pop(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
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
                  // Opslaan button
                  child: const Text('Opslaan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff82A790),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text Field Styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
    required TextInputType keyboardType,
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
