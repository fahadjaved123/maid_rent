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

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final auth = context.read<AuthProvider>();
    context.read<HouseholdProvider>().loadMyPosts(auth.userModel!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.postHourlyJob),
          ),
        ],
      ),
      body: Consumer<HouseholdProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading your posts...');
          }

          if (provider.myPosts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.post_add,
              title: 'No Job Posts Yet',
              subtitle: 'Post an hourly job to find maids quickly',
              buttonText: 'Post a Job',
              onButtonPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.postHourlyJob),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPosts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myPosts.length,
              itemBuilder: (context, index) {
                final post = provider.myPosts[index];
                return _MyPostCard(
                  post: post,
                  onCancel: () => _cancelPost(post.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelPost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Job Post?'),
        content: const Text('Are you sure you want to cancel this job post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Cancel Post'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<HouseholdProvider>().cancelPost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job post cancelled'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }
}

class _MyPostCard extends StatelessWidget {
  final HourlyPostModel post;
  final VoidCallback onCancel;

  const _MyPostCard({
    required this.post,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = post.status == PostStatus.open;
    final isAssigned = post.status == PostStatus.assigned || post.assignedMaidId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAssigned ? AppTheme.success.withOpacity(0.4) : AppTheme.dividerColor,
          width: isAssigned ? 1.5 : 1,
        ),
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
          onTap: (post.applicantIds.isNotEmpty || isAssigned)
              ? () => Navigator.pushNamed(
                    context,
                    AppRoutes.jobApplicants,
                    arguments: post,
                  )
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusBadge(status: post.status),
                Text(
                  DateFormat('MMM dd, yyyy').format(post.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              post.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Services
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.services.map((s) {
                return ServiceChip(
                  label: s,
                  isSelected: true,
                  small: true,
                  onTap: () {},
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Info Row
            Row(
              children: [
                Text(
                  '${post.startTime} - ${post.endTime} (${post.hours}h)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Rs. ${post.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Applicants count & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (post.applicantIds.isNotEmpty || isAssigned)
                      ? () => Navigator.pushNamed(
                            context,
                            AppRoutes.jobApplicants,
                            arguments: post,
                          )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        isAssigned ? Icons.check_circle : Icons.people_outline,
                        size: 18,
                        color: isAssigned ? AppTheme.success : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAssigned
                            ? 'Maid Hired'
                            : '${post.applicantIds.length} applicants',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isAssigned ? AppTheme.success : AppTheme.primaryColor,
                        ),
                      ),
                      if (post.applicantIds.isNotEmpty || isAssigned) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: isAssigned ? AppTheme.success : AppTheme.primaryColor,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (isAssigned)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.jobApplicants,
                          arguments: post,
                        ),
                        icon: const Icon(Icons.check_circle, size: 14),
                        label: const Text(
                          'View Hired Maid',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    else if (post.applicantIds.isNotEmpty && isOpen)
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.jobApplicants,
                          arguments: post,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    if (isOpen) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onCancel,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
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
}

class _StatusBadge extends StatelessWidget {
  final PostStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case PostStatus.open:
        color = AppTheme.primaryColor;
        label = 'Open';
        break;
      case PostStatus.assigned:
        color = AppTheme.successColor;
        label = 'Assigned';
        break;
      case PostStatus.completed:
        color = AppTheme.secondaryColor;
        label = 'Completed';
        break;
      case PostStatus.cancelled:
        color = AppTheme.errorColor;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
