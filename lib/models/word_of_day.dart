class WordOfDay {
  final int dayOfYear;
  final String germanWord;
  final String englishMeaning;
  final String exampleSentenceGerman;
  final String exampleSentenceEnglish;

  WordOfDay({
    required this.dayOfYear,
    required this.germanWord,
    required this.englishMeaning,
    required this.exampleSentenceGerman,
    required this.exampleSentenceEnglish,
  });

  factory WordOfDay.fromJson(Map<String, dynamic> json) {
    return WordOfDay(
      dayOfYear: json['dayOfYear'] as int,
      germanWord: json['germanWord'] as String,
      englishMeaning: json['englishMeaning'] as String,
      exampleSentenceGerman: json['exampleSentenceGerman'] as String,
      exampleSentenceEnglish: json['exampleSentenceEnglish'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfYear': dayOfYear,
      'germanWord': germanWord,
      'englishMeaning': englishMeaning,
      'exampleSentenceGerman': exampleSentenceGerman,
      'exampleSentenceEnglish': exampleSentenceEnglish,
    };
  }
}
