import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/routes.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/providers/household_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/booking_card.dart';
import 'package:maid_rent/widgets/maid_card.dart';

class HouseholdDashboardScreen extends StatefulWidget {
  const HouseholdDashboardScreen({super.key});

  @override
  State<HouseholdDashboardScreen> createState() => _HouseholdDashboardScreenState();
}

class _HouseholdDashboardScreenState extends State<HouseholdDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final maidProvider = context.read<MaidProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final householdProvider = context.read<HouseholdProvider>();

    maidProvider.loadAvailableMaids();
    if (auth.userModel != null) {
      bookingProvider.loadHouseholdBookings(auth.userModel!.uid);
      householdProvider.loadMyPosts(auth.userModel!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'User';
    final bookingProvider = context.watch<BookingProvider>();
    final householdProvider = context.watch<HouseholdProvider>();
    final maidProvider = context.watch<MaidProvider>();

    final totalBookings = bookingProvider.bookings.length;
    final totalPosts = householdProvider.myPosts.length;
    final activeBookings = bookingProvider.activeBookings;
    final pendingBookings = bookingProvider.pendingBookings;
    final recentBookings = [...activeBookings, ...pendingBookings];

    final quickActions = [
      {
        'icon': Icons.search_rounded,
        'label': 'Browse Maids',
        'subtitle': 'Find & hire maids',
        'color': const Color(0xFFB4E4DD),
        'iconColor': const Color(0xFF0F766E),
        'route': AppRoutes.browseMaids,
      },
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Post Job',
        'subtitle': 'Hourly request',
        'color': const Color(0xFFFED7AA),
        'iconColor': const Color(0xFFC2410C),
        'route': AppRoutes.postHourlyJob,
      },
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'My Bookings',
        'subtitle': '$totalBookings total',
        'color': const Color(0xFFDBEAFE),
        'iconColor': const Color(0xFF1D4ED8),
        'route': AppRoutes.myBookings,
      },
      {
        'icon': Icons.assignment_outlined,
        'label': 'My Posts',
        'subtitle': '$totalPosts ${totalPosts == 1 ? 'post' : 'posts'}',
        'color': const Color(0xFFFCE7F3),
        'iconColor': const Color(0xFFBE185D),
        'route': AppRoutes.myPosts,
      },
    ];

    final serviceCards = [
      {'icon': Icons.cleaning_services_rounded, 'label': 'Cleaning', 'color': const Color(0xFFBFEAE2)},
      {'icon': Icons.soup_kitchen_rounded, 'label': 'Cooking', 'color': const Color(0xFFFED7AA)},
      {'icon': Icons.child_care_rounded, 'label': 'Childcare', 'color': const Color(0xFFDBEAFE)},
      {'icon': Icons.local_laundry_service_rounded, 'label': 'Laundry', 'color': const Color(0xFFE9D5FF)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF0D8B8B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with User Avatar, Name & Profile Icons (No fake status bar)
                _buildTopBar(user),
                const SizedBox(height: 20),

                // Hero Banner
                _buildHeroCard(userName),
                const SizedBox(height: 22),

                // 2x2 Quick Actions Grid
                _buildActionGrid(quickActions),
                const SizedBox(height: 28),

                // Popular Services
                _buildSectionHeader(
                  title: 'Popular Services',
                  actionLabel: 'All Services',
                  onAction: () => Navigator.pushNamed(context, AppRoutes.browseMaids),
                ),
                const SizedBox(height: 14),
                _buildServiceGrid(serviceCards),
                const SizedBox(height: 28),

                // Active / Recent Bookings
                _buildSectionHeader(
                  title: 'Active Bookings',
                  actionLabel: totalBookings > 0 ? 'View All' : null,
                  onAction: () => Navigator.pushNamed(context, AppRoutes.myBookings),
                ),
                const SizedBox(height: 14),
                _buildBookingsSection(recentBookings),
                const SizedBox(height: 28),

                // Available Maids
                _buildSectionHeader(
                  title: 'Available Maids',
                  actionLabel: 'Browse All',
                  onAction: () => Navigator.pushNamed(context, AppRoutes.browseMaids),
                ),
                const SizedBox(height: 14),
                _buildAvailableMaidsSection(maidProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0D8B8B).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFF0D8B8B).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: user != null && user.profileImage.isNotEmpty
                      ? Image.network(
                          user.profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(user.name),
                        )
                      : _buildAvatarFallback(user?.name),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user?.name.isNotEmpty == true ? user!.name : 'Household',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2B2B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.person_outline_rounded,
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(String? name) {
    final initial = name?.isNotEmpty == true ? name![0].toUpperCase() : 'H';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D8B8B),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: const Color(0xFF26292B), size: 22),
        ),
      ),
    );
  }

  Widget _buildHeroCard(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D8B8B), Color(0xFF075E64)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D8B8B).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Need a maid today? Browse available maids or post an hourly request in minutes.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.postHourlyJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D8B8B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.work_outline_rounded, size: 22, color: Color(0xFF0D8B8B)),
                  SizedBox(width: 8),
                  Text(
                    'Post Urgent Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D8B8B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(List<Map<String, dynamic>> quickActions) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: quickActions.map((action) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () {
              final route = action['route'] as String;
              Navigator.pushNamed(context, route);
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: action['color'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['iconColor'] as Color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    action['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2B2B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action['subtitle'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2B2B),
            letterSpacing: -0.4,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D8B8B),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceGrid(List<Map<String, dynamic>> serviceCards) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: serviceCards.map((service) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.browseMaids,
                arguments: service['label'] as String,
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: service['color'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: const Color(0xFF0D8B8B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2B2B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingsSection(List<dynamic> bookings) {
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D8B8B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF0D8B8B),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No active bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2B2B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your booked maids and ongoing requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.browseMaids),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D8B8B),
                  side: const BorderSide(color: Color(0xFF0D8B8B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Find a Maid'),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: bookings.take(3).map((booking) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BookingCard(
            booking: booking,
            viewerRole: UserRole.household,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.bookingDetail,
              arguments: booking.id,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailableMaidsSection(MaidProvider maidProvider) {
    if (maidProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF0D8B8B)),
        ),
      );
    }

    final maids = maidProvider.availableMaids;

    if (maids.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No available maids found at the moment.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      children: maids.take(3).map((maid) {
        return MaidCard(
          maid: maid,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.maidDetail,
            arguments: maid.uid,
          ),
        );
      }).toList(),
    );
  }
}
