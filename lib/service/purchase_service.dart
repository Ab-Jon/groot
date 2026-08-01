import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  // Initialize in-app purchases
  static Future<void> init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    });
  }

  // Get available subscription products
  static Future<List<ProductDetails>> getProducts() async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({
      'your_subscription_id', // Replace with your product ID(s)
    });

    if (response.error != null) {
      throw Exception('Failed to load products: ${response.error}');
    }

    return response.productDetails;
  }

  // Check if user is subscribed
  static Future<bool> checkSubscriptionStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Fetch user subscription status from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
    return doc.exists && doc['isSubscribed'] == true;
  }

  // Handle the purchase updates
  static void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        _markSubscriptionAsActive();
      }
    }
  }

  // Mark user as subscribed in Firestore
  static Future<void> _markSubscriptionAsActive() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update subscription status in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.email).set(
      {
        'isSubscribed': true,
      },
      SetOptions(merge: true),
    );
  }

  // Buy a subscription
  static Future<void> buySubscription(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Restore previous purchases
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
