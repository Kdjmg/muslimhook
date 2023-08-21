import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color_provider.dart';
import '../prayer_timings.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {required this.selectedSvgColor,
        required this.selectedMethodValue,
        Key? key})
      : super(key: key);

  final Color selectedSvgColor;
  final int selectedMethodValue;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentTime;
  late String currentDay;
  late Timer timer;
  PrayerTimings? prayerTimings;
  Position? currentLocation;
  late int selectedMethodValue;

  @override
  void initState() {
    super.initState();
    selectedMethodValue = widget.selectedMethodValue;
    currentTime = _getCurrentDateTime();
    currentDay = _getCurrentDay();
    startTimer();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Demander l'autorisation d'accès à la géolocalisation
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        // L'autorisation a été accordée, vous pouvez accéder à la géolocalisation
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        setState(() {
          currentLocation = position;
        });

        print("Votre localisation : $position");
        await fetchData(position.latitude, position.longitude);
      } else if (status.isDenied) {
        // L'utilisateur a refusé l'autorisation, vous pouvez lui montrer un message explicatif
        print("L'utilisateur a refusé l'autorisation de localisation");
      }
    } catch (e) {
      print("Erreur lors de la récupération de la localisation: $e");
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = _getCurrentDateTime();
      });
    });
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;

    return '$day/$month/$year';
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  Future<void> fetchData(double latitude, double longitude) async {
    final now = DateTime.now();
    final formatDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final response = await http.get(
      Uri.parse(
          "http://api.aladhan.com/v1/timings/$formatDate?latitude=$latitude&longitude=$longitude&method=$selectedMethodValue"),
    );

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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<ColorProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/310342.svg",
                  colorFilter: ColorFilter.mode(
                      widget.selectedSvgColor, BlendMode.srcIn),
                  height: 630,
                ),
                Positioned(
                  bottom: 190,
                  left: 155,
                  child: Text(
                    currentDay,
                    style: GoogleFonts.cinzel(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 70,
                  child: Text(
                    'muslimhook',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 130,
                  child: Text(
                    "heure de prières",
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 150,
                  left: 180,
                  child: Text(
                    currentTime,
                    style: GoogleFonts.cinzel(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 120,
                  child: Text(
                    'Fajr: ${prayerTimings?.fajr}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: colorProvider.selectedSvgColor)),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 120,
                  child: Text(
                    'Dhuhr: ${prayerTimings?.dhuhr}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: colorProvider.selectedSvgColor)),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 120,
                  child: Text(
                    'Asr: ${prayerTimings?.asr}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: colorProvider.selectedSvgColor)),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 120,
                  child: Text(
                    'Maghrib: ${prayerTimings?.maghrib}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: colorProvider.selectedSvgColor)),
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 120,
                  child: Text(
                    'Isha: ${prayerTimings?.isha}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 30,
                            color: colorProvider.selectedSvgColor)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ColorProvider(prefs)..loadSavedColors(),
      child: const MaterialApp(
          home: HomePage(
            selectedSvgColor: Colors.blueAccent,
            selectedMethodValue: 0,
          )),
    ),
  );
}
