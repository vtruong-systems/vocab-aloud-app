enum PremiumPurchaseResult {
  success,
  cancelled,
  storeUnavailable,
  failed,
}

abstract class PurchaseService {
  bool get isStubFallback;

  Future<void> initialize();

  Future<bool> isStoreAvailable();

  Future<bool> purchaseProduct(String productId);

  Future<Set<String>> restorePurchases();

  void dispose();
}

class StubPurchaseService implements PurchaseService {
  const StubPurchaseService();

  @override
  bool get isStubFallback => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isStoreAvailable() async => true;

  @override
  Future<bool> purchaseProduct(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<Set<String>> restorePurchases() async => {};

  @override
  void dispose() {}
}
