import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/review_model.dart';
import 'package:maid_rent/models/service_category.dart';
import 'package:maid_rent/models/verification_request_model.dart';
import 'package:maid_rent/services/firestore_service.dart';
import 'package:maid_rent/services/storage_service.dart';

class MaidProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  MaidProfileModel? _maidProfile;
  List<MaidProfileModel> _availableMaids = [];
  List<ReviewModel> _reviews = [];
  VerificationRequestModel? _verificationRequest;
  bool _isLoading = false;
  String? _error;

  MaidProfileModel? get maidProfile => _maidProfile;
  List<MaidProfileModel> get availableMaids => _availableMaids;
  List<ReviewModel> get reviews => _reviews;
  VerificationRequestModel? get verificationRequest => _verificationRequest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get a maid by ID from the loaded list
  MaidProfileModel? getMaidById(String maidId) {
    try {
      return _availableMaids.firstWhere((m) => m.uid == maidId);
    } catch (e) {
      return null;
    }
  }

  // Get reviews for a specific maid
  List<ReviewModel> getMaidReviews(String maidId) {
    return _reviews.where((r) => r.maidId == maidId).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  // Load maid profile
  Future<void> loadMaidProfile(String uid) async {
    try {
      _setLoading(true);
      _maidProfile = await _firestoreService.getMaidProfile(uid);
      _setLoading(false);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load profile.';
      notifyListeners();
    }
  }

  // Create or update maid profile
  Future<bool> saveMaidProfile(MaidProfileModel profile) async {
    try {
      _setLoading(true);
      final existing = await _firestoreService.getMaidProfile(profile.uid);
      if (existing == null) {
        await _firestoreService.createMaidProfile(profile);
      } else {
        await _firestoreService.updateMaidProfile(
            profile.uid, profile.toMap());
      }
      _maidProfile = profile;
      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to save profile.';
      notifyListeners();
      return false;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final url = await _storageService.uploadProfileImage(uid, imageFile);
      await _firestoreService.updateMaidProfile(uid, {'profileImage': url});
      _maidProfile = _maidProfile?.copyWith(profileImage: url);
      notifyListeners();
      return url;
    } catch (e) {
      _error = 'Failed to upload image.';
      notifyListeners();
      return null;
    }
  }

  // Toggle availability
  Future<void> toggleAvailability(String uid) async {
    if (_maidProfile == null) return;
    final newStatus = !_maidProfile!.isAvailable;
    await _firestoreService
        .updateMaidProfile(uid, {'isAvailable': newStatus});
    _maidProfile = _maidProfile!.copyWith(isAvailable: newStatus);
    notifyListeners();
  }

  // Load available maids (for household browsing)
  void loadAvailableMaids() {
    _firestoreService.getAvailableMaids().listen((maids) {
      _availableMaids = maids;
      notifyListeners();
    });
  }

  // Search maids with filters
  Future<void> searchMaids({
    ServiceCategory? category,
    String? service,
    double? minRating,
    double? maxHourlyRate,
    bool? acceptsHourly,
    bool? acceptsMonthly,
  }) async {
    try {
      _setLoading(true);
      // Note: We use the same search method but handle category filtering on client-side
      // since Firestore doesn't support easy enum-list filtering.
      _availableMaids = await _firestoreService.searchMaids(
        service: service,
        minRating: minRating,
        maxHourlyRate: maxHourlyRate,
        acceptsHourly: acceptsHourly,
        acceptsMonthly: acceptsMonthly,
      );

      if (category != null) {
        _availableMaids = _availableMaids
            .where((m) => m.categories.contains(category))
            .toList();
      }

      _setLoading(false);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to search maids.';
      notifyListeners();
    }
  }

  // Load reviews for a maid
  void loadMaidReviews(String maidId) {
    _firestoreService.getMaidReviews(maidId).listen((reviewList) {
      _reviews = reviewList;
      notifyListeners();
    });
  }

  // ──────────────── VERIFICATION ────────────────

  Future<void> loadVerificationStatus(String uid) async {
    try {
      _verificationRequest = await _firestoreService.getUserVerificationRequest(uid);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load verification status.';
      notifyListeners();
    }
  }

  Future<bool> submitVerification(VerificationRequestModel request) async {
    try {
      _setLoading(true);
      await _firestoreService.submitVerificationRequest(request);
      _verificationRequest = request;
      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to submit verification.';
      notifyListeners();
      return false;
    }
  }

  void clearProfile() {
    _maidProfile = null;
    _verificationRequest = null;
    notifyListeners();
  }
}
