import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/widgets/empty_state_widget.dart';
import 'package:maid_rent/widgets/loading_widget.dart';

class MaidEarningsScreen extends StatefulWidget {
  const MaidEarningsScreen({super.key});

  @override
  State<MaidEarningsScreen> createState() => _MaidEarningsScreenState();
}

class _MaidEarningsScreenState extends State<MaidEarningsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel != null) {
      context.read<BookingProvider>().loadMaidBookings(auth.userModel!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadEarnings,
        child: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading earnings...');
            }

            final completedBookings = provider.completedBookings;
            final totalEarnings = provider.totalEarnings;

            if (completedBookings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No Earnings Yet',
                subtitle:
                    'Complete jobs to start earning.\nYour payment history will appear here.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Earnings Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.successColor, Color(0xFF27AE60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rs. ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalEarnings.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'From ${completedBookings.length} completed ${completedBookings.length == 1 ? "job" : "jobs"}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'This Month',
                        value: _getMonthlyEarnings(completedBookings),
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Avg per Job',
                        value: completedBookings.isEmpty
                            ? 0
                            : totalEarnings / completedBookings.length,
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Earnings History
                const Text(
                  'Earnings History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ...completedBookings.map((booking) {
                  return _EarningTile(
                    householdName: booking.householdName ?? 'Household',
                    amount: booking.totalPrice,
                    date: booking.endDate ?? booking.startDate,
                    hiringType: booking.hiringType.toString().split('.').last,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  double _getMonthlyEarnings(List bookings) {
    final now = DateTime.now();
    final thisMonth = bookings.where((b) {
      final date = b.endDate ?? b.startDate;
      return date.year == now.year && date.month == now.month;
    });
    return thisMonth.fold(0.0, (sum, b) => sum + b.totalPrice);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(
            'Rs. ${value.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
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

class _EarningTile extends StatelessWidget {
  final String householdName;
  final double amount;
  final DateTime date;
  final String hiringType;

  const _EarningTile({
    required this.householdName,
    required this.amount,
    required this.date,
    required this.hiringType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  householdName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(date)} • ${_formatHiringType(hiringType)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ Rs. ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHiringType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }
}
