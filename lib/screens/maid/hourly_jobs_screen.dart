import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/routes.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/household_provider.dart';
import 'package:maid_rent/widgets/empty_state_widget.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'package:maid_rent/widgets/service_chip.dart';

class HourlyJobsScreen extends StatefulWidget {
  const HourlyJobsScreen({super.key});

  @override
  State<HourlyJobsScreen> createState() => _HourlyJobsScreenState();
}

class _HourlyJobsScreenState extends State<HourlyJobsScreen> {
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    context.read<HouseholdProvider>().loadOpenPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Jobs'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadJobs,
        child: Consumer<HouseholdProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading jobs...');
            }

            if (provider.openPosts.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.work_outline,
                title: 'No Hourly Jobs Available',
                subtitle:
                    'Check back later for new opportunities.\nHouseholds post jobs here for quick work.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.openPosts.length,
              itemBuilder: (context, index) {
                final post = provider.openPosts[index];
                return _JobCard(
                  post: post,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.hourlyJobDetail,
                    arguments: post,
                  ),
                  onApply: () => _applyToJob(post),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _applyToJob(HourlyPostModel post) async {
    final auth = context.read<AuthProvider>();
    final hasApplied = post.applicantIds.contains(auth.userModel!.uid);

    if (hasApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already applied to this job'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Apply to Job?'),
        content: Text(
          'Apply to "${post.title}"?\nThe household will see your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context
          .read<HouseholdProvider>()
          .applyToPost(post.id, auth.userModel!.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}

class _JobCard extends StatelessWidget {
  final HourlyPostModel post;
  final VoidCallback onTap;
  final VoidCallback onApply;

  const _JobCard({
    required this.post,
    required this.onTap,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasApplied = post.applicantIds.contains(auth.userModel?.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: post.householdImage.isNotEmpty
                          ? NetworkImage(post.householdImage)
                          : null,
                      child: post.householdImage.isEmpty
                          ? const Icon(Icons.person,
                              size: 20, color: AppTheme.primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.householdName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            post.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Applied',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  post.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Services
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.services.map((service) {
                    return ServiceChip(
                      label: service,
                      isSelected: true,
                      small: true,
                      onTap: () {},
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Details Row
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(post.date),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${post.startTime} - ${post.endTime}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${post.hours} hours',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Budget: Rs. ${post.budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Apply Button
          if (!hasApplied)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onApply,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const Center(
                      child: Text(
                        'Apply for this Job',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
        ),
      ),
    );
  }
}
