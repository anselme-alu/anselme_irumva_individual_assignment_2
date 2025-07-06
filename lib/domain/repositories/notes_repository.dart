import '../entities/note.dart';

// Abstract repository for notes operations
abstract class NotesRepository {
  Future<List<Note>> fetchNotes(String userId);
  Future<Note> addNote(String userId, String title, String content);
  Future<Note> updateNote(String noteId, String title, String content);
  Future<void> deleteNote(String noteId);
}
