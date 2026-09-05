import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { maid, household }

enum HiringType { monthly, contract, hourly }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final UserRole role;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final bool isVerified;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    required this.role,
    this.location = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.createdAt,
    this.isVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.household,
      ),
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role.name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    UserRole? role,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
