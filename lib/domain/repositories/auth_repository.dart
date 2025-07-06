import '../entities/user.dart';

// Abstract repository for authentication operations
abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;
}
