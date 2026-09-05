import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _imageFile;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final auth = context.read<AuthProvider>();
    if (auth.userModel != null) {
      _nameController.text = auth.userModel!.name;
      _emailController.text = auth.userModel!.email;
      _phoneController.text = auth.userModel!.phone ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    // TODO: Implement profile update logic
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.userModel == null) {
            return const Center(child: Text('User data not available'));
          }

          final isMaid = auth.userModel!.role == UserRole.maid;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : auth.userModel!.profileImage != null
                              ? NetworkImage(auth.userModel!.profileImage!)
                              : null,
                      child: _imageFile == null &&
                              auth.userModel!.profileImage == null
                          ? const Icon(Icons.person,
                              size: 60, color: AppTheme.primaryColor)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Badge
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMaid
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isMaid ? 'Maid' : 'Household',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isMaid
                          ? AppTheme.primaryColor
                          : AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 20),

              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                readOnly: !_isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Edit Profile Button for Maids
              if (isMaid && !_isEditing)
                CustomButton(
                  text: 'Edit Maid Profile',
                  onPressed: () => Navigator.pushNamed(
                      context, '/maid/profile-setup'),
                  isOutlined: true,
                ),
              if (isMaid && !_isEditing) const SizedBox(height: 12),

              // Save/Cancel Buttons
              if (_isEditing)
                Column(
                  children: [
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Cancel',
                      onPressed: () => setState(() {
                        _isEditing = false;
                        _loadUserData();
                      }),
                      isOutlined: true,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Account Stats
                    if (auth.userModel!.createdAt != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Member since ${auth.userModel!.createdAt!.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Logout Button
                    CustomButton(
                      text: 'Logout',
                      onPressed: _logout,
                      color: AppTheme.errorColor,
                      isOutlined: true,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
