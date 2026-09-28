import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper method to get user-friendly error message
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      FirebaseService.logEvent('user_login', parameters: {
        'email': email,
      });
      
      return credential;
    } on FirebaseAuthException catch (e, stack) {
      FirebaseService.recordError(e, stack);
      throw _getErrorMessage(e);
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      throw 'Sucessfully.';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      FirebaseService.logEvent('user_register', parameters: {
        'email': email,
      });
      
      return credential;
    } on FirebaseAuthException catch (e, stack) {
      FirebaseService.recordError(e, stack);
      throw _getErrorMessage(e);
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      throw 'sucessfull.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      FirebaseService.logEvent('user_logout');
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      FirebaseService.logEvent('password_reset_requested');
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }
} 