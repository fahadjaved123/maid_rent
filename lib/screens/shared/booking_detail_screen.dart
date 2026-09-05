import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'package:maid_rent/widgets/rating_widget.dart';
import 'package:maid_rent/widgets/service_chip.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  BookingModel? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final bookingProvider = context.read<BookingProvider>();
    final booking = bookingProvider.bookings
        .firstWhere((b) => b.id == widget.bookingId, orElse: () => BookingModel(
              id: '',
              maidId: '',
              householdId: '',
              hiringType: HiringType.hourly,
              status: BookingStatus.pending,
              services: [],
              startDate: DateTime.now(),
              totalPrice: 0,
              hourlyRate: 0,
              address: '',
              createdAt: DateTime.now(),
            ));

    if (booking.id.isNotEmpty) {
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading booking details...'),
      );
    }

    if (_booking == null || _booking!.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Booking not found')),
      );
    }

    final auth = context.watch<AuthProvider>();
    final isMaid = auth.userModel!.role.toString().contains('maid');
    final isPending = _booking!.status == BookingStatus.pending;
    final isAccepted = _booking!.status == BookingStatus.accepted;
    final isInProgress = _booking!.status == BookingStatus.inProgress;
    final isCompleted = _booking!.status == BookingStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status Badge
          Center(
            child: _StatusBadge(status: _booking!.status),
          ),
          const SizedBox(height: 24),

          // Profile Card
          _ProfileCard(
            name: isMaid
                ? _booking!.householdName ?? 'Household'
                : _booking!.maidName ?? 'Maid',
            imageUrl: isMaid ? _booking!.householdImage : _booking!.maidImage,
            role: isMaid ? 'Household' : 'Maid',
          ),
          const SizedBox(height: 24),

          // Booking Info Card
          _InfoSection(
            title: 'Booking Information',
            children: [
              _InfoRow(
                icon: Icons.work_outline,
                label: 'Hiring Type',
                value: _booking!.hiringType.toString().split('.').last.toUpperCase(),
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Start Date',
                value: DateFormat('MMM dd, yyyy').format(_booking!.startDate),
              ),
              if (_booking!.endDate != null)
                _InfoRow(
                  icon: Icons.event,
                  label: 'End Date',
                  value: DateFormat('MMM dd, yyyy').format(_booking!.endDate!),
                ),
              if (_booking!.startTime != null && _booking!.endTime != null)
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${_booking!.startTime} - ${_booking!.endTime}',
                ),
              if (_booking!.totalHours != null)
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Duration',
                  value: '${_booking!.totalHours} hours',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Services
          _InfoSection(
            title: 'Services',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _booking!.services.map((service) {
                  return ServiceChip(
                    label: service,
                    isSelected: true,
                    onTap: () {},
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address
          _InfoSection(
            title: 'Address',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _booking!.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          if (_booking!.notes?.isNotEmpty ?? false) ...[
            _InfoSection(
              title: 'Special Instructions',
              children: [
                Text(
                  _booking!.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Price
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rs. ${_booking!.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Review Section (for completed bookings)
          if (isCompleted && _booking!.rating != null) ...[
            _InfoSection(
              title: 'Your Review',
              children: [
                Row(
                  children: [
                    RatingWidget(rating: _booking!.rating!),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_booking!.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_booking!.review?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  Text(
                    _booking!.review!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          Consumer<BookingProvider>(
            builder: (context, provider, _) {
              if (isMaid) {
                if (isPending) {
                  return Column(
                    children: [
                      CustomButton(
                        text: 'Accept Booking',
                        onPressed: () => _acceptBooking(provider),
                        isLoading: provider.isLoading,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Reject',
                        onPressed: () => _rejectBooking(provider),
                        isOutlined: true,
                        color: AppTheme.errorColor,
                      ),
                    ],
                  );
                } else if (isAccepted) {
                  return CustomButton(
                    text: 'Start Job',
                    onPressed: () => _startBooking(provider),
                    isLoading: provider.isLoading,
                  );
                } else if (isInProgress) {
                  return CustomButton(
                    text: 'Mark as Completed',
                    onPressed: () => _completeBooking(provider),
                    isLoading: provider.isLoading,
                    color: AppTheme.successColor,
                  );
                }
              } else {
                // Household actions
                if (isPending) {
                  return CustomButton(
                    text: 'Cancel Booking',
                    onPressed: () => _cancelBooking(provider),
                    isOutlined: true,
                    color: AppTheme.errorColor,
                  );
                } else if (isCompleted && _booking!.rating == null) {
                  return CustomButton(
                    text: 'Leave a Review',
                    onPressed: () => _navigateToReview(),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _acceptBooking(BookingProvider provider) async {
    final success = await provider.acceptBooking(_booking!.id);
    if (success && mounted) {
      setState(() => _booking = provider.bookings.firstWhere((b) => b.id == _booking!.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking accepted successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _rejectBooking(BookingProvider provider) async {
    final confirmed = await _showConfirmDialog(
      'Reject Booking?',
      'Are you sure you want to reject this booking request?',
    );
    if (confirmed == true) {
      final success = await provider.rejectBooking(_booking!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _startBooking(BookingProvider provider) async {
    final success = await provider.startBooking(_booking!.id);
    if (success && mounted) {
      setState(() => _booking = provider.bookings.firstWhere((b) => b.id == _booking!.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job started!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  Future<void> _completeBooking(BookingProvider provider) async {
    final success = await provider.completeBooking(_booking!.id);
    if (success && mounted) {
      setState(() => _booking = provider.bookings.firstWhere((b) => b.id == _booking!.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job completed!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _cancelBooking(BookingProvider provider) async {
    final confirmed = await _showConfirmDialog(
      'Cancel Booking?',
      'Are you sure you want to cancel this booking?',
    );
    if (confirmed == true) {
      final success = await provider.cancelBooking(_booking!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToReview() {
    Navigator.pushNamed(context, '/review', arguments: _booking!.id);
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = AppTheme.warningColor;
        label = 'Pending';
        icon = Icons.schedule;
        break;
      case BookingStatus.accepted:
        color = AppTheme.primaryColor;
        label = 'Accepted';
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.inProgress:
        color = AppTheme.primaryColor;
        label = 'In Progress';
        icon = Icons.work_outline;
        break;
      case BookingStatus.completed:
        color = AppTheme.successColor;
        label = 'Completed';
        icon = Icons.check_circle;
        break;
      case BookingStatus.rejected:
        color = AppTheme.errorColor;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      case BookingStatus.cancelled:
        color = AppTheme.errorColor;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String role;

  const _ProfileCard({
    required this.name,
    this.imageUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 32, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
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
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
