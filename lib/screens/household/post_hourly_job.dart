import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/constants.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/hourly_post_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/household_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';
import 'package:maid_rent/widgets/service_chip.dart';

class PostHourlyJobScreen extends StatefulWidget {
  const PostHourlyJobScreen({super.key});

  @override
  State<PostHourlyJobScreen> createState() => _PostHourlyJobScreenState();
}

class _PostHourlyJobScreenState extends State<PostHourlyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController(text: '3');
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  final _selectedServices = <String>{};
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final householdProvider = context.read<HouseholdProvider>();

    final post = HourlyPostModel(
      id: '',
      householdId: auth.userModel!.uid,
      householdName: auth.userModel!.name,
      householdImage: auth.userModel!.profileImage,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      services: _selectedServices.toList(),
      date: _selectedDate,
      startTime:
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      endTime:
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      hours: (double.tryParse(_hoursController.text) ?? 1.0).toInt(),
      budget: double.parse(_budgetController.text),
      address: _addressController.text.trim(),
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : (auth.userModel!.location ?? 'Local Area'),
      status: PostStatus.open,
      applicantIds: [],
      createdAt: DateTime.now(),
    );

    final success = await householdProvider.createHourlyPost(post);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job post published successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/household/my-posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Hourly Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Post an urgent or hourly job. Available maids will be notified and can apply.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Job Title
            CustomTextField(
              controller: _titleController,
              label: 'Job Title',
              hint: 'e.g., Deep clean 2BHK apartment',
              prefixIcon: Icons.title,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 20),

            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe what needs to be done in detail...',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 24),

            // Services Needed
            const Text(
              'Services Needed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.serviceTypes.map((service) {
                return ServiceChip(
                  label: service,
                  isSelected: _selectedServices.contains(service),
                  onTap: () {
                    setState(() {
                      if (_selectedServices.contains(service)) {
                        _selectedServices.remove(service);
                      } else {
                        _selectedServices.add(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy')
                              .format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            color: AppTheme.primaryColor, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Time Range
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hours & Budget
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _hoursController,
                    label: 'Total Hours',
                    hint: '3',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _budgetController,
                    label: 'Budget (Rs)',
                    hint: '1500',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Address
            CustomTextField(
              controller: _addressController,
              label: 'Full Address',
              hint: 'Apartment, Street, Area...',
              prefixIcon: Icons.location_on_outlined,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter address' : null,
            ),
            const SizedBox(height: 20),

            // Area / Neighborhood
            CustomTextField(
              controller: _locationController,
              label: 'Area / Neighborhood (Optional)',
              hint: 'e.g., Gulberg, DHA Phase 5',
              prefixIcon: Icons.map_outlined,
            ),
            const SizedBox(height: 32),

            // Submit Button
            Consumer<HouseholdProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Publish Job Post',
                  onPressed: _submitPost,
                  isLoading: provider.isLoading,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Icon(Icons.access_time,
                    color: AppTheme.primaryColor, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
