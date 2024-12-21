import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('isLogin', true);
      await preferences.setString('account', email);
      await preferences.setString('password', password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign out
  Future signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isLogin', false);
    await _firebaseAuth.signOut();
  }

  // Get current user
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }
}