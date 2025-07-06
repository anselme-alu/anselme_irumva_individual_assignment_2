import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AppUser?> getCurrentUser() async {
    final userModel = await _authService.getCurrentUser();
    return userModel?.toDomain();
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final userModel = await _authService.signInWithEmailAndPassword(email, password);
    return userModel.toDomain();
  }

  @override
  Future<AppUser> createUserWithEmailAndPassword(String email, String password) async {
    final userModel = await _authService.createUserWithEmailAndPassword(email, password);
    return userModel.toDomain();
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.map((userModel) => userModel?.toDomain());
  }
}
