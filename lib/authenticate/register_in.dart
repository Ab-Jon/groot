import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groot/authenticate/sign_in.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  Color myColor = const Color(0xff102FCE);
  bool _isLoading = false;

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
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    email = value;
                  },
                  decoration: const InputDecoration(
                      hintText: 'E-mail',
                      border: OutlineInputBorder()
                  )
              ),
              const SizedBox (height: 10,),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value){
                  password = value;
                },
                decoration: const InputDecoration(
                    hintText: 'password',
                    border: OutlineInputBorder()
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _isLoading
                      ? null
                      :() async {
                    setState(() {
                      _isLoading = true;
                    });
                    try{
                      final  newUser = await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password);
                      if (newUser != null){
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) => const SignIn()));
                      } } catch(e){
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2,),
                  )
                  : const Text('Create', style: TextStyle(color: Colors.white)))
            ],
          ),
        ),
      ),
    );
  }
}
