import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubar/core/constants/app_constants.dart';
import 'package:nubar/core/constants/backblaze_constants.dart';
import 'package:nubar/features/auth/models/auth_model.dart';
import 'package:nubar/features/profile/providers/profile_provider.dart';
import 'package:nubar/shared/services/backblaze_service.dart';
import 'package:nubar/shared/widgets/nubar_avatar.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _locationController;
  final _imagePicker = ImagePicker();
  File? _selectedAvatar;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _websiteController = TextEditingController(text: widget.user.website ?? '');
    _locationController =
        TextEditingController(text: widget.user.location ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedAvatar = File(image.path));
    }
  }

  Future<void> _handleSave() async {
    String? avatarUrl;
    if (_selectedAvatar != null) {
      setState(() => _uploadingAvatar = true);
      try {
        final path = BackblazeConstants.avatarPath(widget.user.id);
        avatarUrl = await BackblazeService.uploadFile(
          file: _selectedAvatar!,
          path: path,
          contentType: 'image/jpeg',
        );
      } finally {
        if (mounted) setState(() => _uploadingAvatar = false);
      }
    }

    ref.read(profileActionsProvider.notifier).updateProfile(
          userId: widget.user.id,
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
          website: _websiteController.text.trim(),
          location: _locationController.text.trim(),
          avatarUrl: avatarUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actionsState = ref.watch(profileActionsProvider);

    ref.listen(profileActionsProvider, (_, state) {
      state.whenOrNull(
        data: (_) => Navigator.pop(context),
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          TextButton(
            onPressed: actionsState.isLoading ? null : _handleSave,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  _selectedAvatar != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(_selectedAvatar!),
                        )
                      : NubarAvatar(
                          imageUrl: widget.user.avatarUrl,
                          radius: 50,
                          fallbackText: widget.user.fullName,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  if (_uploadingAvatar)
                    const Positioned.fill(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full name
            NubarTextField(
              controller: _fullNameController,
              label: l10n.fullName,
              prefixIcon: Icons.person_outlined,
            ),
            const SizedBox(height: 16),

            // Bio
            NubarTextField(
              controller: _bioController,
              label: l10n.bio,
              prefixIcon: Icons.info_outlined,
              maxLines: 3,
              maxLength: AppConstants.maxBioLength,
            ),
            const SizedBox(height: 16),

            // Website
            NubarTextField(
              controller: _websiteController,
              label: l10n.website,
              prefixIcon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Location
            NubarTextField(
              controller: _locationController,
              label: l10n.location,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 32),

            NubarButton(
              text: l10n.save,
              onPressed: _handleSave,
              isLoading: actionsState.isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
