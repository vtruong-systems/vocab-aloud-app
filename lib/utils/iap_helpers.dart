import '../data/profile_icon_catalog.dart';

const iapProductIdPrefix = 'vocab_icon_';

String? iconIdFromProductId(String productId) {
  if (!productId.startsWith(iapProductIdPrefix)) return null;
  return productId.substring(iapProductIdPrefix.length);
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
