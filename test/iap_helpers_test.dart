import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/utils/iap_helpers.dart';

void main() {
  test('iconIdFromProductId strips vocab_icon_ prefix', () {
    expect(iconIdFromProductId('vocab_icon_octopus'), 'octopus');
    expect(iconIdFromProductId('other'), isNull);
  });

  test('iconIdsFromProductIds maps known product ids', () {
    expect(
      iconIdsFromProductIds(['vocab_icon_octopus', 'unknown']),
      {'octopus'},
    );
  });
}
