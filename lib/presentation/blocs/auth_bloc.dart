import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../core/error.dart';
import 'auth_event_state.dart';

// Auth BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignInWithEmailAndPassword _signInWithEmailAndPassword;
  final CreateUserWithEmailAndPassword _createUserWithEmailAndPassword;
  final SignOut _signOut;
  final GetAuthStateChanges _getAuthStateChanges;

  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required SignInWithEmailAndPassword signInWithEmailAndPassword,
    required CreateUserWithEmailAndPassword createUserWithEmailAndPassword,
    required SignOut signOut,
    required GetAuthStateChanges getAuthStateChanges,
  })  : _getCurrentUser = getCurrentUser,
        _signInWithEmailAndPassword = signInWithEmailAndPassword,
        _createUserWithEmailAndPassword = createUserWithEmailAndPassword,
        _signOut = signOut,
        _getAuthStateChanges = getAuthStateChanges,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Don't auto-listen to auth state changes to avoid overriding error states
    // We'll handle auth state manually in each method
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final user = await _getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    try {
      print('AuthBloc: Starting sign in process for ${event.email}'); // Debug log
      emit(AuthLoading());
      final user = await _signInWithEmailAndPassword(event.email, event.password);
      print('AuthBloc: Sign in successful, emitting AuthAuthenticated'); // Debug log
      // Only emit authenticated state if sign in was successful
      emit(AuthAuthenticated(user));
    } on AuthFailure catch (e) {
      print('AuthBloc: AuthFailure caught: ${e.message}'); // Debug log
      // Emit error state and stay on current screen to show error
      emit(AuthError(e.message));
      // After showing error, return to unauthenticated state
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          print('AuthBloc: Returning to unauthenticated state after error'); // Debug log
          emit(AuthUnauthenticated());
        }
      });
    } catch (e) {
      print('AuthBloc: General error caught: $e'); // Debug log
      emit(AuthError('An unexpected error occurred. Please try again.'));
      // After showing error, return to unauthenticated state
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          print('AuthBloc: Returning to unauthenticated state after general error'); // Debug log
          emit(AuthUnauthenticated());
        }
      });
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final user = await _createUserWithEmailAndPassword(event.email, event.password);
      // Only emit authenticated state if sign up was successful
      emit(AuthAuthenticated(user));
    } on AuthFailure catch (e) {
      // Emit error state and stay on current screen to show error
      emit(AuthError(e.message));
      // After showing error, return to unauthenticated state
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(AuthUnauthenticated());
      });
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
      // After showing error, return to unauthenticated state
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) emit(AuthUnauthenticated());
      });
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
