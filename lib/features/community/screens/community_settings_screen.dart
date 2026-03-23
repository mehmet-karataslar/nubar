import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/l10n/app_localizations.dart';
import 'package:nubar/features/community/providers/community_provider.dart';
import 'package:nubar/shared/widgets/loading_indicator.dart';
import 'package:nubar/shared/widgets/nubar_button.dart';
import 'package:nubar/shared/widgets/nubar_text_field.dart';

class CommunitySettingsScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunitySettingsScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunitySettingsScreen> createState() =>
      _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState
    extends ConsumerState<CommunitySettingsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(communityActionsProvider)
          .updateCommunity(
            communityId: widget.communityId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            isPrivate: _isPrivate,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityAsync = ref.watch(
      communityDetailProvider(widget.communityId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communitySettings),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: communityAsync.when(
        data: (community) {
          if (!_initialized) {
            _nameController.text = community.name;
            _descriptionController.text = community.description ?? '';
            _isPrivate = community.isPrivate;
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NubarTextField(
                  controller: _nameController,
                  label: l10n.communities,
                ),
                const SizedBox(height: 16),
                NubarTextField(
                  controller: _descriptionController,
                  label: l10n.bio,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Private'),
                  value: _isPrivate,
                  onChanged: (value) => setState(() => _isPrivate = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Members section
                Text(
                  l10n.memberCount(community.memberCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Leave community
                NubarButton(
                  text: l10n.leaveCommunity,
                  isOutlined: true,
                  width: double.infinity,
                  onPressed: () async {
                    await ref
                        .read(communityActionsProvider)
                        .leaveCommunity(widget.communityId);
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(child: Text(l10n.error)),
      ),
    );
  }
}
