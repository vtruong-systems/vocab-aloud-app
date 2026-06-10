enum SpeechSpeed {
  slow,
  normal,
  fast,
}

class AppSettings {
  const AppSettings({
    this.speechSpeed = SpeechSpeed.normal,
    this.autoReadLearnWord = false,
    this.autoReadQuizDefinition = false,
    this.requireTypeItForCompletion = false,
  });

  final SpeechSpeed speechSpeed;
  final bool autoReadLearnWord;
  final bool autoReadQuizDefinition;
  final bool requireTypeItForCompletion;

  AppSettings copyWith({
    SpeechSpeed? speechSpeed,
    bool? autoReadLearnWord,
    bool? autoReadQuizDefinition,
    bool? requireTypeItForCompletion,
  }) {
    return AppSettings(
      speechSpeed: speechSpeed ?? this.speechSpeed,
      autoReadLearnWord: autoReadLearnWord ?? this.autoReadLearnWord,
      autoReadQuizDefinition:
          autoReadQuizDefinition ?? this.autoReadQuizDefinition,
      requireTypeItForCompletion:
          requireTypeItForCompletion ?? this.requireTypeItForCompletion,
    );
  }

  Map<String, dynamic> toJson() => {
        'speechSpeed': speechSpeed.name,
        'autoReadLearnWord': autoReadLearnWord,
        'autoReadQuizDefinition': autoReadQuizDefinition,
        'requireTypeItForCompletion': requireTypeItForCompletion,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      speechSpeed: SpeechSpeed.values.firstWhere(
        (value) => value.name == json['speechSpeed'],
        orElse: () => SpeechSpeed.normal,
      ),
      autoReadLearnWord: json['autoReadLearnWord'] as bool? ?? false,
      autoReadQuizDefinition: json['autoReadQuizDefinition'] as bool? ?? false,
      requireTypeItForCompletion:
          json['requireTypeItForCompletion'] as bool? ?? false,
    );
  }
}
