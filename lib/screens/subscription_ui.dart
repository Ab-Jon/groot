// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../service/subscription_provider.dart';
// //
// // class SubscriptionScreen extends ConsumerWidget {
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final subscriptionState = ref.watch(subscriptionProvider);
// //
// //     // Call initialize() when the widget is first built
// //     Future.delayed(Duration.zero, () {
// //       ref.read(subscriptionProvider.notifier).initialize();
// //     });
// //
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Subscription")),
// //       body: subscriptionState.isAvailable
// //           ? Column(
// //         children: [
// //           // Subscription status
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Text(
// //               subscriptionState.isSubscribed
// //                   ? "You are subscribed ✅"
// //                   : "Not subscribed ❌",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //
// //           // Show available subscription options
// //           if (subscriptionState.products.isNotEmpty)
// //             SizedBox(
// //               child: ListView.builder(
// //                 itemCount: subscriptionState.products.length,
// //                 itemBuilder: (context, index) {
// //                   final product = subscriptionState.products[index];
// //                   return Card(
// //                     child: ListTile(
// //                       title: Text(product.title),
// //                       subtitle: Text(product.description),
// //                       trailing: Text("\$${product.price}"),
// //                       onTap: () {
// //                         ref.read(subscriptionProvider.notifier).buySubscription(product);
// //                       },
// //                     ),
// //                   );
// //                 },
// //               ),
// //             )
// //           else
// //             Center(child: Text("No subscriptions available")),
// //
// //           // Restore Purchases Button
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: ElevatedButton(
// //               onPressed: () {
// //                 ref.read(subscriptionProvider.notifier).restorePurchases();
// //               },
// //               child: Text("Restore Purchases"),
// //             ),
// //           ),
// //         ],
// //       )
// //           : Center(
// //         child: Text("Billing is not available."),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
//
// class SubscriptionScreen extends StatefulWidget {
//   @override
//   _SubscriptionScreenState createState() => _SubscriptionScreenState();
// }
//
// class _SubscriptionScreenState extends State<SubscriptionScreen> {
//   Offerings? _offerings;
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOfferings();
//   }
//
//   Future<void> _loadOfferings() async {
//     try {
//       Offerings offerings = await Purchases.getOfferings();
//       setState(() {
//         _offerings = offerings;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _loading = false;
//       });
//       print("Error loading offerings: $e");
//     }
//   }
//
//   Future<void> _purchase(Package package) async {
//     try {
//       CustomerInfo customerInfo = await Purchases.purchasePackage(package);
//       bool isPro = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
//       if (isPro) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("You're now subscribed!")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Purchase failed: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     final packages = _offerings?.current?.availablePackages ?? [];
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Choose a Plan")),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: packages.length,
//         itemBuilder: (context, index) {
//           final pkg = packages[index];
//           return Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             margin: EdgeInsets.symmetric(vertical: 10),
//             child: ListTile(
//               title: Text(pkg.storeProduct.title),
//               subtitle: Text(pkg.storeProduct.description),
//               trailing: Text(pkg.storeProduct.priceString),
//               onTap: () => _purchase(pkg),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:groot/screens/welcome_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'home_screen.dart';

class PremiumPricingScreen extends StatefulWidget {
  @override
  _PremiumPricingScreenState createState() => _PremiumPricingScreenState();
}

class _PremiumPricingScreenState extends State<PremiumPricingScreen> {
  Offerings? _offerings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadOfferings();
  }

  Future<void> _checkSubscription() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPro = info.entitlements.all['Premium']?.isActive ?? false;

      if (isPro) {
        // Navigate automatically if already subscribed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        });
      }
    } catch (e) {
      print("Failed to check subscription: $e");
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      setState(() {
        _offerings = offerings;
        _loading = false;
      });
    } catch (e) {
      print("Error loading offerings: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    try {
      CustomerInfo info = (await Purchases.purchasePackage(package)) as CustomerInfo;
      if (info.entitlements.all['Premium']?.isActive ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subscription successful! 🎉")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Purchase failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final packages = _offerings?.current?.availablePackages ?? [];

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(title: Text("Go Premium")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          final isBest = pkg.identifier.toLowerCase().contains('year');

          return GestureDetector(
            onTap: () => _purchase(pkg),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isBest ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isBest ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBest)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "BEST VALUE",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  SizedBox(height: 10),
                  Text(
                    pkg.storeProduct.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    pkg.storeProduct.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pkg.storeProduct.priceString,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          size: 28, color: Colors.black54),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
