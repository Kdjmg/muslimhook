import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_data.dart';
import '../color_provider.dart';
import '../prayer_timings_list_of_quran.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ColorProvider(prefs)..loadSavedColors()),
        ChangeNotifierProvider(create: (context) => AppDataProvider()),
      ],
      child: const MaterialApp(home: ParamPage()),
    ),
  );
}

class ParamPage extends StatefulWidget {
  const ParamPage({super.key});

  @override
  State<ParamPage> createState() => _ParamPageState();
}

class _ParamPageState extends State<ParamPage> {
  PrayerTimings? prayerTimings;
  String selectedMethod = "";
  int selectedMethodIndex = 0;
  List<MapEntry<String, int>> angle = [
    const MapEntry('Shia Ithna-Ansari', 0),
    const MapEntry('University of Islamic Sciences, Karachi', 1),
    const MapEntry('Islamic Society of North America', 2),
    const MapEntry(' Muslim World League', 3),
    const MapEntry('Umm Al-Qura University, La Mecque', 4),
    const MapEntry('Autorité générale égyptienne des levés', 5),
    const MapEntry('Institut de géophysique, Université de Téhéran', 7),
    const MapEntry('Région du Golfe', 8),
    const MapEntry('Koweït', 9),
    const MapEntry('Qatar', 10),
    const MapEntry(' Majlis Ugama Islam Singapura, Singapour', 11),
    const MapEntry('Union Organisation islamique de France', 12),
    const MapEntry('Diyanet İşleri Başkanlığı, Turquie', 13),
    const MapEntry('Administration spirituelle des musulmans de Russie', 14),
    const MapEntry('Moonsighting Committee Worldwide', 15),
    const MapEntry('Dubaï ', 16),
  ];

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<ColorProvider>(context, listen: false);
    final appDataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgWidget(colorProvider.selectedSvgColor),
            Text(
                'Angle de calcul: ${angle[appDataProvider.selectedMethodValue].key}'),
            ElevatedButton(
              onPressed: () async {
                final configData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfigPage(
                      initialSvgColor: colorProvider.selectedSvgColor,
                      initialTextColor: colorProvider.selectedTextColor,
                      initialMethod: selectedMethod,
                      initialMethodIndex: selectedMethodIndex,
                      onSave: (configData) {
                        setState(() {
                          selectedMethod = configData['method'];
                          selectedMethodIndex = configData['methodIndex'];
                        });
                        if (configData['latitude'] != null &&
                            configData['longitude'] != null) {
                          fetchData(
                              configData['latitude'], configData['longitude']);
                          setState(() {});
                        } else {
                          print("Latitude et/ou longitude non disponibles");
                        }
                      },
                      initialBackgroundColor:
                          colorProvider.selectedBackgroundColor,
                      angle: angle,
                    ),
                  ),
                );
              },
              child: const Text('Configurer'),
            ),
          ],
        ),
      ),
    );
  }

  void fetchData(double latitude, double longitude) async {
    final now = DateTime.now();
    final formatDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final selectedMethodValue = angle[selectedMethodIndex].value;
    final response = await http.get(
      Uri.parse(
          "http://api.aladhan.com/v1/timings/$formatDate?latitude=$latitude&longitude=$longitude&method=$selectedMethodValue"),
    );
    print("valeur de selectMethodValue de paramPage:$selectedMethodValue");

    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      final jsonData = json.decode(response.body);
      setState(() {
        prayerTimings = PrayerTimings.fromJson(jsonData);
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}

class SvgWidget extends StatelessWidget {
  final Color color;

  SvgWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Center(
          child: Text(
        'thèmes',
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}

class ConfigPage extends StatefulWidget {
  final Color initialSvgColor;
  final Color initialTextColor;
  final Color initialBackgroundColor;
  final String initialMethod;
  final int initialMethodIndex;
  final Function(Map<String, dynamic>) onSave;
  final List<MapEntry<String, int>> angle;

  ConfigPage({
    Key? key,
    required this.initialSvgColor,
    required this.initialTextColor,
    required this.onSave,
    required this.initialBackgroundColor,
    required this.initialMethod,
    required this.initialMethodIndex,
    required this.angle,
  }) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late Color selectedSvgColor;
  late Color selectedTextColor;
  late Color selectedBackgroundColor;
  String selectedMethod = 'Shia Ithna-Ansari'; // Méthode par défaut
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    selectedSvgColor = widget.initialSvgColor;
    selectedTextColor = widget.initialTextColor;
    selectedBackgroundColor = widget.initialBackgroundColor;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = position;
      });
    } catch (e) {
      print("Erreur lors de la récupération de la localisation: $e");
    }
  }

  void changeSvgColor(Color color) {
    setState(() {
      selectedSvgColor = color;
    });
  }

  void changeTextColor(Color color) {
    setState(() {
      selectedTextColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appDataProvider =
        Provider.of<AppDataProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('Méthode de calcul:'),
          DropdownButton<String>(
            value: selectedMethod,
            onChanged: (value) {
              appDataProvider.updateSelectedMethodValue(
                  widget.angle.firstWhere((entry) => entry.key == value).value);
              setState(() {
                selectedMethod = value!;
              });
            },
            items: widget.angle.map<DropdownMenuItem<String>>((method) {
              return DropdownMenuItem<String>(
                value: method.key,
                child: Text(method.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          const Text("couleur de la Mosquée"),
          ColorPicker(
            pickerColor: selectedSvgColor,
            onColorChanged: changeSvgColor,
            showLabel: false,
            pickerAreaHeightPercent: 0.3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (currentLocation != null) {
                var colorProvider =
                    Provider.of<ColorProvider>(context, listen: false);
                colorProvider.setSelectedSvgColor(selectedSvgColor);
                colorProvider.setSelectedTextColor(selectedTextColor);
                colorProvider
                    .setSelectedBackgroundColor(selectedBackgroundColor);
                appDataProvider.updateSelectedMethodValue(widget.angle
                    .indexWhere((entry) => entry.key == selectedMethod));

                widget.onSave({
                  'method': selectedMethod,
                  'methodIndex': widget.angle
                      .indexWhere((entry) => entry.key == selectedMethod),
                  'latitude': currentLocation!.latitude,
                  'longitude': currentLocation!.longitude,
                  'selectedMethodValue': appDataProvider.selectedMethodValue
                });
                Navigator.pop(context);
                setState(() {});
              } else {
                print("Localisation non disponible");
              }
             
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
