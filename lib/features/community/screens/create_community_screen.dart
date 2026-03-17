import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/core/utils/validators.dart';
import 'package:nubar/features/community/providers/community_provider.dart';
import 'package:nubar/features/community/screens/community_feed_screen.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState
    extends ConsumerState<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_autoGenerateSlug);
  }

  void _autoGenerateSlug() {
    final name = _nameController.text;
    _slugController.text = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final community = await ref.read(communityActionsProvider).createCommunity(
            name: _nameController.text.trim(),
            slug: _slugController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            isPrivate: _isPrivate,
          );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityFeedScreen(communityId: community.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createCommunity),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NubarTextField(
                controller: _nameController,
                label: l10n.communities,
                hint: 'Kurdistan Books',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              NubarTextField(
                controller: _slugController,
                label: 'Slug',
                hint: 'kurdistan-books',
                validator: (value) => Validators.validateSlug(value?.trim()),
              ),
              const SizedBox(height: 16),

              NubarTextField(
                controller: _descriptionController,
                label: l10n.bio,
                hint: '...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Private'),
                subtitle: Text(
                  'Only members can see posts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              NubarButton(
                text: l10n.createCommunity,
                onPressed: _isLoading ? null : _createCommunity,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
