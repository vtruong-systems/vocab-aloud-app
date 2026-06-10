import '../models/vocabulary_set.dart';

bool setMatchesQuery(VocabularySet set, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;

  final fields = <String?>[
    set.id,
    set.title,
    set.theme,
    set.gradeLabel,
    set.description,
    set.teacher,
    set.school,
  ];

  return fields.any(
    (field) => field != null && field.toLowerCase().contains(normalized),
  );
}

List<VocabularySet> filterSetsByQuery(
  List<VocabularySet> sets,
  String query,
) {
  return sets.where((set) => setMatchesQuery(set, query)).toList();
}

List<VocabularySet> defaultSets(List<VocabularySet> sets) {
  return sets
      .where((set) => set.source == VocabularySetSource.defaultSet)
      .toList();
}

List<VocabularySet> communitySets(List<VocabularySet> sets) {
  return sets
      .where((set) => set.source == VocabularySetSource.community)
      .toList();
}

bool hasCommunitySets(List<VocabularySet> sets) {
  return sets.any((set) => set.isCommunity);
}
