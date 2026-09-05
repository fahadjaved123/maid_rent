import 'package:flutter/material.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class HouseholdProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<HourlyPostModel> _openPosts = [];
  List<HourlyPostModel> _myPosts = [];
  List<MaidProfileModel> _applicants = [];
  bool _isLoading = false;
  String? _error;

  List<HourlyPostModel> get openPosts => _openPosts;
  List<HourlyPostModel> get myPosts => _myPosts;
  List<MaidProfileModel> get applicants => _applicants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  // Create hourly job post
  Future<bool> createHourlyPost(HourlyPostModel post) async {
    try {
      _setLoading(true);
      final newPost = post.copyWith(id: _uuid.v4());
      await _firestoreService.createHourlyPost(newPost);
      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create post.';
      notifyListeners();
      return false;
    }
  }

  // Load open posts (for maids to browse)
  void loadOpenPosts() {
    _firestoreService.getOpenHourlyPosts().listen((posts) {
      _openPosts = posts;
      notifyListeners();
    });
  }

  // Load household's own posts
  void loadMyPosts(String householdId) {
    _firestoreService.getHouseholdPosts(householdId).listen((posts) {
      _myPosts = posts;
      notifyListeners();
    });
  }

  // Load applicants for a specific post
  Future<void> loadApplicants(List<String> applicantIds) async {
    try {
      _setLoading(true);
      _applicants = await _firestoreService.getMaidsByIds(applicantIds);
      _setLoading(false);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load applicants.';
      notifyListeners();
    }
  }

  // Clear applicants list
  void clearApplicants() {
    _applicants = [];
    notifyListeners();
  }

  // Maid applies to a post
  Future<bool> applyToPost(String postId, String maidId) async {
    try {
      await _firestoreService.applyToHourlyPost(postId, maidId);
      return true;
    } catch (e) {
      _error = 'Failed to apply.';
      notifyListeners();
      return false;
    }
  }

  // Household assigns a maid to a post
  Future<bool> assignMaid(String postId, String maidId) async {
    try {
      await _firestoreService.assignMaidToPost(postId, maidId);
      final index = _myPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _myPosts[index] = _myPosts[index].copyWith(
          status: PostStatus.assigned,
          assignedMaidId: maidId,
        );
      }
      _openPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to assign maid.';
      notifyListeners();
      return false;
    }
  }

  // Cancel a post
  Future<bool> cancelPost(String postId) async {
    try {
      await _firestoreService.updateHourlyPost(postId, {
        'status': PostStatus.cancelled.name,
      });
      return true;
    } catch (e) {
      _error = 'Failed to cancel post.';
      notifyListeners();
      return false;
    }
  }
}
