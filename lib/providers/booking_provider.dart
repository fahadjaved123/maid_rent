import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/review_model.dart';
import 'package:maid_rent/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<BookingModel>>? _bookingsSubscription;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookingModel> get pendingBookings =>
      _bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingModel> get activeBookings => _bookings
      .where((b) =>
          b.status == BookingStatus.accepted ||
          b.status == BookingStatus.inProgress)
      .toList();

  List<BookingModel> get completedBookings =>
      _bookings.where((b) => b.status == BookingStatus.completed).toList();

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  // Create a new booking
  Future<bool> createBooking(BookingModel booking) async {
    try {
      _setLoading(true);
      final newBooking = booking.copyWith(id: _uuid.v4());
      await _firestoreService.createBooking(newBooking);
      _bookings.add(newBooking);
      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create booking.';
      notifyListeners();
      return false;
    }
  }

  // Load bookings for maid
  void loadMaidBookings(String maidId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription =
        _firestoreService.getMaidBookings(maidId).listen((bookingList) {
      _bookings = bookingList;
      notifyListeners();
    });
  }

  // Load bookings for household
  void loadHouseholdBookings(String householdId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription =
        _firestoreService.getHouseholdBookings(householdId).listen((bookingList) {
      _bookings = bookingList;
      notifyListeners();
    });
  }

  // Accept booking (maid)
  Future<bool> acceptBooking(String bookingId) async {
    try {
      await _firestoreService.updateBooking(bookingId, {
        'status': BookingStatus.accepted.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to accept booking.';
      notifyListeners();
      return false;
    }
  }

  // Reject booking (maid)
  Future<bool> rejectBooking(String bookingId) async {
    try {
      await _firestoreService.updateBooking(bookingId, {
        'status': BookingStatus.rejected.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to reject booking.';
      notifyListeners();
      return false;
    }
  }

  // Mark as in progress
  Future<bool> startBooking(String bookingId) async {
    try {
      await _firestoreService.updateBooking(bookingId, {
        'status': BookingStatus.inProgress.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to update booking.';
      notifyListeners();
      return false;
    }
  }

  // Complete booking
  Future<bool> completeBooking(String bookingId) async {
    try {
      await _firestoreService.updateBooking(bookingId, {
        'status': BookingStatus.completed.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to complete booking.';
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestoreService.updateBooking(bookingId, {
        'status': BookingStatus.cancelled.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to cancel booking.';
      notifyListeners();
      return false;
    }
  }

  // Submit review
  Future<bool> submitReview(
    String bookingId,
    double rating,
    String review,
  ) async {
    try {
      _setLoading(true);

      // Get booking details
      final booking = _bookings.firstWhere((b) => b.id == bookingId);

      final reviewModel = ReviewModel(
        id: _uuid.v4(),
        bookingId: bookingId,
        maidId: booking.maidId,
        householdId: booking.householdId,
        householdName: booking.householdName ?? 'Household',
        rating: rating,
        review: review,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createReview(reviewModel);

      // Update booking with rating
      await _firestoreService.updateBooking(bookingId, {
        'rating': rating,
        'review': review,
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to submit review.';
      notifyListeners();
      return false;
    }
  }

  // Calculate total earnings for maid
  double get totalEarnings {
    return completedBookings.fold(0.0, (sum, b) => sum + b.totalPrice);
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
