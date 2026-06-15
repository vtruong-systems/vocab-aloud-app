import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/iap_helpers.dart';
import 'purchase_service.dart';

class InAppPurchaseService implements PurchaseService {
  InAppPurchaseService({InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _available = false;
  final Map<String, Completer<bool>> _pendingPurchases = {};
  bool _restoring = false;
  final Set<String> _restoreBuffer = {};

  @override
  bool get isStubFallback => false;

  @override
  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    await _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('IAP purchase stream error: $error');
        _failPendingPurchases();
      },
    );
  }

  @override
  Future<bool> isStoreAvailable() async => _available;

  @override
  Future<bool> purchaseProduct(String productId) async {
    if (!_available) return false;

    final response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      debugPrint('IAP queryProductDetails error: ${response.error}');
      return false;
    }
    if (response.productDetails.isEmpty) {
      debugPrint('IAP product not found: $productId');
      return false;
    }

    final completer = Completer<bool>();
    _pendingPurchases[productId] = completer;

    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: response.productDetails.first,
      ),
    );
    if (!started) {
      _pendingPurchases.remove(productId);
      return false;
    }

    try {
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          _pendingPurchases.remove(productId);
          return false;
        },
      );
    } catch (_) {
      _pendingPurchases.remove(productId);
      return false;
    }
  }

  @override
  Future<Set<String>> restorePurchases() async {
    if (!_available) return {};

    _restoring = true;
    _restoreBuffer.clear();

    await _iap.restorePurchases();
    await Future<void>.delayed(const Duration(seconds: 2));

    _restoring = false;
    final iconIds = iconIdsFromProductIds(_restoreBuffer);
    _restoreBuffer.clear();
    return iconIds;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _failPendingPurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        return;
      case PurchaseStatus.error:
        debugPrint('IAP purchase error: ${purchase.error}');
        _pendingPurchases.remove(productId)?.complete(false);
      case PurchaseStatus.canceled:
        _pendingPurchases.remove(productId)?.complete(false);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        if (_restoring) {
          _restoreBuffer.add(productId);
        }
        _pendingPurchases.remove(productId)?.complete(true);
    }
  }

  void _failPendingPurchases() {
    for (final completer in _pendingPurchases.values) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    _pendingPurchases.clear();
  }
}
