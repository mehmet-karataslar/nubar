import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nubar/core/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════
// ── Shared Config Builder ──
// ═══════════════════════════════════════════════════════════════
class NubarQuillConfigBuilder {
  static QuillEditorConfig buildConfig({
    required BuildContext context,
    required String placeholder,
    EdgeInsets padding = const EdgeInsets.all(8),
    bool autoFocus = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return QuillEditorConfig(
      placeholder: placeholder,
      padding: padding,
      autoFocus: autoFocus,
      expands: true,
      customStyleBuilder: (Attribute attribute) {
        if (attribute.key == 'size' || attribute.key == 'customFontSize') {
          final val = attribute.value.toString();
          final size = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
          if (size != null) {
            return TextStyle(fontSize: size);
          }
        } else if (attribute.key == 'font') {
          return TextStyle(fontFamily: attribute.value.toString());
        }
        return const TextStyle();
      },
      customStyles: DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          tt.bodyLarge!.copyWith(
            fontSize: 18,
            height: 1.65,
            letterSpacing: 0.1,
          ),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(6, 0),
          const VerticalSpacing(0, 0),
          null,
        ),
        h1: DefaultTextBlockStyle(
          tt.headlineMedium!.copyWith(fontWeight: FontWeight.w800, height: 1.4),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(10, 6),
          const VerticalSpacing(0, 0),
          null,
        ),
        h2: DefaultTextBlockStyle(
          tt.titleLarge!.copyWith(fontWeight: FontWeight.w700, height: 1.4),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(8, 4),
          const VerticalSpacing(0, 0),
          null,
        ),
        h3: DefaultTextBlockStyle(
          tt.titleMedium!.copyWith(fontWeight: FontWeight.w600, height: 1.4),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(6, 2),
          const VerticalSpacing(0, 0),
          null,
        ),
        bold: const TextStyle(fontWeight: FontWeight.w800),
        italic: const TextStyle(fontStyle: FontStyle.italic),
        strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
        underline: const TextStyle(decoration: TextDecoration.underline),
        placeHolder: DefaultTextBlockStyle(
          tt.bodyLarge!.copyWith(
            fontSize: 18,
            color: cs.onSurface.withValues(alpha: 0.28),
            height: 1.65,
          ),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(0, 0),
          const VerticalSpacing(0, 0),
          null,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ── Shared Toolbar Widget ──
// ═══════════════════════════════════════════════════════════════
class NubarQuillToolbar extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final Widget? trailingAction;

  const NubarQuillToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.trailingAction,
  });

  @override
  State<NubarQuillToolbar> createState() => _NubarQuillToolbarState();
}

class _NubarQuillToolbarState extends State<NubarQuillToolbar> {
  String? _activeMenu;

