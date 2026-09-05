import 'package:flutter/material.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final UserRole viewerRole;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.viewerRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      viewerRole == UserRole.maid
                          ? (booking.householdName ?? 'Household')
                          : (booking.maidName ?? 'Maid'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy').format(booking.startDate),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.work_outline,
                    booking.hiringType.name.toUpperCase(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (booking.startTime != null && booking.startTime!.isNotEmpty)
                    _buildInfoChip(
                      Icons.access_time,
                      '${booking.startTime} - ${booking.endTime}',
                    ),
                  const Spacer(),
                  Text(
                    'Rs ${booking.totalPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              if (booking.services.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  booking.services.join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text = booking.status.name;

    switch (booking.status) {
      case BookingStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        text = 'Pending';
        break;
      case BookingStatus.accepted:
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        text = 'Accepted';
        break;
      case BookingStatus.inProgress:
        bgColor = AppTheme.primaryColor.withValues(alpha: 0.1);
        textColor = AppTheme.primaryColor;
        text = 'In Progress';
        break;
      case BookingStatus.completed:
        bgColor = AppTheme.successColor.withValues(alpha: 0.1);
        textColor = AppTheme.successColor;
        text = 'Completed';
        break;
      case BookingStatus.rejected:
        bgColor = AppTheme.errorColor.withValues(alpha: 0.1);
        textColor = AppTheme.errorColor;
        text = 'Rejected';
        break;
      case BookingStatus.cancelled:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
