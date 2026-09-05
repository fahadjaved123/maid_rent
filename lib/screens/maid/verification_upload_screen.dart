import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/verification_request_model.dart';
import 'package:maid_rent/providers/auth_provider.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/custom_button.dart';
import 'package:maid_rent/widgets/custom_text_field.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'dart:io';

class VerificationUploadScreen extends StatefulWidget {
  const VerificationUploadScreen({super.key});

  @override
  State<VerificationUploadScreen> createState() => _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends State<VerificationUploadScreen> {
  final _cnicController = TextEditingController();
  File? _frontImage;
  File? _backImage;
  bool _isUploading = false;

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_cnicController.text.isEmpty || _frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide CNIC number and both images.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final auth = context.read<AuthProvider>();
      final maidProvider = context.read<MaidProvider>();

      // In a real app, we'd upload images to storage first and get URLs
      // For now, we'll simulate the upload and use the local paths as placeholders
      // or assume a storage service handles the file upload.

      final request = VerificationRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: auth.userModel!.uid,
        cnicNumber: _cnicController.text,
        frontImageUrl: _frontImage!.path, // Placeholder
        backImageUrl: _backImage!.path,   // Placeholder
        submittedAt: DateTime.now(),
      );

      final success = await maidProvider.submitVerification(request);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification request submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Submission failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Verify Your Account'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trust is everything',
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              'To keep our community safe, we require all service providers to verify their identity with a CNIC.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            CustomTextField(
              controller: _cnicController,
              label: 'CNIC Number',
              hint: 'e.g. 42101-XXXXXXX-X',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.spaceLg),

            const Text(
              'Identification Documents',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                Expanded(
                  child: _buildImagePicker(
                    label: 'Front Side',
                    image: _frontImage,
                    onTap: () => _pickImage(true),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: _buildImagePicker(
                    label: 'Back Side',
                    image: _backImage,
                    onTap: () => _pickImage(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),

            SizedBox(
              width: double.infinity,
              child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Submit for Verification',
                    onPressed: _submitVerification,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(label, style: AppTheme.labelMedium),
        const SizedBox(height: AppTheme.spaceXs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: AppTheme.onSurfaceVariant),
                      SizedBox(height: 8),
                      Text(
                        'Upload',
                        style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
