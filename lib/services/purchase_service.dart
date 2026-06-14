abstract class PurchaseService {
  Future<bool> purchaseProduct(String productId);
}

class StubPurchaseService implements PurchaseService {
  const StubPurchaseService();

  @override
  Future<bool> purchaseProduct(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
