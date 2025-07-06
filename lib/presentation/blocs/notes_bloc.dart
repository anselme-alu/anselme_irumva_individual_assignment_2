import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notes_usecases.dart';
import '../../core/error.dart';
import '../../core/constants.dart';
import 'notes_event_state.dart';

// Notes BLoC for managing notes state
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FetchNotes _fetchNotes;
  final AddNote _addNote;
  final UpdateNote _updateNote;
  final DeleteNote _deleteNote;

  NotesBloc({
    required FetchNotes fetchNotes,
    required AddNote addNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
  })  : _fetchNotes = fetchNotes,
        _addNote = addNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
        super(NotesInitial()) {
    on<FetchNotesRequested>(_onFetchNotesRequested);
    on<AddNoteRequested>(_onAddNoteRequested);
    on<UpdateNoteRequested>(_onUpdateNoteRequested);
    on<DeleteNoteRequested>(_onDeleteNoteRequested);
  }

  Future<void> _onFetchNotesRequested(FetchNotesRequested event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final notes = await _fetchNotes(event.userId);
      emit(NotesLoaded(notes));
    } on ServerFailure catch (e) {
      emit(NotesError(e.message));
    } catch (e) {
      emit(const NotesError(AppConstants.genericError));
    }
  }

  Future<void> _onAddNoteRequested(AddNoteRequested event, Emitter<NotesState> emit) async {
    try {
      await _addNote(event.userId, event.title, event.content);
      // Refetch notes after adding
      final notes = await _fetchNotes(event.userId);
      emit(NoteOperationSuccess(
        message: AppConstants.noteAdded,
        notes: notes,
      ));
    } on ServerFailure catch (e) {
      emit(NotesError(e.message));
    } catch (e) {
      emit(const NotesError(AppConstants.genericError));
    }
  }

  Future<void> _onUpdateNoteRequested(UpdateNoteRequested event, Emitter<NotesState> emit) async {
    try {
      await _updateNote(event.noteId, event.title, event.content);
      // Refetch notes after updating
      final notes = await _fetchNotes(event.userId);
      emit(NoteOperationSuccess(
        message: AppConstants.noteUpdated,
        notes: notes,
      ));
    } on ServerFailure catch (e) {
      emit(NotesError(e.message));
    } catch (e) {
      emit(const NotesError(AppConstants.genericError));
    }
  }

  Future<void> _onDeleteNoteRequested(DeleteNoteRequested event, Emitter<NotesState> emit) async {
    try {
      await _deleteNote(event.noteId);
      // Refetch notes after deleting
      final notes = await _fetchNotes(event.userId);
      emit(NoteOperationSuccess(
        message: AppConstants.noteDeleted,
        notes: notes,
      ));
    } on ServerFailure catch (e) {
      emit(NotesError(e.message));
    } catch (e) {
      emit(const NotesError(AppConstants.genericError));
    }
  }
}
