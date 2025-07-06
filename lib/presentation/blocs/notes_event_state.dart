import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

// Notes Events
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class FetchNotesRequested extends NotesEvent {
  final String userId;

  const FetchNotesRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddNoteRequested extends NotesEvent {
  final String userId;
  final String title;
  final String content;

  const AddNoteRequested({
    required this.userId,
    required this.title,
    required this.content,
  });

  @override
  List<Object> get props => [userId, title, content];
}

class UpdateNoteRequested extends NotesEvent {
  final String noteId;
  final String title;
  final String content;
  final String userId; // Add userId for refetching

  const UpdateNoteRequested({
    required this.noteId,
    required this.title,
    required this.content,
    required this.userId,
  });

  @override
  List<Object> get props => [noteId, title, content, userId];
}

class DeleteNoteRequested extends NotesEvent {
  final String noteId;
  final String userId; // Add userId for refetching

  const DeleteNoteRequested({
    required this.noteId,
    required this.userId,
  });

  @override
  List<Object> get props => [noteId, userId];
}

// Notes States
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object> get props => [message];
}

class NoteOperationSuccess extends NotesState {
  final String message;
  final List<Note> notes;

  const NoteOperationSuccess({
    required this.message,
    required this.notes,
  });

  @override
  List<Object> get props => [message, notes];
}
