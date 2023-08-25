import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:muslimhook/color_provider.dart';
import 'package:muslimhook/prayer_timings_list_of_quran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../color_provider.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ColorProvider(prefs)..loadSavedColors(),
      child: const MaterialApp(
          home: SecondPage(
        selectedSvgColor: Colors.blueAccent,
      )),
    ),
  );
}

class SecondPage extends StatefulWidget {
  const SecondPage({
    super.key,
    required this.selectedSvgColor,
  });
  final Color selectedSvgColor;
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<ListOfQuran> listsquran = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse("http://api.alquran.cloud/v1/surah"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data'] as List<dynamic>;

      List<ListOfQuran> listOfquran =
          dataList.map((item) => ListOfQuran.fromJson(item)).toList();

      setState(() {
        listsquran = listOfquran;
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: listsquran.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsOfQuran(
                    quranDetails: listsquran[index],
                  ),
                ),
              );
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listsquran[index].number.toString(),
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 22,
                            color: Provider.of<ColorProvider>(context)
                                .selectedSvgColor))),
                Text(' ${listsquran[index].name}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 22,
                            color: Provider.of<ColorProvider>(context)
                                .selectedSvgColor))),
                Text(' ${listsquran[index].englishName}',
                    style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                            fontSize: 22,
                            color: Provider.of<ColorProvider>(context)
                                .selectedSvgColor))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DetailsOfQuran extends StatefulWidget {
  final ListOfQuran quranDetails;

  const DetailsOfQuran({Key? key, required this.quranDetails})
      : super(key: key);

  @override
  _DetailsOfQuranState createState() => _DetailsOfQuranState();
}

class _DetailsOfQuranState extends State<DetailsOfQuran> {
  final audioPlayer = AudioPlayer();
  List<Sourate> sourate = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        "https://api.alquran.cloud/v1/surah/${widget.quranDetails.number}/ar.abdurrahmaansudais"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data']['ayahs'] as List<dynamic>;

      List<Sourate> sourateList =
          dataList.map((item) => Sourate.fromJson(item)).toList();

      setState(() {
        sourate = sourateList;
        audioPlayer.setSourceUrl(sourate[0].audio);
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  int currentIndex = 0;
  Future<void> playAudio(int index) async {
    if (index >= 0 && index < sourate.length) {
      // ignore: unnecessary_cast
      await audioPlayer.play(UrlSource(sourate[index].audio as String));
      audioPlayer.onPlayerComplete.listen((event) {
        currentIndex++;
        if (currentIndex < sourate.length) {
          playAudio(currentIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<ColorProvider>(context).selectedSvgColor,
        title: Text(widget.quranDetails.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Divider(), // Add a separator here
          Expanded(
            child: ListView.separated(
              itemCount: sourate.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    sourate[index].text,
                    style: GoogleFonts.cinzel(
                      textStyle: TextStyle(
                        fontSize: 22,
                        color: Provider.of<ColorProvider>(context)
                            .selectedSvgColor,
                      ),
                    ),
                  ),
                  onTap: () {
                    currentIndex = index;
                    playAudio(currentIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
