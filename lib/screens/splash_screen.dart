import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groot/authenticate/sign_in.dart';
import 'package:groot/screens/agreement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:groot/screens/home_screen.dart'; // Assuming you have a home screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  Future<void> checkAgreementAndAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool agreementAccepted = prefs.getBool('agreementAccepted') ?? false;

    // Check if user is signed in
    User? user = FirebaseAuth.instance.currentUser;

    if (agreementAccepted) {
      if (user != null) {
        // User is signed in and agreement is accepted, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Home screen if signed in
        );
      } else {
        // If user is not signed in, navigate to SignIn screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()), // Sign in screen
        );
      }
    } else {
      // Navigate to Agreement screen if agreement is not accepted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AgreementScreen()), // Agreement screen
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkAgreementAndAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/g_root.jpg'), // Your splash image
      ),
    );
  }
}
