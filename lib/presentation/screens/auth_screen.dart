import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event_state.dart';
import '../../core/constants.dart';
import "dart:developer";

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Direct Firebase authentication with immediate error handling
  Future<void> _submitFormDirect() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors above', isError: true);
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      log('AuthScreen: Starting direct Firebase auth for $email');
      
      if (_isSignUp) {
        // Create new account
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        
        if (userCredential.user != null) {
          log('AuthScreen: Account created successfully');
          _showSnackBar(AppConstants.userCreated, isError: false);
          // Trigger BLoC to update app state
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckRequested());
          }
        }
      } else {
        // Sign in to existing account
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        
        if (userCredential.user != null) {
          log('AuthScreen: Sign in successful');
          _showSnackBar(AppConstants.userLoggedIn, isError: false);
          // Trigger BLoC to update app state
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckRequested());
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      log('AuthScreen: FirebaseAuthException - ${e.code}: ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address. Please check your email or create a new account.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please check your password and try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address. Please use a different email or sign in instead.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address (e.g., user@example.com).';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support for assistance.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please wait a few minutes before trying again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password sign-in is not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection and try again.';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message ?? e.code}';
      }
      
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      log('AuthScreen: General error - $e');
      _showSnackBar('An unexpected error occurred. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    log('AuthScreen: Showing snackbar - "$message", isError: $isError');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
        action: isError ? SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Only listen for navigation purposes, not for error handling
          if (state is AuthAuthenticated) {
            log('AuthScreen: User authenticated via BLoC');
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                Icon(
                  Icons.note_add_rounded,
                  size: 80,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture your thoughts, organize your ideas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Auth Form
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSignUp ? 'Create Account' : 'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email address is required';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address\n(e.g., user@example.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitFormDirect(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: _isSignUp ? 'At least 6 characters' : 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              if (_isSignUp && value.length < 6) {
                                return 'Password must be at least 6 characters\nfor account security';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitFormDirect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Toggle Auth Mode
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _formKey.currentState?.reset();
                                ScaffoldMessenger.of(context).clearSnackBars();
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  TextSpan(
                                    text: _isSignUp
                                        ? "Already have an account? "
                                        : "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    text: _isSignUp ? "Sign In" : "Sign Up",
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Help text for sign up
                          if (_isSignUp) ...[
                            const SizedBox(height: 8),
                            Text(
                              'By creating an account, you can save your notes securely in the cloud and access them from any device.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
