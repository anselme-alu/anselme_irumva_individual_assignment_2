# Notes App - Individual Assignment 2

A Flutter notes application with Firebase authentication and Firestore database integration.

## Features

- **Authentication**: Email/password signup and login using Firebase Auth
- **CRUD Operations**: Create, Read, Update, Delete notes
- **Clean Architecture**: Separated presentation, domain, and data layers
- **State Management**: BLoC pattern for managing application state
- **Real-time Data**: Notes are stored and retrieved from Firestore
- **User Experience**: Material Design UI with loading states and error handling

## Architecture

The app follows Clean Architecture principles with the following layers:

### Domain Layer
- **Entities**: Note and User models
- **Repositories**: Abstract contracts for data operations
- **Use Cases**: Business logic for auth and notes operations

### Data Layer
- **Models**: Data models with Firebase serialization
- **Services**: Firebase Auth and Firestore services
- **Repository Implementations**: Concrete implementations of domain contracts

### Presentation Layer
- **BLoCs**: State management using flutter_bloc
- **Screens**: Auth screen and Notes screen
- **Widgets**: Reusable UI components

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.7.2)
- Firebase project setup
- Android Studio or VS Code

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication and Firestore

2. **Configure Firebase Authentication**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Email/Password" provider

3. **Configure Firestore Database**
   - In Firebase Console, go to Firestore Database
   - Create database in test mode
   - Set up the following security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their own notes
    match /notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

4. **Add Firebase Configuration Files**
   - Download `google-services.json` for Android
   - Place it in `android/app/google-services.json`

### Installation

1. **Clone and navigate to the project**
```bash
cd anselme_irumva_individual_assignment_2
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## CRUD Operations Implementation

### Create (Add Note)
```dart
await addNote(userId, title, content);
```

### Read (Fetch Notes)
```dart
await fetchNotes(userId);
```

### Update (Edit Note)
```dart
await updateNote(noteId, title, content);
```

### Delete (Remove Note)
```dart
await deleteNote(noteId);
```

## Key Dependencies

- **firebase_core**: Firebase SDK initialization
- **firebase_auth**: Authentication services
- **cloud_firestore**: Firestore database
- **flutter_bloc**: State management
- **equatable**: Value equality for BLoC states/events
- **google_fonts**: Custom typography

## State Management

The app uses BLoC pattern with two main BLoCs:

### AuthBloc
Manages authentication state with events:
- `AuthCheckRequested`: Check current auth status
- `SignInRequested`: Sign in with email/password
- `SignUpRequested`: Create new account
- `SignOutRequested`: Sign out user

### NotesBloc
Manages notes state with events:
- `FetchNotesRequested`: Load user's notes
- `AddNoteRequested`: Create new note
- `UpdateNoteRequested`: Edit existing note
- `DeleteNoteRequested`: Delete note

## Error Handling

- **Comprehensive Authentication Errors**: Handles all Firebase Auth error codes with user-friendly messages
- **Form Validation**: Client-side validation for email format, password strength, and required fields
- **Network Error Handling**: Graceful handling of connection issues
- **Enhanced SnackBars**: 
  - ✅ Success notifications with green color and checkmark icon
  - ❌ Error notifications with red color and error icon
  - Dismiss button for error messages
  - Auto-clear previous notifications
  - Extended duration for error messages (4 seconds vs 2 seconds for success)
- **User-Friendly Messages**: No technical jargon, clear actionable guidance
- **Loading States**: Visual feedback during all operations
- **Validation Feedback**: Real-time form validation with helpful hints

## UI Features

- **Material Design 3**: Modern UI components
- **Custom Fonts**: Google Fonts (Poppins)
- **Responsive Design**: Grid layout for notes
- **Color-coded Notes**: Different colored note cards
- **Empty State**: Helpful message when no notes exist
- **Confirmation Dialogs**: For destructive actions

## Testing

Run the analyzer to check code quality:
```bash
flutter analyze
```

## Demo Video Requirements

The demo video should show:
1. Creating a new user account
2. Logging in with created credentials
3. Empty state with "Nothing here yet—tap ➕ to add a note" message
4. Adding multiple notes
5. Editing existing notes
6. Deleting notes
7. Firebase Console showing the data changes
8. Face and voice clearly visible during demonstration

## Author

**Anselme Irumva**  
ALU - Mobile Application Development  
Individual Assignment 2
