import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../services/firestore_notes_service.dart';

// Implementation of NotesRepository using Firestore
class NotesRepositoryImpl implements NotesRepository {
  final FirestoreNotesService _notesService;

  NotesRepositoryImpl(this._notesService);

  @override
  Future<List<Note>> fetchNotes(String userId) async {
    final noteModels = await _notesService.fetchNotes(userId);
    return noteModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<Note> addNote(String userId, String title, String content) async {
    final noteModel = await _notesService.addNote(userId, title, content);
    return noteModel.toDomain();
  }

  @override
  Future<Note> updateNote(String noteId, String title, String content) async {
    final noteModel = await _notesService.updateNote(noteId, title, content);
    return noteModel.toDomain();
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _notesService.deleteNote(noteId);
  }
}
