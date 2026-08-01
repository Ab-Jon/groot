import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groot/screens/chat_screen.dart';
import 'package:groot/screens/tab_screen.dart';
import 'package:groot/screens/welcome_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../authenticate/sign_in.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    print("Could not launch $url");
  }
}

void logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut(); // Sign out the user
  await Purchases.logOut(); //logs the user out of revenue cat too

  // Navigate to the login screen and clear the back stack
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => SignIn()),
        (route) => false, // This removes all previous routes
  );
}


void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              logout(context); // Close dialog// Perform logout
            },
            child: Text("Logout"),
          ),
        ],
      );
    },
  );
}

class _HomeScreenState extends State<HomeScreen> {

  //remove const (reminder)
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const WelcomeScreen(),
    const TabulateScreen(),
    const ChatScreen(),
    const ContactScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          color: Colors.white,
            onPressed: (){
              _confirmLogout(context);
            },
            icon: const Icon(Icons.logout)),
        backgroundColor: Colors.green,
        title: const Text('G-ROOT', style: TextStyle(color: Colors.white),),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
              onPressed: () => _launchURL("https://excellentsolutionproviders.org/privacy-policy"),
              child: Text('Privacy Policy', style: TextStyle(color: Colors.white),))
          ]
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Colors.green,
            primaryColor: Colors.white),
        child: BottomNavigationBar(
            selectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (int index){
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.contact_page),
                  label: 'Contact')
            ]
        ),),
    );
  }
}

// New addition: A chat feature is added in the bottom navigation