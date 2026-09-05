import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/constants.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/service_category.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';
import 'package:maid_rent/widgets/service_chip.dart';

class MaidProfileSetupScreen extends StatefulWidget {
  const MaidProfileSetupScreen({super.key});

  @override
  State<MaidProfileSetupScreen> createState() => _MaidProfileSetupScreenState();
}

class _MaidProfileSetupScreenState extends State<MaidProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _monthlyRateController = TextEditingController();

  File? _imageFile;
  final _selectedCategories = <ServiceCategory>{};
  final _selectedSpecializedServices = <String>{};
  final _selectedLanguages = <String>{};
  final _workingDays = List.generate(7, (i) => true);
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _acceptsHourly = true;
  bool _acceptsMonthly = true;
  bool _acceptsContract = false;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final auth = context.read<AuthProvider>();
    final maidProvider = context.read<MaidProvider>();
    await maidProvider.loadMaidProfile(auth.userModel!.uid);

    if (maidProvider.maidProfile != null) {
      setState(() {
        _isEditing = true;
        final profile = maidProvider.maidProfile!;
        _bioController.text = profile.bio;
        _experienceController.text = profile.experienceYears.toString();
        _hourlyRateController.text = profile.hourlyRate.toString();
        _monthlyRateController.text = profile.monthlyRate.toString();
        _selectedCategories.addAll(profile.categories);
        _selectedSpecializedServices.addAll(profile.specializedServices);
        _selectedLanguages.addAll(profile.languages);
        for (int i = 0; i < profile.workingDays.length && i < 7; i++) {
          final dayName = profile.workingDays[i];
          final dayIndex = AppConstants.weekDays.indexOf(dayName);
          if (dayIndex >= 0 && dayIndex < 7) {
            _workingDays[dayIndex] = true;
          }
        }
        _startTime = TimeOfDay(
          hour: int.parse(profile.workStartTime.split(':')[0]),
          minute: int.parse(profile.workStartTime.split(':')[1]),
        );
        _endTime = TimeOfDay(
          hour: int.parse(profile.workEndTime.split(':')[0]),
          minute: int.parse(profile.workEndTime.split(':')[1]),
        );
        _acceptsHourly = profile.acceptsHourly;
        _acceptsMonthly = profile.acceptsMonthly;
        _acceptsContract = profile.acceptsContract;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _monthlyRateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final maidProvider = context.read<MaidProvider>();

    final selectedDays = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_workingDays[i]) {
        selectedDays.add(AppConstants.weekDays[i]);
      }
    }

    final profile = MaidProfileModel(
      uid: auth.userModel!.uid,
      name: auth.userModel!.name,
      bio: _bioController.text.trim(),
      categories: _selectedCategories.toList(),
      specializedServices: _selectedSpecializedServices.toList(),
      hourlyRate: double.parse(_hourlyRateController.text),
      monthlyRate: double.parse(_monthlyRateController.text),
      rating: maidProvider.maidProfile?.rating ?? 0.0,
      totalReviews: maidProvider.maidProfile?.totalReviews ?? 0,
      completedJobs: maidProvider.maidProfile?.completedJobs ?? 0,
      isAvailable: maidProvider.maidProfile?.isAvailable ?? true,
      acceptsHourly: _acceptsHourly,
      acceptsMonthly: _acceptsMonthly,
      acceptsContract: _acceptsContract,
      workingDays: selectedDays,
      workStartTime:
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      workEndTime:
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      experienceYears: int.parse(_experienceController.text),
      languages: _selectedLanguages.toList(),
      createdAt: maidProvider.maidProfile?.createdAt ?? DateTime.now(),
    );

    await maidProvider.saveMaidProfile(profile);

    if (_imageFile != null) {
      await maidProvider.uploadProfileImage(auth.userModel!.uid, _imageFile!);
    }

    if (mounted) {
      if (_isEditing) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/maid/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Setup Profile'),
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : context.watch<AuthProvider>().userModel?.profileImage != null
                            ? NetworkImage(context.read<AuthProvider>().userModel!.profileImage!)
                            : null,
                    child: _imageFile == null &&
                            context.watch<AuthProvider>().userModel?.profileImage == null
                        ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell households about yourself',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a bio' : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'Service Categories',
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
              children: ServiceCategory.values.map((cat) {
                return ServiceChip(
                  label: cat.label,
                  isSelected: _selectedCategories.contains(cat),
                  onTap: () {
                    setState(() {
                      if (_selectedCategories.contains(cat)) {
                        _selectedCategories.remove(cat);
                      } else {
                        _selectedCategories.add(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Specialized Services based on selected categories
            if (_selectedCategories.isNotEmpty) ...[
              const Text(
                'Specialized Services',
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
                children: _selectedCategories
                    .expand((cat) => cat.subServices)
                    .map((service) {
                  return ServiceChip(
                    label: service,
                    isSelected: _selectedSpecializedServices.contains(service),
                    onTap: () {
                      setState(() {
                        if (_selectedSpecializedServices.contains(service)) {
                          _selectedSpecializedServices.remove(service);
                        } else {
                          _selectedSpecializedServices.add(service);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _hourlyRateController,
                    label: 'Hourly Rate (Rs)',
                    hint: '0',
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
                    controller: _monthlyRateController,
                    label: 'Monthly Rate (Rs)',
                    hint: '0',
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
            CustomTextField(
              controller: _experienceController,
              label: 'Years of Experience',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (int.tryParse(value!) == null) return 'Invalid';
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Languages',
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
              children: AppConstants.languages.map((lang) {
                return ServiceChip(
                  label: lang,
                  isSelected: _selectedLanguages.contains(lang),
                  small: true,
                  onTap: () {
                    setState(() {
                      if (_selectedLanguages.contains(lang)) {
                        _selectedLanguages.remove(lang);
                      } else {
                        _selectedLanguages.add(lang);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Working Days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _workingDays[index] = !_workingDays[index]),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _workingDays[index]
                          ? AppTheme.primaryColor
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        AppConstants.weekDays[index],
                        style: TextStyle(
                          color: _workingDays[index]
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TimeSelector(
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
                  child: _TimeSelector(
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
            const SizedBox(height: 24),
            const Text(
              'Available For',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Hourly Jobs'),
              value: _acceptsHourly,
              onChanged: (val) => setState(() => _acceptsHourly = val!),
              activeColor: AppTheme.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Monthly Basis'),
              value: _acceptsMonthly,
              onChanged: (val) => setState(() => _acceptsMonthly = val!),
              activeColor: AppTheme.primaryColor,
            ),
            CheckboxListTile(
              title: const Text('Contract Basis'),
              value: _acceptsContract,
              onChanged: (val) => setState(() => _acceptsContract = val!),
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 32),
            Consumer<MaidProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: _isEditing ? 'Save Changes' : 'Complete Setup',
                  onPressed: _saveProfile,
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

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSelector({
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
