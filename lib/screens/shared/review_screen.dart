import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;

  const ReviewScreen({super.key, required this.bookingId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5.0;
  final _reviewController = TextEditingController();
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _loadBooking() {
    final bookingProvider = context.read<BookingProvider>();
    final booking = bookingProvider.bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => BookingModel(
        id: '',
        maidId: '',
        householdId: '',
        hiringType: HiringType.hourly,
        status: BookingStatus.completed,
        services: [],
        startDate: DateTime.now(),
        totalPrice: 0,
        hourlyRate: 0,
        address: '',
        createdAt: DateTime.now(),
      ),
    );

    if (booking.id.isNotEmpty) {
      setState(() => _booking = booking);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.submitReview(
      widget.bookingId,
      _rating,
      _reviewController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: _booking == null
          ? const Center(child: Text('Booking not found'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Maid Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: _booking!.maidImage != null
                            ? NetworkImage(_booking!.maidImage!)
                            : null,
                        child: _booking!.maidImage == null
                            ? const Icon(Icons.person,
                                size: 32, color: AppTheme.primaryColor)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _booking!.maidName ?? 'Maid',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rate your experience',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Rating Section
                const Text(
                  'How would you rate the service?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Center(
                  child: RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 48,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    _getRatingLabel(_rating),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _getRatingColor(_rating),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Review Text Area
                const Text(
                  'Share your experience',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _reviewController,
                  label: 'Your Review',
                  hint: 'Tell us about your experience with this maid...',
                  maxLines: 6,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please write a review' : null,
                ),
                const SizedBox(height: 32),

                // Tips Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Tips for a helpful review',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Was the maid punctual and professional?\n'
                        '• How was the quality of work?\n'
                        '• Would you recommend them to others?\n'
                        '• Any specific highlights or concerns?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    return CustomButton(
                      text: 'Submit Review',
                      onPressed: _submitReview,
                      isLoading: provider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent! ⭐';
    if (rating >= 3.5) return 'Good 👍';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Below Average';
    return 'Poor';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return AppTheme.successColor;
    if (rating >= 3.0) return AppTheme.primaryColor;
    if (rating >= 2.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
