import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/firebase_auth_service.dart';
import '../data/services/firestore_notes_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/notes_repository_impl.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/notes_usecases.dart';
import '../presentation/blocs/auth_bloc.dart';
import '../presentation/blocs/notes_bloc.dart';

// Dependency injection setup
class DependencyInjection {
  // Services
  static final FirebaseAuthService _authService = FirebaseAuthService();
  static final FirestoreNotesService _notesService = FirestoreNotesService();

  // Repositories
  static final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(_authService);
  static final NotesRepositoryImpl _notesRepository = NotesRepositoryImpl(_notesService);

  // Auth Use Cases
  static final GetCurrentUser _getCurrentUser = GetCurrentUser(_authRepository);
  static final SignInWithEmailAndPassword _signInWithEmailAndPassword = 
      SignInWithEmailAndPassword(_authRepository);
  static final CreateUserWithEmailAndPassword _createUserWithEmailAndPassword = 
      CreateUserWithEmailAndPassword(_authRepository);
  static final SignOut _signOut = SignOut(_authRepository);
  static final GetAuthStateChanges _getAuthStateChanges = GetAuthStateChanges(_authRepository);

  // Notes Use Cases
  static final FetchNotes _fetchNotes = FetchNotes(_notesRepository);
  static final AddNote _addNote = AddNote(_notesRepository);
  static final UpdateNote _updateNote = UpdateNote(_notesRepository);
  static final DeleteNote _deleteNote = DeleteNote(_notesRepository);

  // BLoCs
  static AuthBloc get authBloc => AuthBloc(
        getCurrentUser: _getCurrentUser,
        signInWithEmailAndPassword: _signInWithEmailAndPassword,
        createUserWithEmailAndPassword: _createUserWithEmailAndPassword,
        signOut: _signOut,
        getAuthStateChanges: _getAuthStateChanges,
      );

  static NotesBloc get notesBloc => NotesBloc(
        fetchNotes: _fetchNotes,
        addNote: _addNote,
        updateNote: _updateNote,
        deleteNote: _deleteNote,
      );

  // Provide all BLoCs
  static List<BlocProvider> get providers => [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<NotesBloc>(create: (_) => notesBloc),
      ];
}
