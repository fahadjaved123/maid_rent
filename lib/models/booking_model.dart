import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maid_rent/models/user_model.dart';

enum BookingStatus { pending, accepted, rejected, inProgress, completed, cancelled }

enum PaymentMethod { cash, easypaisa, jazzcash }

class BookingModel {
  final String id;
  final String maidId;
  final String? maidName;
  final String? maidImage;
  final String householdId;
  final String? householdName;
  final String? householdImage;
  final HiringType hiringType;
  final BookingStatus status;
  final List<String> services;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int? totalHours;
  final double totalPrice;
  final double hourlyRate;
  final String address;
  final String? notes;
  final double? rating;
  final String? review;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.maidId,
    this.maidName,
    this.maidImage,
    required this.householdId,
    this.householdName,
    this.householdImage,
    required this.hiringType,
    this.status = BookingStatus.pending,
    this.services = const [],
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.totalHours,
    this.totalPrice = 0.0,
    this.hourlyRate = 0.0,
    this.address = '',
    this.notes,
    this.rating,
    this.review,
    this.paymentMethod = PaymentMethod.cash,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      maidId: map['maidId'] ?? '',
      maidName: map['maidName'],
      maidImage: map['maidImage'],
      householdId: map['householdId'] ?? '',
      householdName: map['householdName'],
      householdImage: map['householdImage'],
      hiringType: HiringType.values.firstWhere(
        (e) => e.name == map['hiringType'],
        orElse: () => HiringType.hourly,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      services: List<String>.from(map['services'] ?? []),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      startTime: map['startTime'],
      endTime: map['endTime'],
      totalHours: map['totalHours'],
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      notes: map['notes'],
      rating: (map['rating'] as num?)?.toDouble(),
      review: map['review'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maidId': maidId,
      'maidName': maidName,
      'maidImage': maidImage,
      'householdId': householdId,
      'householdName': householdName,
      'householdImage': householdImage,
      'hiringType': hiringType.name,
      'status': status.name,
      'services': services,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'startTime': startTime,
      'endTime': endTime,
      'totalHours': totalHours,
      'totalPrice': totalPrice,
      'hourlyRate': hourlyRate,
      'address': address,
      'notes': notes,
      'rating': rating,
      'review': review,
      'paymentMethod': paymentMethod.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? maidId,
    String? maidName,
    String? maidImage,
    String? householdId,
    String? householdName,
    String? householdImage,
    HiringType? hiringType,
    BookingStatus? status,
    List<String>? services,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    int? totalHours,
    double? totalPrice,
    double? hourlyRate,
    String? address,
    String? notes,
    double? rating,
    String? review,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      maidId: maidId ?? this.maidId,
      maidName: maidName ?? this.maidName,
      maidImage: maidImage ?? this.maidImage,
      householdId: householdId ?? this.householdId,
      householdName: householdName ?? this.householdName,
      householdImage: householdImage ?? this.householdImage,
      hiringType: hiringType ?? this.hiringType,
      status: status ?? this.status,
      services: services ?? this.services,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      totalPrice: totalPrice ?? this.totalPrice,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
