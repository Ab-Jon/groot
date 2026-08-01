import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod/riverpod.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
      (ref) => SubscriptionNotifier(),
);

class SubscriptionState {
  final bool isAvailable;
  final bool isSubscribed;
  final List<ProductDetails> products;

  SubscriptionState({required this.isAvailable, required this.isSubscribed, required this.products});
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];

  SubscriptionNotifier()
      : super(SubscriptionState(isAvailable: false, isSubscribed: false, products: []));

  Future<void> initialize() async {
    // Check if billing is available
    bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      state = SubscriptionState(isAvailable: false, isSubscribed: false, products: []);
      print("Billing is not available. Ensure Google Play Services is installed.");
      return;
    }

    // Define product IDs for your subscriptions
    const Set<String> _productIds = {'principal_product', 'groot_access'};

    // Query available products from the Play Store
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

    // Check for errors in the response
    if (response.error != null) {
      print("Error querying product details: ${response.error}");
    }

    // Check if any product IDs were not found
    if (response.notFoundIDs.isNotEmpty) {
      print("Product IDs not found: ${response.notFoundIDs}");
    }

    // If no products are found, return early
    if (response.productDetails.isEmpty) {
      print("No products found.");
      state = SubscriptionState(isAvailable: available, isSubscribed: false, products: []);
      return;
    }

    // Store the available products and update the state
    _products = response.productDetails;
    state = SubscriptionState(isAvailable: available, isSubscribed: false, products: _products);

    // Start listening for purchases
    listenToPurchases();
  }

  void buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void listenToPurchases() {
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          verifyPurchase(purchase);
        }
      }
    });
  }

  void verifyPurchase(PurchaseDetails purchase) {
    if (purchase.productID == 'principal_product') {
      state = SubscriptionState(isAvailable: true, isSubscribed: true, products: _products);
    }
  }

  void restorePurchases() {
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          verifyPurchase(purchase);
        }
      }
    });
  }
}
