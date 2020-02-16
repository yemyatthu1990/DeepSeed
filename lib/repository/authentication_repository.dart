import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> signIn() async {
    return await _auth.signInAnonymously();
  }

  Future<FirebaseUser> getCurrentUserId() async {
    await _auth.currentUser();
  }
}
