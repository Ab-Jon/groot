import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groot/authenticate/register_in.dart';
import 'package:groot/screens/forgot_password.dart';
import 'package:groot/screens/subscription_ui.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../screens/welcome_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isLoaded = false;
  String email = '';
  String password = '';

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  final List<String> roleBased = ['Principal', 'Up-line', 'Group'];
  String? selectedValue;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscure_text = true;

  void _toggleVisibility() {
    setState(() {
      _obscure_text = !_obscure_text;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    if (selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a role!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailCont.text.trim(),
        password: passwordCont.text.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Link RevenueCat to Firebase UID
       // await Purchases.logIn(user.uid);

        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          final userData = docSnapshot.data();

          if (userData != null && userData.containsKey('Role')) {
            String existingRole = userData['Role'];

            if (existingRole == selectedValue) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Sign-in successful!"),
                    backgroundColor: Colors.green),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => WelcomeScreen()),//Replace Premium Pricing screen with home screen
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('This User is assigned a role already'),
                    backgroundColor: Colors.red),
              );
            }
          } else {
            await userDoc.set({'Role': selectedValue}, SetOptions(merge: true));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Sign-in successful!"),
                  backgroundColor: Colors.green),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PremiumPricingScreen()),
            );
          }
        } else {
          await userDoc.set({'Role': selectedValue});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Sign-in successful!"),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PremiumPricingScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          _errorMessage = 'Incorrect password';
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          _errorMessage = 'No user found with this email';
        });
      } else {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Poor Network connection. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: emailCont,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  hintText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCont,
                obscureText: _obscure_text,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(
                    hintText: 'password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: _toggleVisibility,
                        icon: Icon(
                          _obscure_text
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ))),
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Select a role'),
                value: selectedValue,
                items: roleBased.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedValue = newValue;
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          _signIn();
                        } catch (e) {}
                      },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign In',
                        style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Register()),
                  ),
                  child: Text(
                    'Create account',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const ForgotPasswordScreen()),
                  ),
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New addition: Implement show/hide feature for password and help users in a case of forgotten password.