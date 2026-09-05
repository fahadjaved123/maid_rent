import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus { pending, approved, rejected }

class VerificationRequestModel {
  final String id;
  final String uid;
  final String cnicNumber;
  final String frontImageUrl;
  final String backImageUrl;
  final VerificationStatus status;
  final DateTime submittedAt;
  final String? adminNote;

  const VerificationRequestModel({
    required this.id,
    required this.uid,
    required this.cnicNumber,
    required this.frontImageUrl,
    required this.backImageUrl,
    this.status = VerificationStatus.pending,
    required this.submittedAt,
    this.adminNote,
  });

  factory VerificationRequestModel.fromMap(Map<String, dynamic> map) {
    return VerificationRequestModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      cnicNumber: map['cnicNumber'] ?? '',
      frontImageUrl: map['frontImageUrl'] ?? '',
      backImageUrl: map['backImageUrl'] ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VerificationStatus.pending,
      ),
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminNote: map['adminNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'cnicNumber': cnicNumber,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'status': status.name,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'adminNote': adminNote,
    };
  }

  VerificationRequestModel copyWith({
    String? id,
    String? uid,
    String? cnicNumber,
    String? frontImageUrl,
    String? backImageUrl,
    VerificationStatus? status,
    DateTime? submittedAt,
    String? adminNote,
  }) {
    return VerificationRequestModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}
