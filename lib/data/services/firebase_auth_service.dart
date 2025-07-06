import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/error.dart';
import '../../core/constants.dart';

// Firebase authentication service
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    } catch (e) {
      throw AuthFailure('Failed to get current user: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Firebase Auth: Attempting sign in for $email'); // Debug log
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('Firebase Auth: Sign in successful for $email'); // Debug log
        return UserModel.fromFirebaseUser(userCredential.user!);
      } else {
        print('Firebase Auth: User is null after sign in'); // Debug log
        throw const AuthFailure('Sign in failed: User is null');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}'); // Debug log
      final errorMessage = _getAuthErrorMessage(e.code);
      print('Mapped Error Message: $errorMessage'); // Debug log
      throw AuthFailure(errorMessage);
    } catch (e) {
      print('General Error during sign in: $e'); // Debug log
      throw AuthFailure('Sign in failed: ${e.toString()}');
    }
  }

  // Create user with email and password
  Future<UserModel> createUserWithEmailAndPassword(String email, String password) async {
    try {
      print('Firebase Auth: Attempting create user for $email'); // Debug log
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('Firebase Auth: User created successfully for $email'); // Debug log
        final userModel = UserModel.fromFirebaseUser(userCredential.user!);
        
        // Save user data to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userModel.id)
            .set(userModel.toMap());
        
        print('Firebase Auth: User data saved to Firestore'); // Debug log
        return userModel;
      } else {
        print('Firebase Auth: User is null after creation'); // Debug log
        throw const AuthFailure('Account creation failed: User is null');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during creation: ${e.code} - ${e.message}'); // Debug log
      final errorMessage = _getAuthErrorMessage(e.code);
      print('Mapped Error Message: $errorMessage'); // Debug log
      throw AuthFailure(errorMessage);
    } catch (e) {
      print('General Error during account creation: $e'); // Debug log
      throw AuthFailure('Account creation failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthFailure('Sign out failed: ${e.toString()}');
    }
  }

  // Auth state changes stream
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or create a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please use a different email or sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
      case 'invalid-email':
        return 'Please enter a valid email address (e.g., user@example.com).';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please try again.';
      case 'missing-email':
        return 'Please enter your email address.';
      case 'missing-password':
        return 'Please enter your password.';
      case 'email-change-needs-verification':
        return 'Email change requires verification. Please check your email.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      default:
        return 'Authentication failed. Please check your credentials and try again.';
    }
  }
}
