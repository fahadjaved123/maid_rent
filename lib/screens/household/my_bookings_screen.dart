import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/widgets/booking_card.dart';
import 'package:maid_rent/widgets/empty_state_widget.dart';
import 'package:maid_rent/widgets/loading_widget.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel != null) {
      context
          .read<BookingProvider>()
          .loadHouseholdBookings(auth.userModel!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading bookings...');
          }

          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: TabBarView(
              controller: _tabController,
              children: [
                _BookingList(
                  bookings: provider.pendingBookings,
                  emptyIcon: Icons.schedule,
                  emptyTitle: 'No Pending Bookings',
                  emptySubtitle:
                      'When you book a maid, the request will appear here',
                ),
                _BookingList(
                  bookings: provider.activeBookings,
                  emptyIcon: Icons.work_outline,
                  emptyTitle: 'No Active Bookings',
                  emptySubtitle:
                      'Accepted bookings and ongoing services appear here',
                ),
                _BookingList(
                  bookings: provider.completedBookings,
                  emptyIcon: Icons.check_circle_outline,
                  emptyTitle: 'No Completed Bookings',
                  emptySubtitle: 'Your past bookings will be listed here',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _BookingList({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookingCard(
            booking: booking,
            viewerRole: UserRole.household,
            onTap: () => Navigator.pushNamed(
              context,
              '/booking-detail',
              arguments: booking.id,
            ),
          ),
        );
      },
    );
  }
}