  void _showFontFamilySheet(BuildContext context) {
    final fonts = [
      ('Inter', 'Inter'),
      ('Noto Sans Arabic', 'Noto Sans Arabic'),
      ('Roboto', 'Roboto'),
      ('serif', 'Serif'),
      ('monospace', 'Monospace'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.fontFamily,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...fonts.map(
                (f) => ListTile(
                  title: Text(f.$2, style: TextStyle(fontFamily: f.$1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Future.delayed(const Duration(milliseconds: 50), () {
                      widget.focusNode.requestFocus();
                      widget.controller.formatSelection(
                        Attribute.fromKeyValue('font', f.$1),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLinkDialog(BuildContext context) {
    final tController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bağlantı Ekle / Add Link'),
        content: TextField(
          controller: tController,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              if (tController.text.isNotEmpty) {
                final val = tController.text.startsWith('http')
                    ? tController.text
                    : 'https://${tController.text}';
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 50), () {
                  widget.focusNode.requestFocus();
                  widget.controller.formatSelection(LinkAttribute(val));
                });
              } else {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRow(ColorScheme cs) {
    final sizes = [8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28];
    return Row(
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () {
            widget.focusNode.requestFocus();
            setState(() => _activeMenu = null);
          },
        ),
        Container(width: 1, height: 24, color: cs.outlineVariant),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sizes.map((s) {
                return InkWell(
                  onTap: () {
                    widget.focusNode.requestFocus();
                    widget.controller.formatSelection(
                      Attribute.fromKeyValue('size', s.toDouble()),
                    );
                    setState(() => _activeMenu = null);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      '$s',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: _activeMenu == 'size'
              ? _buildSizeRow(cs)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuillFmtBtn(
                          controller: widget.controller,
                          attribute: Attribute.bold,
                          icon: Icons.format_bold_rounded,
                          baseColor: cs.primary,
                        ),
                        _QuillFmtBtn(
                          controller: widget.controller,
                          attribute: Attribute.italic,
                          icon: Icons.format_italic_rounded,
                          baseColor: cs.secondary,
                        ),
                        _QuillFmtBtn(
                          controller: widget.controller,
                          attribute: Attribute.underline,
                          icon: Icons.format_underlined_rounded,
                          baseColor: cs.tertiary,
                        ),
                        _QuillFmtBtn(
                          controller: widget.controller,
                          attribute: Attribute.strikeThrough,
                          icon: Icons.strikethrough_s_rounded,
                          baseColor: cs.error,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.leftAlignment,
                          icon: Icons.format_align_left_rounded,
                          baseColor: cs.primaryContainer,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.centerAlignment,
                          icon: Icons.format_align_center_rounded,
                          baseColor: cs.primaryContainer,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.rightAlignment,
                          icon: Icons.format_align_right_rounded,
                          baseColor: cs.primaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.h1,
                          icon: Icons.title_rounded,
                          baseColor: cs.secondary,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.h2,
                          icon: Icons.text_fields_rounded,
                          baseColor: cs.secondaryContainer,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.blockQuote,
                          icon: Icons.format_quote_rounded,
                          baseColor: cs.tertiary,
                        ),
                        _QuillBlockBtn(
                          controller: widget.controller,
                          attribute: Attribute.ul,
                          icon: Icons.format_list_bulleted_rounded,
                          baseColor: cs.primary,
                        ),
                        NubarQuillToolIcon(
                          icon: Icons.link_rounded,
                          onTap: () => _showLinkDialog(context),
                          baseColor: cs.tertiaryContainer,
                        ),
                        _QuillFontSizeBtn(
                          controller: widget.controller,
                          onTap: () {
                            setState(() => _activeMenu = 'size');
                          },
                          baseColor: cs.errorContainer,
                        ),
                        NubarQuillToolIcon(
                          icon: Icons.font_download_outlined,
                          onTap: () => _showFontFamilySheet(context),
                          baseColor: cs.secondary,
                        ),
                        if (widget.trailingAction != null)
                          widget.trailingAction!,
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ── Inline & Block Buttons ──
// ═══════════════════════════════════════════════════════════════

class _QuillFmtBtn extends StatefulWidget {
  final QuillController controller;
  final Attribute attribute;
  final IconData icon;
  final Color baseColor;

  const _QuillFmtBtn({
    required this.controller,
    required this.attribute,
    required this.icon,
    required this.baseColor,
  });

  @override
  State<_QuillFmtBtn> createState() => _QuillFmtBtnState();
}

class _QuillFmtBtnState extends State<_QuillFmtBtn> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final active = attrs.containsKey(widget.attribute.key);
    if (active != _isActive) {
      if (mounted) setState(() => _isActive = active);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isActive
          ? widget.baseColor.withValues(alpha: 0.15)
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          widget.controller.formatSelection(
            _isActive
                ? Attribute.clone(widget.attribute, null)
                : widget.attribute,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            widget.icon,
            size: 20,
            color: _isActive
                ? widget.baseColor
                : widget.baseColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _QuillBlockBtn extends StatefulWidget {
  final QuillController controller;
  final Attribute attribute;
  final IconData icon;
  final Color baseColor;

  const _QuillBlockBtn({
    required this.controller,
    required this.attribute,
    required this.icon,
    required this.baseColor,
  });

  @override
  State<_QuillBlockBtn> createState() => _QuillBlockBtnState();
}

class _QuillBlockBtnState extends State<_QuillBlockBtn> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final active = attrs[widget.attribute.key]?.value == widget.attribute.value;
    if (active != _isActive) {
      if (mounted) setState(() => _isActive = active);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isActive
          ? widget.baseColor.withValues(alpha: 0.15)
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          widget.controller.formatSelection(
            _isActive
                ? Attribute.clone(widget.attribute, null)
                : widget.attribute,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            widget.icon,
            size: 20,
            color: _isActive
                ? widget.baseColor
                : widget.baseColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _QuillFontSizeBtn extends StatefulWidget {
  final QuillController controller;
  final VoidCallback onTap;
  final Color baseColor;

  const _QuillFontSizeBtn({
    required this.controller,
    required this.onTap,
    required this.baseColor,
  });

  @override
  State<_QuillFontSizeBtn> createState() => _QuillFontSizeBtnState();
}

class _QuillFontSizeBtnState extends State<_QuillFontSizeBtn> {
  String _currentSize = '16';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final sizeAttr = attrs['customFontSize'] ?? attrs['size'];
    String sizeStr = '16';
    if (sizeAttr != null && sizeAttr.value != null) {
      final val = sizeAttr.value;
      if (val is double) {
        sizeStr = val.toInt().toString();
      } else if (val is int) {
        sizeStr = val.toString();
      } else if (val is String) {
        sizeStr = val.replaceAll(RegExp(r'[^0-9]'), '');
      }
    }

    if (sizeStr.isEmpty) sizeStr = '16';

    if (sizeStr != _currentSize) {
      if (mounted) setState(() => _currentSize = sizeStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Text(
                _currentSize,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.baseColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NubarQuillToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color baseColor;

  const NubarQuillToolIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? baseColor.withValues(alpha: 0.15)
          : Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: active ? baseColor : baseColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
