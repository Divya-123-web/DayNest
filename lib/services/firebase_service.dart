import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One place that knows where everything lives in Firebase.
///
/// Firestore structure:
///   users/{uid}              the user's profile (name, email)
///   users/{uid}/tasks/{id}   each task
///   users/{uid}/notes/{id}   each note
///
/// {uid} is the Firebase Authentication user id, so every person's
/// data stays under their own id.
class FirebaseService {
  FirebaseService._();

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Turns on offline persistence.
  /// Call this once in main(), right after Firebase.initializeApp().
  /// Changes made offline are saved on the phone and sent to the cloud
  /// when the connection comes back.
  static void configureFirestore() {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// The profile document of one user.
  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }

  /// All tasks of one user.
  static CollectionReference<Map<String, dynamic>> tasksCollection(
    String uid,
  ) {
    return userDoc(uid).collection('tasks');
  }

  /// All notes of one user.
  static CollectionReference<Map<String, dynamic>> notesCollection(
    String uid,
  ) {
    return userDoc(uid).collection('notes');
  }
}