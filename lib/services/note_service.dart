import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import 'firebase_service.dart';

/// Reads and writes notes in Cloud Firestore.
/// Path: users/{uid}/notes/{noteId}
/// The NoteProvider uses this class; screens never call it directly.
class NoteService {
  /// A live stream of the user's notes.
  /// It sends a new list every time anything changes: when this phone
  /// changes a note, or when another device does.
  Stream<List<NoteModel>> watchNotes(String uid) {
    return FirebaseService.notesCollection(uid).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        return snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
            .toList();
      },
    );
  }

  /// Saves a new note. The note id is used as the document id.
  Future<void> addNote(String uid, NoteModel note) {
    return FirebaseService.notesCollection(uid).doc(note.id).set(note.toMap());
  }

  /// Saves the changes of an existing note.
  Future<void> updateNote(String uid, NoteModel note) {
    return FirebaseService.notesCollection(uid).doc(note.id).set(note.toMap());
  }

  /// Deletes a note.
  Future<void> deleteNote(String uid, String noteId) {
    return FirebaseService.notesCollection(uid).doc(noteId).delete();
  }
}