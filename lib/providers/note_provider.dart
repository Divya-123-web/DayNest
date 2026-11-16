import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';

/// Holds all notes and the logic to change them.
/// Screens read from it with context.watch / Consumer and
/// call its methods to add, edit, delete and pin notes.
///
/// The notes live in Cloud Firestore (users/{uid}/notes).
/// This provider listens to them live, so every screen updates
/// when the data changes, even if the change came from another device.
class NoteProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  StreamSubscription<List<NoteModel>>? _subscription;
  String? _uid;
  bool _disposed = false;

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// True until the first list of notes arrives from Firestore.
  bool get isLoading => _isLoading;

  /// The last error message, or null.
  String? get errorMessage => _errorMessage;

  /// All notes (read only, so screens cannot change the list directly).
  List<NoteModel> get notes => List.unmodifiable(_notes);

  int get totalCount => _notes.length;

  int get pinnedCount => _notes.where((n) => n.isPinned).length;

  // ---------------------------------------------------------------------
  // Connecting to the signed-in user
  // ---------------------------------------------------------------------

  /// Called whenever the signed-in user changes.
  /// - A uid starts listening to that user's notes.
  /// - null (logged out) stops listening and clears the notes.
  void setUser(String? uid) {
    // Nothing to do if it is the same user.
    if (uid == _uid) return;

    _subscription?.cancel();
    _subscription = null;
    _uid = uid;
    _notes = [];
    _errorMessage = null;

    if (uid == null) {
      _isLoading = false;
    } else {
      _isLoading = true;
      _subscription = _service.watchNotes(uid).listen(
        (List<NoteModel> notes) {
          _notes = notes;
          _isLoading = false;
          _errorMessage = null;
          _notify();
        },
        onError: (Object error) {
          debugPrint('Notes stream error: $error');
          _isLoading = false;
          _errorMessage = 'Could not load your notes.';
          _notify();
        },
      );
    }

    _notify();
  }

  // ---------------------------------------------------------------------
  // Actions
  //
  // We do not wait for the cloud here. Firestore shows our own change
  // on screen immediately (even offline) and sends it to the cloud when
  // it can. The live stream above then updates the list.
  // ---------------------------------------------------------------------

  /// Adds a new note.
  void addNote(NoteModel note) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.addNote(uid, note), 'Could not save the note.');
  }

  /// Saves the changes of a note.
  void updateNote(NoteModel note) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.updateNote(uid, note), 'Could not update the note.');
  }

  /// Removes a note.
  void deleteNote(String id) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.deleteNote(uid, id), 'Could not delete the note.');
  }

  /// Pins a note, or unpins it.
  void togglePin(String id) {
    final String? uid = _uid;
    if (uid == null) return;

    final int index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final NoteModel changed =
        _notes[index].copyWith(isPinned: !_notes[index].isPinned);

    _run(_service.updateNote(uid, changed), 'Could not update the note.');
  }

  /// Clears the last error message.
  void clearError() {
    _errorMessage = null;
    _notify();
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Runs a Firestore write and records an error if it fails.
  void _run(Future<void> action, String errorText) {
    action.catchError((Object error) {
      debugPrint('Note write error: $error');
      _errorMessage = errorText;
      _notify();
    });
  }

  /// Notifies the screens. It waits a moment first, so it is also safe to
  /// call while Flutter is still building the screen.
  void _notify() {
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}