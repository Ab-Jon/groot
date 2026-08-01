import 'package:flutter/material.dart';
import 'package:groot/screens/project%20screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // Add this import for RevenueCat
import 'package:groot/screens/subscription_ui.dart';
import '../humanitarian/humanitarian_dashboard.dart';
import '../registration/group_register.dart';
import '../registration/register_screen.dart';
import 'humanitarian_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool hasFullAccess = false;
  bool hasRestrictedAccess = false;

  final Color myColor = const Color(0xff102FCE);

  @override
  void initState() {
    super.initState();
    _checkEntitlements();
  }

  Future<void> _checkEntitlements() async {
    try {
      // Fetch customer info from RevenueCat
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      // Check if the user has access to the entitlement that grants everything
      hasFullAccess = customerInfo.entitlements.active.containsKey('Premium');

      // Check if the user has access to the entitlement that restricts access to certain screens
      hasRestrictedAccess = customerInfo.entitlements.active.containsKey('Regular');

      setState(() {});
    } catch (e) {
      print('Error fetching entitlements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              width: double.maxFinite,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/REGISTER.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.green, style: BorderStyle.solid),
                  ),
                  onPressed: () {
                    showModalBottomSheet(context: context, builder: (BuildContext context) {
                      return Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Register as Individual', style: TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.people),
                            title: const Text('Register as Group', style: TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupRegister()));
                            },
                          ),
                        ],
                      );
                    });
                  },
                  child: Text('', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 25)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              width: double.maxFinite,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/HUMANITARIAN.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.green, style: BorderStyle.solid),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => HumanitarianDashboard()));
                  },
                  child: Text('', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 25)),
                ),
              ),
            ),
            Container(
              height: 250,
              width: double.maxFinite,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/POLITICAL.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.green, style: BorderStyle.solid),
                  ),
                  // Conditional navigation based on entitlement
                  onPressed: hasFullAccess
                      ? () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProjectScreen()));
                  }
                      : null, // Disable button if the user doesn't have full access
                  child: Text('', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
