import '../data/profile_icon_catalog.dart';

String? iconIdFromProductId(String productId) {
  for (final entry in ProfileIconCatalog.allIcons) {
    if (entry.kind == ProfileIconKind.premium &&
        entry.productId == productId) {
      return entry.id;
    }
  }
  return null;
}

Set<String> premiumProductIds() {
  return ProfileIconCatalog.allIcons
      .where((entry) => entry.kind == ProfileIconKind.premium)
      .map((entry) => entry.productId)
      .toSet();
}

Set<String> iconIdsFromProductIds(Iterable<String> productIds) {
  return productIds.map(iconIdFromProductId).whereType<String>().toSet();
}
