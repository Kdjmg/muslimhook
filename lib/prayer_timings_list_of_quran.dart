class PrayerTimings {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimings({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    return PrayerTimings(
      fajr: json['data']['timings']['Fajr'],
      dhuhr: json['data']['timings']['Dhuhr'],
      asr: json['data']['timings']['Asr'],
      maghrib: json['data']['timings']['Maghrib'],
      isha: json['data']['timings']['Isha'],
    );
  }
}

class ListOfQuran {
  final int number;
  final String name;
  final String englishName;

  ListOfQuran(
      {required this.number, required this.name, required this.englishName});

  factory ListOfQuran.fromJson(Map<String, dynamic> json) {
    return ListOfQuran(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
    );
  }
}

class Sourate {
  final String text;
  final String audio;

  Sourate({required this.text, required this.audio});

  factory Sourate.fromJson(Map<String, dynamic> json) {
    return Sourate(
      text: json['text'],
      audio: json['audio'],
    );
  }
}
