enum SpeechSpeed { slow, normal, fast }

class AppSettings {
  const AppSettings({
    this.speechSpeed = SpeechSpeed.normal,
    this.autoReadLearnWord = true,
    this.autoReadQuizDefinition = true,
    this.requireTypeItForCompletion = false,
    this.heardPracticeDefault = true,
  });

  final SpeechSpeed speechSpeed;
  final bool autoReadLearnWord;
  final bool autoReadQuizDefinition;
  final bool requireTypeItForCompletion;

  /// Set after the first launch that turns spoken practice on by default.
  /// Older saves omitted this flag while leaving auto-read off.
  final bool heardPracticeDefault;

  AppSettings copyWith({
    SpeechSpeed? speechSpeed,
    bool? autoReadLearnWord,
    bool? autoReadQuizDefinition,
    bool? requireTypeItForCompletion,
    bool? heardPracticeDefault,
  }) {
    return AppSettings(
      speechSpeed: speechSpeed ?? this.speechSpeed,
      autoReadLearnWord: autoReadLearnWord ?? this.autoReadLearnWord,
      autoReadQuizDefinition:
          autoReadQuizDefinition ?? this.autoReadQuizDefinition,
      requireTypeItForCompletion:
          requireTypeItForCompletion ?? this.requireTypeItForCompletion,
      heardPracticeDefault: heardPracticeDefault ?? this.heardPracticeDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'speechSpeed': speechSpeed.name,
    'autoReadLearnWord': autoReadLearnWord,
    'autoReadQuizDefinition': autoReadQuizDefinition,
    'requireTypeItForCompletion': requireTypeItForCompletion,
    'heardPracticeDefault': heardPracticeDefault,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      speechSpeed: SpeechSpeed.values.firstWhere(
        (value) => value.name == json['speechSpeed'],
        orElse: () => SpeechSpeed.normal,
      ),
      autoReadLearnWord: json['autoReadLearnWord'] as bool? ?? true,
      autoReadQuizDefinition: json['autoReadQuizDefinition'] as bool? ?? true,
      requireTypeItForCompletion:
          json['requireTypeItForCompletion'] as bool? ?? false,
      heardPracticeDefault: json['heardPracticeDefault'] as bool? ?? false,
    );
  }
}
