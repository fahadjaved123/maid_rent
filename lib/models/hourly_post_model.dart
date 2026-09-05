import 'package:cloud_firestore/cloud_firestore.dart';

enum PostStatus { open, assigned, completed, cancelled }

class HourlyPostModel {
  final String id;
  final String householdId;
  final String householdName;
  final String householdImage;
  final String title;
  final String description;
  final List<String> services;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int hours;
  final double budget;
  final String address;
  final String location;
  final double latitude;
  final double longitude;
  final PostStatus status;
  final List<String> applicantIds;
  final String? assignedMaidId;
  final DateTime createdAt;

  const HourlyPostModel({
    required this.id,
    required this.householdId,
    required this.householdName,
    this.householdImage = '',
    required this.title,
    this.description = '',
    this.services = const [],
    required this.date,
    this.startTime = '',
    this.endTime = '',
    this.hours = 0,
    this.budget = 0.0,
    this.address = '',
    this.location = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.status = PostStatus.open,
    this.applicantIds = const [],
    this.assignedMaidId,
    required this.createdAt,
  });

  factory HourlyPostModel.fromMap(Map<String, dynamic> map) {
    return HourlyPostModel(
      id: map['id'] ?? '',
      householdId: map['householdId'] ?? '',
      householdName: map['householdName'] ?? '',
      householdImage: map['householdImage'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      hours: map['hours'] ?? 0,
      budget: (map['budget'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: PostStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PostStatus.open,
      ),
      applicantIds: List<String>.from(map['applicantIds'] ?? []),
      assignedMaidId: map['assignedMaidId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdId': householdId,
      'householdName': householdName,
      'householdImage': householdImage,
      'title': title,
      'description': description,
      'services': services,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'hours': hours,
      'budget': budget,
      'address': address,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'applicantIds': applicantIds,
      'assignedMaidId': assignedMaidId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HourlyPostModel copyWith({
    String? id,
    String? householdId,
    String? householdName,
    String? householdImage,
    String? title,
    String? description,
    List<String>? services,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? hours,
    double? budget,
    String? address,
    String? location,
    double? latitude,
    double? longitude,
    PostStatus? status,
    List<String>? applicantIds,
    String? assignedMaidId,
    DateTime? createdAt,
  }) {
    return HourlyPostModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      householdName: householdName ?? this.householdName,
      householdImage: householdImage ?? this.householdImage,
      title: title ?? this.title,
      description: description ?? this.description,
      services: services ?? this.services,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hours: hours ?? this.hours,
      budget: budget ?? this.budget,
      address: address ?? this.address,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      applicantIds: applicantIds ?? this.applicantIds,
      assignedMaidId: assignedMaidId ?? this.assignedMaidId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
