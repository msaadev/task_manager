import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/flutter_login.dart';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  late FirebaseAuth _auth;

  static FirebaseAuthService get instance {
    _instance ??= FirebaseAuthService._init();
    return _instance!;
  }

  FirebaseAuthService._init() {
    _auth = FirebaseAuth.instance;
  }


  bool isLogged() {
    return _auth.currentUser != null;
  }

  Future<String?> signIn({
    required LoginData data,
  }) async {
    try {
      var request = await _auth.signInWithEmailAndPassword(
          email: data.name, password: data.password);

      if (request.user != null) {
        return null;
      }

      return 'Bir hata oluştu';
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message;
      } else {
        return 'Bir hata oluştu';
      }
    }
  }

  Future<String?> signUp({
    required SignupData data,
  }) async {
    try {
      var request = await _auth.createUserWithEmailAndPassword(
          email: data.name ?? '', password: data.password ?? '');

      if (request.user != null) {
        return null;
      }
      return 'Bir hata oluştu';
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message;
      } else {
        return 'Bir hata oluştu';
      }
    }
  }

  Future<bool> recoverPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
    return true;
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    return true;
  }
}
