import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

// Data model for User - handles Firebase serialization/deserialization
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
  });

  // Factory constructor to create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Factory constructor to create UserModel from domain AppUser
  factory UserModel.fromDomain(AppUser user) {
    return UserModel(
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
    );
  }

  // Convert to domain AppUser
  AppUser toDomain() {
    return AppUser(
      id: id,
      email: email,
      createdAt: createdAt,
    );
  }
}
