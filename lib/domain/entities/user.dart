// User entity - represents a user in the domain layer
class AppUser {
  final String id;
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  AppUser copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, createdAt: $createdAt)';
  }
}
