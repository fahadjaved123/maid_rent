import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:maid_rent/config/routes.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/services/firestore_service.dart';

/// Job Detail Screen for Maids
/// Matches reference Image #5 design:
/// - Map preview header with location pin
/// - Title, budget rate with "Hourly" & "Est. X hours" chips
/// - Date/time/location info
/// - Poster profile with verified badge & rating
/// - Service request requirements
/// - Bottom sticky buttons for "Message" and "Accept Job"
class HourlyJobDetailScreen extends StatefulWidget {
  final HourlyPostModel post;

  const HourlyJobDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<HourlyJobDetailScreen> createState() => _HourlyJobDetailScreenState();
}

class _HourlyJobDetailScreenState extends State<HourlyJobDetailScreen> {
  bool _isApplying = false;

  Future<void> _applyToJob() async {
    final auth = context.read<AuthProvider>();
    if (auth.userModel == null) return;

    setState(() => _isApplying = true);

    try {
      await FirestoreService().applyToHourlyPost(
        widget.post.id,
        auth.userModel!.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Application submitted successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasApplied = auth.userModel != null &&
        widget.post.applicantIds.contains(auth.userModel!.uid);
    final isHiredForThisJob = auth.userModel != null &&
        widget.post.assignedMaidId == auth.userModel!.uid;
    final isJobAssignedToOther = widget.post.status == PostStatus.assigned && !isHiredForThisJob;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Map Preview Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.surfaceContainerLowest,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowLevel2,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Map placeholder with gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primary.withOpacity(0.1),
                              AppTheme.primary.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            size: 64,
                            color: AppTheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                      // Location label
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: AppTheme.shadowLevel1,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.post.location,
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hired Banner (if this maid was hired for this job)
                      if (auth.userModel != null && widget.post.assignedMaidId == auth.userModel!.uid)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You are Hired for this Job!',
                                      style: AppTheme.labelLarge.copyWith(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'The household has hired you. You can track this in My Bookings.',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Title
                      Text(
                        widget.post.title,
                        style: AppTheme.headlineLarge.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),

                      // Budget and chips row
                      Row(
                        children: [
                          Text(
                            '\$${widget.post.budget.toInt()}',
                            style: AppTheme.headlineMedium.copyWith(
                              fontSize: 28,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.hourlyBadgeBg,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              'Hourly',
                              style: AppTheme.labelSmall.copyWith(
                                fontSize: 11,
                                color: AppTheme.hourlyBadgeText,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              'Est. ${widget.post.hours} hours',
                              style: AppTheme.labelSmall.copyWith(
                                fontSize: 11,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceLg),

                      // Date & Time
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date & Time',
                        DateFormat('EEEE, MMM d, y • h:mm a').format(widget.post.date),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),

                      // Duration
                      _buildInfoRow(
                        Icons.access_time,
                        'Duration',
                        '${widget.post.startTime} - ${widget.post.endTime} (${widget.post.hours}h)',
                      ),
                      const SizedBox(height: AppTheme.spaceMd),

                      // Location
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Location',
                        widget.post.address,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),

                      // Divider
                      Divider(
                        color: AppTheme.outlineVariant,
                        height: 1,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),

                      // Poster Profile
                      Text(
                        'Posted by',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      _buildPosterProfile(),
                      const SizedBox(height: AppTheme.spaceLg),

                      // Divider
                      Divider(
                        color: AppTheme.outlineVariant,
                        height: 1,
                      ),
                      const SizedBox(height: AppTheme.spaceLg),

                      // Service Request
                      Text(
                        'Service Request',
                        style: AppTheme.headlineMedium.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      Text(
                        widget.post.description,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),

                      // Services chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.post.services
                            .map((service) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryContainer.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    service,
                                    style: AppTheme.labelMedium.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 120), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom sticky buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Message functionality
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primary, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: Text(
                          'Message',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      flex: 3,
                      child: isHiredForThisJob
                          ? ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.maidBookings);
                              },
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('View in Bookings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: AppTheme.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                              ),
                            )
                          : isJobAssignedToOther
                              ? ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.surfaceContainerHigh,
                                    disabledBackgroundColor: AppTheme.surfaceContainerHigh,
                                    disabledForegroundColor: AppTheme.onSurfaceVariant,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    ),
                                  ),
                                  child: const Text('Position Filled'),
                                )
                              : ElevatedButton(
                                  onPressed: hasApplied || _isApplying ? null : _applyToJob,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: AppTheme.onPrimary,
                                    disabledBackgroundColor: AppTheme.surfaceContainerHigh,
                                    disabledForegroundColor: AppTheme.onSurfaceVariant,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    ),
                                  ),
                                  child: _isApplying
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppTheme.onPrimary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          hasApplied ? 'Applied' : 'Accept Job',
                                          style: AppTheme.labelMedium.copyWith(
                                            color: hasApplied
                                                ? AppTheme.onSurfaceVariant
                                                : AppTheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPosterProfile() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.outlineVariant,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: widget.post.householdImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.post.householdImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.surfaceContainer,
                      ),
                      errorWidget: (context, url, error) =>
                          _buildAvatarFallback(widget.post.householdName),
                    )
                  : _buildAvatarFallback(widget.post.householdName),
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
                        widget.post.householdName,
                        style: AppTheme.bodyLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: AppTheme.verifiedBlue,
                    ),
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
                      '4.8 (24 reviews)',
                      style: AppTheme.labelMedium.copyWith(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: AppTheme.primaryContainer.withOpacity(0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'H',
          style: AppTheme.labelMedium.copyWith(
            fontSize: 20,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
