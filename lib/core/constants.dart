// App constants
class AppConstants {
  static const String appName = 'Notes App';
  static const String emptyNotesMessage = 'Nothing here yet—tap ➕ to add a note.';
  
  // Firebase Collections
  static const String notesCollection = 'notes';
  static const String usersCollection = 'users';
  
  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success messages
  static const String noteAdded = 'Note added successfully';
  static const String noteUpdated = 'Note updated successfully';
  static const String noteDeleted = 'Note deleted successfully';
  static const String userCreated = 'Account created successfully';
  static const String userLoggedIn = 'Logged in successfully';
}
