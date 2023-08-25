import 'package:flutter/material.dart';
import 'package:muslimhook/pages/HomePage.dart';
import 'package:muslimhook/pages/ParamPage.dart';
import 'package:muslimhook/pages/SecondPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_data.dart';
import 'color_provider.dart';


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorProvider = context.watch<ColorProvider>();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Provider.of<ColorProvider>(context).selectedSvgColor,
          title: [
            const Text("Heure de prières"),
            const Text("Coran"),
            const Text("Configuration")
          ][_currentIndex],
        ),
        body: [
          HomePage(
            selectedSvgColor: colorProvider.selectedSvgColor,
            selectedMethodValue: 0,
          ),
           SecondPage(selectedSvgColor: colorProvider.selectedSvgColor,),
          const ParamPage(),
        ][_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setCurrentIndex(index),
          selectedItemColor: colorProvider.selectedSvgColor,
          unselectedItemColor: Colors.grey,
          iconSize: 32,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "heures de prières",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label:"Coran"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "configuration",
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ColorProvider(prefs)..loadSavedColors()),
        ChangeNotifierProvider(create: (context) => AppDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}