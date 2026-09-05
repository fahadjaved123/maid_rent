import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/service_category.dart';

/// Enhanced Maid Card for the Pakistani Market
/// Features:
/// - Verified badge (based on identity verification)
/// - Category-based service chips
/// - Localized currency (Rs.)
/// - Professional visual hierarchy
class MaidCard extends StatelessWidget {
  final MaidProfileModel maid;
  final VoidCallback onTap;
  final bool showFullDetails;

  const MaidCard({
    super.key,
    required this.maid,
    required this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowLevel1,
        border: Border.all(
          color: AppTheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile Image with Verified Badge
                    _buildProfileImage(),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name with Verified Badge
                          _buildNameRow(),
                          const SizedBox(height: 4),

                          // Rating in "★ 4.9 (124 reviews)" format
                          _buildRatingRow(),
                          const SizedBox(height: 4),

                          // Experience
                          if (maid.experienceYears > 0)
                            Text(
                              'Expert in ${_getMainCategory()}. ${maid.experienceYears}+ years experience.',
                              style: AppTheme.bodyMedium.copyWith(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // Status Badge (Hourly/Contract)
                    _buildStatusBadge(),
                  ],
                ),

                const SizedBox(height: 12),

                // Category Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: maid.categories
                      .map((cat) => _buildServiceChip(cat.label))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Bottom Row - Price and Action
                Row(
                  children: [
                    // Price
                    Text(
                      'Rs. ${maid.hourlyRate.toInt()}',
                      style: AppTheme.headlineMedium.copyWith(
                        fontSize: 20,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '/hr',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),

                    // View Profile / Hire Button
                    Row(
                      children: [
                        TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('View Profile'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text('Hire'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.outlineVariant,
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
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildAvatarFallback(),
                  )
                : _buildAvatarFallback(),
          ),
        ),
        // Verified Badge
        if (maid.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.verifiedBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.surfaceContainerLowest,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppTheme.primaryContainer.withOpacity(0.2),
      child: Center(
        child: Text(
          maid.name.isNotEmpty ? maid.name[0].toUpperCase() : 'M',
          style: AppTheme.headlineLarge.copyWith(
            fontSize: 32,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            maid.name,
            style: AppTheme.bodyLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (maid.isVerified) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            size: 18,
            color: AppTheme.verifiedBlue,
          ),
        ],
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: AppTheme.ratingGold,
        ),
        const SizedBox(width: 4),
        Text(
          '${maid.rating.toStringAsFixed(1)} ',
          style: AppTheme.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
          ),
        ),
        Text(
          '(${maid.totalReviews} reviews)',
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    String label;
    Color bgColor;
    Color textColor;

    if (maid.acceptsContract) {
      label = 'Contract';
      bgColor = AppTheme.contractBadgeBg;
      textColor = AppTheme.contractBadgeText;
    } else if (maid.acceptsHourly) {
      label = 'Hourly';
      bgColor = AppTheme.hourlyBadgeBg;
      textColor = AppTheme.hourlyBadgeText;
    } else {
      label = 'Monthly';
      bgColor = AppTheme.hourlyBadgeBg;
      textColor = AppTheme.hourlyBadgeText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: AppTheme.labelSmall.copyWith(
          color: textColor,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        service,
        style: AppTheme.labelSmall.copyWith(
          fontSize: 11,
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMainCategory() {
    if (maid.categories.isEmpty) return 'various services';
    return maid.categories[0].label.toLowerCase();
  }
}
