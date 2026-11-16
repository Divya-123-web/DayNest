/// The signed-in user.
/// Later, `uid` will be the Firebase Authentication UID. It is also the id of
/// the user's document in Firestore (users/{uid}), so each user's tasks and
/// notes stay separate from everyone else's.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// The first letter of the name, used in avatars.
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  /// Makes a copy of this user with some fields changed.
  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }
}