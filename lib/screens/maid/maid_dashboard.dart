import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/models/verification_request_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/booking_card.dart';
import 'package:maid_rent/widgets/empty_state_widget.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'package:maid_rent/screens/maid/verification_upload_screen.dart';

class MaidDashboardScreen extends StatefulWidget {
  const MaidDashboardScreen({super.key});

  @override
  State<MaidDashboardScreen> createState() => _MaidDashboardScreenState();
}

class _MaidDashboardScreenState extends State<MaidDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final maidProvider = context.read<MaidProvider>();
    final bookingProvider = context.read<BookingProvider>();

    maidProvider.loadMaidProfile(auth.userModel!.uid);
    bookingProvider.loadMaidBookings(auth.userModel!.uid);
    await maidProvider.loadVerificationStatus(auth.userModel!.uid);
  }

  Widget _buildVerificationBanner(MaidProvider maidProvider) {
    final request = maidProvider.verificationRequest;
    String message = 'Verify your identity to get more bookings!';
    if (request != null) {
      switch (request.status) {
        case VerificationStatus.pending:
          message = 'Your verification is pending review.';
          break;
        case VerificationStatus.rejected:
          message = 'Verification rejected. Please re-upload your CNIC.';
          break;
        case VerificationStatus.approved:
          return const SizedBox.shrink();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/maid/verify'),
            child: const Text('Verify Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer3<AuthProvider, MaidProvider, BookingProvider>(
          builder: (context, auth, maidProvider, bookingProvider, _) {
            if (maidProvider.isLoading) {
              return const LoadingWidget(message: 'Loading dashboard...');
            }

            final profile = maidProvider.maidProfile;
            if (profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyStateWidget(
                      icon: Icons.person_add_outlined,
                      title: 'Complete Your Profile',
                      subtitle: 'Set up your profile to start receiving bookings',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, '/maid/profile-setup'),
                      child: const Text('Setup Profile'),
                    ),
                  ],
                ),
              );
            }

            final pendingBookings = bookingProvider.pendingBookings;
            final activeBookings = bookingProvider.activeBookings;
            final totalEarnings = bookingProvider.totalEarnings;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Verification Banner
                if (auth.userModel?.isVerified == false)
                  _buildVerificationBanner(maidProvider),
                const SizedBox(height: AppTheme.spaceMd),
                // Profile Summary Card
                _ProfileSummaryCard(
                  name: auth.userModel!.name,
                  imageUrl: auth.userModel!.profileImage,
                  rating: profile.rating,
                  totalReviews: profile.totalReviews,
                  completedJobs: profile.completedJobs,
                ),
                const SizedBox(height: 20),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.schedule,
                        label: 'Pending',
                        value: '${pendingBookings.length}',
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.work_outline,
                        label: 'Active',
                        value: '${activeBookings.length}',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.currency_rupee,
                        label: 'Earned',
                        value: totalEarnings.toStringAsFixed(0),
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.work_history_outlined,
                        label: 'Hourly Jobs',
                        onTap: () => Navigator.pushNamed(
                            context, '/maid/hourly-jobs'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.calendar_today_outlined,
                        label: 'My Bookings',
                        onTap: () => Navigator.pushNamed(
                            context, '/maid/bookings'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.attach_money,
                        label: 'Earnings',
                        onTap: () => Navigator.pushNamed(
                            context, '/maid/earnings'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pending Requests
                if (pendingBookings.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pending Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/maid/bookings'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...pendingBookings.take(3).map(
                        (booking) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BookingCard(
                            booking: booking,
                            viewerRole: UserRole.maid,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/booking-detail',
                              arguments: booking.id,
                            ),
                          ),
                        ),
                      ),
                ],

                // Active Jobs
                if (activeBookings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Active Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...activeBookings.take(3).map(
                        (booking) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BookingCard(
                            booking: booking,
                            viewerRole: UserRole.maid,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/booking-detail',
                              arguments: booking.id,
                            ),
                          ),
                        ),
                      ),
                ],

                if (pendingBookings.isEmpty && activeBookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: EmptyStateWidget(
                      icon: Icons.inbox_outlined,
                      title: 'No Active Bookings',
                      subtitle:
                          'New booking requests will appear here.\nCheck hourly jobs for quick opportunities!',
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final int completedJobs;

  const _ProfileSummaryCard({
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.totalReviews,
    required this.completedJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl!) : null,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($totalReviews reviews)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedJobs jobs completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
