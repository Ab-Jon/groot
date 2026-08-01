import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String getCurrentUserID(){
    User? emailUser = _auth.currentUser;
    return emailUser?.uid ?? '';

  }
}

class FirebaseHelper{
 static final vinRecords = FirebaseFirestore.instance.collection('vinRecords');
}

