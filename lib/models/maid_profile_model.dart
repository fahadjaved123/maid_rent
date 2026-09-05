import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maid_rent/models/service_category.dart';

class MaidProfileModel {
  final String uid;
  final String name;
  final String profileImage;
  final String bio;
  final List<ServiceCategory> categories;
  final List<String> specializedServices;
  final double hourlyRate;
  final double monthlyRate;
  final double rating;
  final int totalReviews;
  final int completedJobs;
  final String location;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final bool acceptsHourly;
  final bool acceptsMonthly;
  final bool acceptsContract;
  final bool isVerified;
  final List<String> workingDays;
  final String workStartTime;
  final String workEndTime;
  final int experienceYears;
  final List<String> languages;
  final DateTime createdAt;

  const MaidProfileModel({
    required this.uid,
    required this.name,
    this.profileImage = '',
    this.bio = '',
    this.categories = const [],
    this.specializedServices = const [],
    this.hourlyRate = 0.0,
    this.monthlyRate = 0.0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.completedJobs = 0,
    this.location = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isAvailable = true,
    this.acceptsHourly = true,
    this.acceptsMonthly = true,
    this.acceptsContract = false,
    this.isVerified = false,
    this.workingDays = const [],
    this.workStartTime = '08:00',
    this.workEndTime = '18:00',
    this.experienceYears = 0,
    this.languages = const [],
    required this.createdAt,
  });

  factory MaidProfileModel.fromMap(Map<String, dynamic> map) {
    return MaidProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'] ?? '',
      bio: map['bio'] ?? '',
      categories: (map['categories'] as List?)
              ?.map((e) => ServiceCategory.values.firstWhere(
                    (cat) => cat.name == e,
                    orElse: () => ServiceCategory.cleaning,
                  ))
              .toList() ?? [],
      specializedServices: List<String>.from(map['specializedServices'] ?? []),
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      monthlyRate: (map['monthlyRate'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      completedJobs: map['completedJobs'] ?? 0,
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      acceptsHourly: map['acceptsHourly'] ?? true,
      acceptsMonthly: map['acceptsMonthly'] ?? true,
      acceptsContract: map['acceptsContract'] ?? false,
      isVerified: map['isVerified'] ?? false,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workStartTime: map['workStartTime'] ?? '08:00',
      workEndTime: map['workEndTime'] ?? '18:00',
      experienceYears: map['experienceYears'] ?? 0,
      languages: List<String>.from(map['languages'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profileImage': profileImage,
      'bio': bio,
      'categories': categories.map((e) => e.name).toList(),
      'specializedServices': specializedServices,
      'hourlyRate': hourlyRate,
      'monthlyRate': monthlyRate,
      'rating': rating,
      'totalReviews': totalReviews,
      'completedJobs': completedJobs,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'acceptsHourly': acceptsHourly,
      'acceptsMonthly': acceptsMonthly,
      'acceptsContract': acceptsContract,
      'isVerified': isVerified,
      'workingDays': workingDays,
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
      'experienceYears': experienceYears,
      'languages': languages,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MaidProfileModel copyWith({
    String? uid,
    String? name,
    String? profileImage,
    String? bio,
    List<ServiceCategory>? categories,
    List<String>? specializedServices,
    double? hourlyRate,
    double? monthlyRate,
    double? rating,
    int? totalReviews,
    int? completedJobs,
    String? location,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    bool? acceptsHourly,
    bool? acceptsMonthly,
    bool? acceptsContract,
    bool? isVerified,
    List<String> ?workingDays,
    String? workStartTime,
    String? workEndTime,
    int? experienceYears,
    List<String>? languages,
    DateTime? createdAt,
  }) {
    return MaidProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      categories: categories ?? this.categories,
      specializedServices: specializedServices ?? this.specializedServices,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      completedJobs: completedJobs ?? this.completedJobs,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      acceptsHourly: acceptsHourly ?? this.acceptsHourly,
      acceptsMonthly: acceptsMonthly ?? this.acceptsMonthly,
      acceptsContract: acceptsContract ?? this.acceptsContract,
      isVerified: isVerified ?? this.isVerified,
      workingDays: workingDays ?? this.workingDays,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      experienceYears: experienceYears ?? this.experienceYears,
      languages: languages ?? this.languages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
