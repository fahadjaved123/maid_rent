import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maid_rent/config/constants.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/review_model.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/models/verification_request_model.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────── USER ────────────────

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  // ──────────────── MAID PROFILE ────────────────

  Future<void> createMaidProfile(MaidProfileModel profile) async {
    await _db
        .collection(AppConstants.maidProfilesCollection)
        .doc(profile.uid)
        .set(profile.toMap());
  }

  Future<MaidProfileModel?> getMaidProfile(String uid) async {
    final doc = await _db
        .collection(AppConstants.maidProfilesCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return MaidProfileModel.fromMap(doc.data()!);
  }

  Future<void> updateMaidProfile(
      String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.maidProfilesCollection)
        .doc(uid)
        .update(data);
  }

  Stream<List<MaidProfileModel>> getAvailableMaids() {
    return _db
        .collection(AppConstants.maidProfilesCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaidProfileModel.fromMap(doc.data()))
            .toList());
  }

  Future<List<MaidProfileModel>> searchMaids({
    String? service,
    double? minRating,
    double? maxHourlyRate,
    bool? acceptsHourly,
    bool? acceptsMonthly,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection(AppConstants.maidProfilesCollection)
        .where('isAvailable', isEqualTo: true);

    if (acceptsHourly == true) {
      query = query.where('acceptsHourly', isEqualTo: true);
    }
    if (acceptsMonthly == true) {
      query = query.where('acceptsMonthly', isEqualTo: true);
    }

    final snapshot = await query.get();
    var maids =
        snapshot.docs.map((doc) => MaidProfileModel.fromMap(doc.data())).toList();

    // Client-side filtering for fields that can't be combined in Firestore
    if (service != null) {
      maids = maids.where((m) => m.specializedServices.contains(service)).toList();
    }
    if (minRating != null) {
      maids = maids.where((m) => m.rating >= minRating).toList();
    }
    if (maxHourlyRate != null) {
      maids = maids.where((m) => m.hourlyRate <= maxHourlyRate).toList();
    }

    return maids;
  }

  // ──────────────── BOOKINGS ────────────────

  Future<void> createBooking(BookingModel booking) async {
    await _db
        .collection(AppConstants.bookingsCollection)
        .doc(booking.id)
        .set(booking.toMap());
  }

  Future<void> updateBooking(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.bookingsCollection)
        .doc(id)
        .update(data);
  }

  Stream<List<BookingModel>> getMaidBookings(String maidId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('maidId', isEqualTo: maidId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  Stream<List<BookingModel>> getHouseholdBookings(String householdId) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  // ──────────────── REVIEWS ────────────────

  Future<void> createReview(ReviewModel review) async {
    await _db
        .collection(AppConstants.reviewsCollection)
        .doc(review.id)
        .set(review.toMap());

    // Update maid's rating
    final reviews = await _db
        .collection(AppConstants.reviewsCollection)
        .where('maidId', isEqualTo: review.maidId)
        .get();

    final totalReviews = reviews.docs.length;
    final avgRating = reviews.docs
            .map((doc) => (doc.data()['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
        totalReviews;

    await updateMaidProfile(review.maidId, {
      'rating': avgRating,
      'totalReviews': totalReviews,
    });
  }

  Stream<List<ReviewModel>> getMaidReviews(String maidId) {
    return _db
        .collection(AppConstants.reviewsCollection)
        .where('maidId', isEqualTo: maidId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data()))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  // ──────────────── HOURLY POSTS ────────────────

  Future<void> createHourlyPost(HourlyPostModel post) async {
    await _db
        .collection(AppConstants.hourlyPostsCollection)
        .doc(post.id)
        .set(post.toMap());
  }

  Future<void> updateHourlyPost(
      String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.hourlyPostsCollection)
        .doc(id)
        .update(data);
  }

  Stream<List<HourlyPostModel>> getOpenHourlyPosts() {
    return _db
        .collection(AppConstants.hourlyPostsCollection)
        .where('status', isEqualTo: PostStatus.open.name)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => HourlyPostModel.fromMap(doc.data()))
              .toList();
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  Stream<List<HourlyPostModel>> getHouseholdPosts(String householdId) {
    return _db
        .collection(AppConstants.hourlyPostsCollection)
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => HourlyPostModel.fromMap(doc.data()))
              .toList();
          // Sort in-memory since Firestore composite index is not created
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  Future<void> applyToHourlyPost(String postId, String maidId) async {
    await _db
        .collection(AppConstants.hourlyPostsCollection)
        .doc(postId)
        .update({
      'applicantIds': FieldValue.arrayUnion([maidId]),
    });
  }

  Future<void> assignMaidToPost(String postId, String maidId) async {
    await _db
        .collection(AppConstants.hourlyPostsCollection)
        .doc(postId)
        .update({
      'assignedMaidId': maidId,
      'status': PostStatus.assigned.name,
    });
  }

  Future<List<MaidProfileModel>> getMaidsByIds(List<String> maidIds) async {
    if (maidIds.isEmpty) return [];

    final maids = <MaidProfileModel>[];
    // Firestore 'in' query supports max 10 items, so batch them
    for (var i = 0; i < maidIds.length; i += 10) {
      final batch = maidIds.skip(i).take(10).toList();
      final snapshot = await _db
          .collection(AppConstants.maidProfilesCollection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      maids.addAll(
        snapshot.docs.map((doc) => MaidProfileModel.fromMap(doc.data())),
      );
    }

    return maids;
  }

  // ──────────────── VERIFICATION ────────────────

  Future<void> submitVerificationRequest(VerificationRequestModel request) async {
    await _db
        .collection(AppConstants.verificationsCollection)
        .doc(request.id)
        .set(request.toMap());
  }

  Future<VerificationRequestModel?> getVerificationRequest(String requestId) async {
    final doc = await _db
        .collection(AppConstants.verificationsCollection)
        .doc(requestId)
        .get();
    if (!doc.exists) return null;
    return VerificationRequestModel.fromMap(doc.data()!);
  }

  Future<void> updateVerificationStatus(
      String requestId, VerificationStatus status, String? adminNote) async {
    await _db
        .collection(AppConstants.verificationsCollection)
        .doc(requestId)
        .update({
      'status': status.name,
      'adminNote': adminNote,
    });
  }

  Future<VerificationRequestModel?> getUserVerificationRequest(String uid) async {
    final snapshot = await _db
        .collection(AppConstants.verificationsCollection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return VerificationRequestModel.fromMap(snapshot.docs.first.data());
  }
}
