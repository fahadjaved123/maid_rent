import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/providers/household_provider.dart';
import 'package:maid_rent/widgets/loading_widget.dart';

/// Screen for households to review all applicants for a posted job
/// Features:
/// - Summary header of the job with live status (Open / Hired)
/// - Confirmation banner when a maid is hired
/// - List of applicant maid cards with rating, rates, verified badge, and experience
/// - Hired badge and dedicated UI indicator for the selected maid
/// - Profile review and Direct Hire action
class JobApplicantsScreen extends StatefulWidget {
  final HourlyPostModel post;

  const JobApplicantsScreen({
    super.key,
    required this.post,
  });

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  String? _hiringMaidId;
  late HourlyPostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HouseholdProvider>().loadApplicants(widget.post.applicantIds);
    });
  }

  Future<void> _hireMaid(MaidProfileModel maid, HourlyPostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Hire ${maid.name}?',
          style: AppTheme.headlineMedium.copyWith(fontSize: 20),
        ),
        content: Text(
          'This will assign ${maid.name} to "${post.title}" and create a confirmed booking.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: const Text('Confirm Hire'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _hiringMaidId = maid.uid);

    try {
      final auth = context.read<AuthProvider>();
      final householdProvider = context.read<HouseholdProvider>();
      final bookingProvider = context.read<BookingProvider>();

      // 1. Assign maid to post
      await householdProvider.assignMaid(post.id, maid.uid);

      // 2. Create booking
      final newBooking = BookingModel(
        id: '', // Will be generated in provider
        householdId: auth.userModel!.uid,
        householdName: auth.userModel!.name,
        householdImage: auth.userModel!.profileImage,
        maidId: maid.uid,
        maidName: maid.name,
        maidImage: maid.profileImage,
        hiringType: HiringType.hourly,
        status: BookingStatus.accepted,
        services: post.services,
        startDate: post.date,
        startTime: post.startTime,
        endTime: post.endTime,
        totalHours: post.hours,
        hourlyRate: post.hours > 0 ? post.budget / post.hours : post.budget,
        totalPrice: post.budget,
        address: post.address,
        createdAt: DateTime.now(),
      );

      await bookingProvider.createBooking(newBooking);

      if (mounted) {
        setState(() {
          _currentPost = post.copyWith(
            status: PostStatus.assigned,
            assignedMaidId: maid.uid,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Successfully hired ${maid.name}! Booking is now confirmed.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to hire maid: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _hiringMaidId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          'Job Applicants',
          style: AppTheme.headlineMedium.copyWith(fontSize: 20),
        ),
      ),
      body: Consumer<HouseholdProvider>(
        builder: (context, provider, _) {
          // Resolve the most up-to-date post model from provider if available
          final postFromProvider = provider.myPosts.where((p) => p.id == _currentPost.id).firstOrNull;
          final post = postFromProvider ?? _currentPost;

          final isJobAssigned = post.status == PostStatus.assigned || post.assignedMaidId != null;
          final hiredMaid = isJobAssigned && post.assignedMaidId != null
              ? provider.applicants.where((m) => m.uid == post.assignedMaidId).firstOrNull
              : null;

          if (provider.isLoading && provider.applicants.isEmpty) {
            return const LoadingWidget(message: 'Loading applicants...');
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              // Job summary card
              _buildJobSummaryCard(post, isJobAssigned),
              const SizedBox(height: AppTheme.spaceMd),

              // Hired Status Banner (if maid is hired)
              if (isJobAssigned) ...[
                _buildHiredBanner(hiredMaid),
                const SizedBox(height: AppTheme.spaceMd),
              ],

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applicants (${provider.applicants.length})',
                    style: AppTheme.headlineMedium.copyWith(fontSize: 18),
                  ),
                  Text(
                    isJobAssigned
                        ? '1 Maid Hired'
                        : 'Select one to hire',
                    style: AppTheme.labelMedium.copyWith(
                      color: isJobAssigned ? AppTheme.success : AppTheme.onSurfaceVariant,
                      fontWeight: isJobAssigned ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Applicants list
              if (provider.applicants.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceXl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'No applicants yet',
                          style: AppTheme.headlineMedium.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          'Maids will appear here once they accept or apply for your job request.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...provider.applicants.map(
                  (maid) => _buildApplicantCard(maid, post, isJobAssigned),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobSummaryCard(HourlyPostModel post, bool isJobAssigned) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isJobAssigned ? AppTheme.success.withOpacity(0.5) : AppTheme.outlineVariant,
          width: isJobAssigned ? 1.5 : 1,
        ),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: AppTheme.headlineMedium.copyWith(fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.hourlyBadgeBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'HOURLY',
                  style: AppTheme.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppTheme.hourlyBadgeText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isJobAssigned) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 13,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'HIRED',
                        style: AppTheme.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Text(
                '\$${post.budget.toInt()}',
                style: AppTheme.headlineMedium.copyWith(
                  fontSize: 22,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '• ${post.hours} hours',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d').format(post.date),
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHiredBanner(MaidProfileModel? hiredMaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hiredMaid != null ? 'Maid Hired: ${hiredMaid.name}' : 'Maid Hired',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A confirmed booking has been created for this job post.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(
    MaidProfileModel maid,
    HourlyPostModel post,
    bool isJobAssigned,
  ) {
    final isHiring = _hiringMaidId == maid.uid;
    final isThisMaidHired = post.assignedMaidId == maid.uid;
    final isAnotherMaidHired = isJobAssigned && !isThisMaidHired;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isThisMaidHired ? AppTheme.success : AppTheme.outlineVariant,
          width: isThisMaidHired ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isThisMaidHired ? AppTheme.success : AppTheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: maid.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: maid.profileImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.surfaceContainer,
                            ),
                            errorWidget: (context, url, error) =>
                                _buildAvatarFallback(maid.name),
                          )
                        : _buildAvatarFallback(maid.name),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              maid.name,
                              style: AppTheme.bodyLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (maid.totalReviews > 5 && maid.rating >= 4.0) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppTheme.verifiedBlue,
                            ),
                          ],
                          if (isThisMaidHired) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'HIRED',
                                    style: AppTheme.labelSmall.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.ratingGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${maid.rating.toStringAsFixed(1)} ',
                            style: AppTheme.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '(${maid.totalReviews} reviews)',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${maid.experienceYears}+ years exp • \$${maid.hourlyRate.toInt()}/hr standard',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Services
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: maid.specializedServices
                  .take(3)
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        s,
                        style: AppTheme.labelSmall.copyWith(fontSize: 10),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/household/maid-detail',
                        arguments: maid.uid,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primary, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      'View Profile',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                if (isThisMaidHired)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.success, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hired Maid',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isAnotherMaidHired)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerHigh,
                        disabledBackgroundColor: AppTheme.surfaceContainerHigh,
                        disabledForegroundColor: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(
                        'Position Filled',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isHiring ? null : () => _hireMaid(maid, post),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: isHiring
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Hire This Maid',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: AppTheme.primaryContainer.withOpacity(0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'M',
          style: AppTheme.headlineLarge.copyWith(
            fontSize: 24,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
