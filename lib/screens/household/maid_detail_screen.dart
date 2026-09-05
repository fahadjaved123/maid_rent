import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/constants.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/booking_model.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/service_category.dart';
import 'package:maid_rent/models/review_model.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/booking_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'package:maid_rent/widgets/rating_widget.dart';
import 'package:maid_rent/widgets/service_chip.dart';

class MaidDetailScreen extends StatefulWidget {
  final String maidId;

  const MaidDetailScreen({super.key, required this.maidId});

  @override
  State<MaidDetailScreen> createState() => _MaidDetailScreenState();
}

class _MaidDetailScreenState extends State<MaidDetailScreen> {
  MaidProfileModel? _maid;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaidDetail();
  }

  void _loadMaidDetail() {
    final maidProvider = context.read<MaidProvider>();
    final maid = maidProvider.getMaidById(widget.maidId);
    if (maid != null) {
      final reviews = maidProvider.getMaidReviews(widget.maidId);
      setState(() {
        _maid = maid;
        _reviews = reviews;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading maid profile...'),
      );
    }

    if (_maid == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Maid profile not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _maid!.profileImage != null
                      ? Image.network(
                          _maid!.profileImage!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _maid!.name ?? 'Maid',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _maid!.location ?? 'Location not specified',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ProfileStat(
                            icon: Icons.star,
                            value: _maid!.rating.toStringAsFixed(1),
                            label: '${_maid!.totalReviews} reviews',
                            color: Colors.amber,
                          ),
                          _ProfileStat(
                            icon: Icons.work_history,
                            value: '${_maid!.experienceYears}',
                            label: 'Years Exp.',
                            color: AppTheme.primaryColor,
                          ),
                          _ProfileStat(
                            icon: Icons.check_circle,
                            value: '${_maid!.completedJobs}',
                            label: 'Completed',
                            color: AppTheme.successColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (_maid!.acceptsHourly)
                          Expanded(
                            child: _PriceCard(
                              label: 'Hourly Rate',
                              price: 'Rs. ${_maid!.hourlyRate.toStringAsFixed(0)}',
                              period: '/ hour',
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        if (_maid!.acceptsHourly && _maid!.acceptsMonthly)
                          const SizedBox(width: 12),
                        if (_maid!.acceptsMonthly)
                          Expanded(
                            child: _PriceCard(
                              label: 'Monthly Rate',
                              price: 'Rs. ${_maid!.monthlyRate.toStringAsFixed(0)}',
                              period: '/ month',
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _maid!.bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Services Offered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _maid!.categories.map((cat) {
                        return ServiceChip(
                          label: cat.label,
                          isSelected: true,
                          onTap: () {},
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Working Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Working Hours',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${_maid!.workStartTime} - ${_maid!.workEndTime}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (index) {
                              final dayName = AppConstants.weekDays[index];
                              final isWorking = _maid!.workingDays.contains(dayName);
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isWorking
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    AppConstants.weekDays[index],
                                    style: TextStyle(
                                      color: isWorking
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_maid!.languages.isNotEmpty) ...[
                      const Text(
                        'Languages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _maid!.languages.map((lang) {
                          return Chip(
                            label: Text(lang),
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                color: AppTheme.dividerColor),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews (${_reviews.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (_reviews.isNotEmpty)
                          RatingWidget(rating: _maid!.rating),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_reviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: const Center(
                          child: Text(
                            'No reviews yet. Be the first to hire and review!',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._reviews.map((review) => _ReviewTile(review: review)),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final authProvider = context.read<AuthProvider>();
          final householdId = authProvider.userModel?.uid;

          final isHired = bookingProvider.bookings.any((booking) =>
            booking.maidId == widget.maidId &&
            booking.householdId == householdId &&
            booking.status != BookingStatus.cancelled &&
            booking.status != BookingStatus.rejected
          );

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: isHired ? 'Hired' : 'Hire Now',
                onPressed: isHired ? null : () => _showHireBottomSheet(context),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHireBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _HireBottomSheet(maid: _maid!),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String price;
  final String period;
  final Color color;

  const _PriceCard({
    required this.label,
    required this.price,
    required this.period,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const _ReviewTile({required this.review});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: review.householdImage != null
                    ? NetworkImage(review.householdImage!)
                    : null,
                child: review.householdImage == null
                    ? const Icon(Icons.person,
                        size: 18, color: AppTheme.primaryColor)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.householdName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              RatingWidget(rating: review.rating),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.review,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HireBottomSheet extends StatefulWidget {
  final MaidProfileModel maid;

  const _HireBottomSheet({required this.maid});

  @override
  State<_HireBottomSheet> createState() => _HireBottomSheetState();
}

class _HireBottomSheetState extends State<_HireBottomSheet> {
  HiringType _hiringType = HiringType.hourly;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _services = <String>{};
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  final _hoursController = TextEditingController(text: '3');
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.maid.categories.isNotEmpty) {
      _services.add(widget.maid.categories.first.label);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    switch (_hiringType) {
      case HiringType.hourly:
        final hours = double.tryParse(_hoursController.text) ?? 1;
        return widget.maid.hourlyRate * hours;
      case HiringType.monthly:
        return widget.maid.monthlyRate;
      case HiringType.contract:
        final days = _endDate.difference(_startDate).inDays;
        final months = days / 30;
        return widget.maid.monthlyRate * months;
    }
  }

  Future<void> _submitBooking() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your address'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final booking = BookingModel(
      id: '',
      maidId: widget.maid.uid,
      householdId: auth.userModel!.uid,
      maidName: widget.maid.name,
      maidImage: widget.maid.profileImage,
      householdName: auth.userModel!.name,
      householdImage: auth.userModel!.profileImage,
      hiringType: _hiringType,
      status: BookingStatus.pending,
      services: _services.toList(),
      startDate: _startDate,
      endDate: _hiringType != HiringType.hourly ? _endDate : null,
      startTime: _hiringType == HiringType.hourly
          ? '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'
          : null,
      endTime: _hiringType == HiringType.hourly
          ? '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'
          : null,
      totalHours: _hiringType == HiringType.hourly
          ? double.tryParse(_hoursController.text)?.toInt()
          : null,
      totalPrice: _totalPrice,
      hourlyRate: widget.maid.hourlyRate,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
    );

    final success = await bookingProvider.createBooking(booking);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request sent successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushNamed(context, '/household/my-bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Maid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Hiring Type Selector
            const Text(
              'Hiring Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.maid.acceptsHourly)
                  Expanded(
                    child: _TypeChip(
                      label: 'Hourly',
                      isSelected: _hiringType == HiringType.hourly,
                      onTap: () =>
                          setState(() => _hiringType = HiringType.hourly),
                    ),
                  ),
                if (widget.maid.acceptsHourly && widget.maid.acceptsMonthly)
                  const SizedBox(width: 8),
                if (widget.maid.acceptsMonthly)
                  Expanded(
                    child: _TypeChip(
                      label: 'Monthly',
                      isSelected: _hiringType == HiringType.monthly,
                      onTap: () =>
                          setState(() => _hiringType = HiringType.monthly),
                    ),
                  ),
                if (widget.maid.acceptsContract) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeChip(
                      label: 'Contract',
                      isSelected: _hiringType == HiringType.contract,
                      onTap: () =>
                          setState(() => _hiringType = HiringType.contract),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Select Services
            const Text(
              'Select Services',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.maid.categories.map((cat) {
                return ServiceChip(
                  label: cat.label,
                  isSelected: _services.contains(cat.label),
                  small: true,
                  onTap: () {
                    setState(() {
                      if (_services.contains(cat.label)) {
                        _services.remove(cat.label);
                      } else {
                        _services.add(cat.label);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Payment Method Selector
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentSelector(),
            const SizedBox(height: 16),

            // Date & Time pickers based on Hiring Type
            if (_hiringType == HiringType.hourly) ...[
              Row(
                children: [
                  Expanded(
                    child: _DateSelector(
                      label: 'Date',
                      date: _startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _hoursController,
                      label: 'Hours',
                      hint: 'Enter hours',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _DateSelector(
                      label: 'Start Date',
                      date: _startDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateSelector(
                      label: 'End Date',
                      date: _endDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Address
            CustomTextField(
              controller: _addressController,
              label: 'Your Address',
              hint: 'Enter your full address',
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Special Instructions (Optional)',
              hint: 'Any specific instructions for the maid...',
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Total Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Rs. ${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Consumer<BookingProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Confirm Booking Request',
                  onPressed: _submitBooking,
                  isLoading: provider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Row(
      children: PaymentMethod.values.map((method) {
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _paymentMethod = method),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _paymentMethod == method
                    ? AppTheme.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _paymentMethod == method
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  method.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _paymentMethod == method
                        ? Colors.white
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Icon(Icons.calendar_today,
                    size: 18, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
