import 'grade_level.dart';

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.avatarEmoji,
    this.avatarPremiumId,
    this.maxGradeLevel,
  });

  final String id;
  final String displayName;
  final DateTime createdAt;
  final String? avatarEmoji;
  final String? avatarPremiumId;
  final GradeLevel? maxGradeLevel;

  GradeLevel get effectiveMaxGradeLevel =>
      GradeLevel.effectiveMax(maxGradeLevel);

  LocalProfile copyWith({
    String? displayName,
    String? avatarEmoji,
    String? avatarPremiumId,
    GradeLevel? maxGradeLevel,
    bool clearMaxGradeLevel = false,
    bool clearAvatarPremiumId = false,
  }) {
    return LocalProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarPremiumId:
          clearAvatarPremiumId ? null : (avatarPremiumId ?? this.avatarPremiumId),
      maxGradeLevel:
          clearMaxGradeLevel ? null : (maxGradeLevel ?? this.maxGradeLevel),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
        'avatarEmoji': avatarEmoji,
        if (avatarPremiumId != null) 'avatarPremiumId': avatarPremiumId,
        if (maxGradeLevel != null) 'maxGradeLevel': maxGradeLevel!.toJson(),
      };

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarEmoji: json['avatarEmoji'] as String?,
      avatarPremiumId: json['avatarPremiumId'] as String?,
      maxGradeLevel: GradeLevel.fromJson(json['maxGradeLevel'] as String?),
    );
  }
}
