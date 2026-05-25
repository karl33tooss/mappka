import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign Up method
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'birthDate': birthDate.toIso8601String(),
          'totalUnlocked': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign Up error Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }

  // Sign In method
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }

  // Sign Out method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
