import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ REGISTER - Email & Password
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    }
  }

  // ✅ LOGIN - Email & Password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ✅ CURRENT USER
  User? get currentUser => _auth.currentUser;

  // ✅ USER INFO
  String? get userEmail => _auth.currentUser?.email;
  String? get userName => _auth.currentUser?.displayName;
}