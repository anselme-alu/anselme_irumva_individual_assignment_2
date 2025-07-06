import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// Use case for signing in with email and password
class SignInWithEmailAndPassword {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  Future<AppUser> call(String email, String password) async {
    return await repository.signInWithEmailAndPassword(email, password);
  }
}

// Use case for creating user with email and password
class CreateUserWithEmailAndPassword {
  final AuthRepository repository;

  CreateUserWithEmailAndPassword(this.repository);

  Future<AppUser> call(String email, String password) async {
    return await repository.createUserWithEmailAndPassword(email, password);
  }
}

// Use case for getting current user
class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<AppUser?> call() async {
    return await repository.getCurrentUser();
  }
}

// Use case for signing out
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}

// Use case for getting auth state changes
class GetAuthStateChanges {
  final AuthRepository repository;

  GetAuthStateChanges(this.repository);

  Stream<AppUser?> call() {
    return repository.authStateChanges;
  }
}
