import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare_connect/services/firestore.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get user => _auth.currentUser;

  bool _loading = false;
  bool get loading => _loading;

  bool get isLoggedIn => user != null;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _loading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestoreService.saveUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
      );

      _loading = false;
      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
