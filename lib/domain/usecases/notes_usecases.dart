import '../entities/note.dart';
import '../repositories/notes_repository.dart';

// Use case for fetching notes
class FetchNotes {
  final NotesRepository repository;

  FetchNotes(this.repository);

  Future<List<Note>> call(String userId) async {
    return await repository.fetchNotes(userId);
  }
}

// Use case for adding a note
class AddNote {
  final NotesRepository repository;

  AddNote(this.repository);

  Future<Note> call(String userId, String title, String content) async {
    return await repository.addNote(userId, title, content);
  }
}

// Use case for updating a note
class UpdateNote {
  final NotesRepository repository;

  UpdateNote(this.repository);

  Future<Note> call(String noteId, String title, String content) async {
    return await repository.updateNote(noteId, title, content);
  }
}

// Use case for deleting a note
class DeleteNote {
  final NotesRepository repository;

  DeleteNote(this.repository);

  Future<void> call(String noteId) async {
    return await repository.deleteNote(noteId);
  }
}
