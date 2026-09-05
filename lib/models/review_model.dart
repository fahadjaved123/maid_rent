import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String maidId;
  final String householdId;
  final String householdName;
  final String householdImage;
  final double rating;
  final String review;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.maidId,
    required this.householdId,
    required this.householdName,
    this.householdImage = '',
    required this.rating,
    this.review = '',
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      maidId: map['maidId'] ?? '',
      householdId: map['householdId'] ?? '',
      householdName: map['householdName'] ?? '',
      householdImage: map['householdImage'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      review: map['review'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'maidId': maidId,
      'householdId': householdId,
      'householdName': householdName,
      'householdImage': householdImage,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
