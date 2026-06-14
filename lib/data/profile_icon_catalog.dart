const presetEmojis = ['🦊', '🐶', '🐱', '🐻', '🦁', '🐸', '🐼', '🦄', '🌟', '📚'];

const _emojiIds = {
  '🦊': 'fox',
  '🐶': 'dog',
  '🐱': 'cat',
  '🐻': 'bear',
  '🦁': 'lion',
  '🐸': 'frog',
  '🐼': 'panda',
  '🦄': 'unicorn',
  '🌟': 'star',
  '📚': 'books',
};

enum ProfileIconKind { emoji, premium }

class ProfileIconEntry {
  const ProfileIconEntry({
    required this.id,
    required this.kind,
    this.emoji,
    this.assetPath,
    this.featured = false,
    this.free = false,
  });

  final String id;
  final ProfileIconKind kind;
  final String? emoji;
  final String? assetPath;
  final bool featured;
  final bool free;

  /// Future App Store / Play SKU: vocab_icon_{id}
  String get productId => 'vocab_icon_$id';

  String get displayName {
    if (kind == ProfileIconKind.emoji) return emoji ?? id;
    return id[0].toUpperCase() + id.substring(1);
  }
}

class ProfileIconCatalog {
  ProfileIconCatalog._();

  static final List<ProfileIconEntry> _emojiIcons = presetEmojis
      .map(
        (emoji) => ProfileIconEntry(
          id: _emojiIds[emoji] ?? emoji,
          kind: ProfileIconKind.emoji,
          emoji: emoji,
          free: true,
        ),
      )
      .toList();

  static const List<ProfileIconEntry> _premiumIcons = [
    ProfileIconEntry(
      id: 'octopus',
      kind: ProfileIconKind.premium,
      assetPath: 'assets/icons/premium/octopus.png',
      featured: true,
    ),
  ];

  static List<ProfileIconEntry> get allIcons => [
        ..._emojiIcons,
        ...List<ProfileIconEntry>.from(_premiumIcons)
          ..sort((a, b) => a.id.compareTo(b.id)),
      ];

  static List<ProfileIconEntry> get featuredIcons =>
      allIcons.where((entry) => entry.featured).toList();

  static ProfileIconEntry? findById(String id) {
    for (final entry in allIcons) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  static ProfileIconEntry? findEmojiEntry(String emoji) {
    for (final entry in _emojiIcons) {
      if (entry.emoji == emoji) return entry;
    }
    return null;
  }
}
