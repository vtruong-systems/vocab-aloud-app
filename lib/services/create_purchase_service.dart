import 'in_app_purchase_service.dart';
import 'purchase_service.dart';

Future<PurchaseService> createPurchaseService() async {
  final iap = InAppPurchaseService();
  await iap.initialize();
  if (await iap.isStoreAvailable()) {
    return iap;
  }
  iap.dispose();
  return const StubPurchaseService();
}
