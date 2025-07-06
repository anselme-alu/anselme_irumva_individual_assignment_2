import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../../core/error.dart';
import '../../core/constants.dart';

// Firebase Firestore service for notes
class FirestoreNotesService {
  final FirebaseFirestore _firestore;

  FirestoreNotesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch all notes for a user
  Future<List<NoteModel>> fetchNotes(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(AppConstants.notesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to fetch notes: ${e.toString()}');
    }
  }

  // Add a new note
  Future<NoteModel> addNote(String userId, String title, String content) async {
    try {
      final now = DateTime.now();
      final noteData = {
        'title': title,
        'content': content,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final DocumentReference docRef = await _firestore
          .collection(AppConstants.notesCollection)
          .add(noteData);

      final DocumentSnapshot doc = await docRef.get();
      return NoteModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to add note: ${e.toString()}');
    }
  }

  // Update an existing note
  Future<NoteModel> updateNote(String noteId, String title, String content) async {
    try {
      final now = DateTime.now();
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.fromDate(now),
      });

      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .get();

      return NoteModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to update note: ${e.toString()}');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore
          .collection(AppConstants.notesCollection)
          .doc(noteId)
          .delete();
    } catch (e) {
      throw ServerFailure('Failed to delete note: ${e.toString()}');
    }
  }
}
