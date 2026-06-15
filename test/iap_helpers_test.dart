import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/utils/iap_helpers.dart';

void main() {
  test('iconIdFromProductId maps Play Console SKU to icon id', () {
    expect(
      iconIdFromProductId('blueberini_octopusini_icon'),
      'octopus',
    );
    expect(iconIdFromProductId('unknown_product'), isNull);
  });

  test('iconIdsFromProductIds maps known product ids', () {
    expect(
      iconIdsFromProductIds([
        'blueberini_octopusini_icon',
        'unknown',
      ]),
      {'octopus'},
    );
  });
}
