import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/dependency_injection.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/auth_event_state.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/notes_screen.dart';
import 'core/constants.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    log('Firebase initialized successfully');
  } catch (e) {
    log('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: DependencyInjection.providers,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Check authentication on app start
        if (state is AuthInitial) {
          context.read<AuthBloc>().add(AuthCheckRequested());
          return const SplashScreen();
        }

        // Show loading screen while checking auth
        if (state is AuthLoading) {
          return const SplashScreen();
        }

        // Show notes screen if authenticated
        if (state is AuthAuthenticated) {
          return const NotesScreen();
        }

        // Show auth screen if not authenticated
        return const AuthScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Capture your thoughts, organize your ideas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:  Colors.white.withAlpha(230),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
