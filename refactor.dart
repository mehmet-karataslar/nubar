import 'dart:io';

void main() {
  processCreatePost();
  processStudioArticle();
}

void processCreatePost() {
  final file = File('lib/features/post/create/create_post_screen.dart');
  final lines = file.readAsLinesSync();
  final out = <String>[];

  bool skipConfig = false;
  bool skipMethods = false;
  bool skipToolbar = false;
  bool skipBottomClasses = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Import
    if (line ==
        "import 'package:nubar/features/post/create/create_post_provider.dart';") {
      out.add(line);
      out.add(
        "import 'package:nubar/shared/widgets/nubar_quill_toolbar.dart';",
      );
      continue;
    }

    // Font size state
    if (line == '  // Font size') {
      i += 2; // skip this and next 2 lines
      continue;
    }

    // Methods
    if (line == '  void _changeFontSize(double size) {') {
      skipMethods = true;
    }
    if (skipMethods) {
      if (line == '  void _handlePost() {') {
        skipMethods = false;
      } else {
        continue;
      }
    }

    // Config
    if (line.contains('config: QuillEditorConfig(')) {
      skipConfig = true;
      out.add('                  config: NubarQuillConfigBuilder.buildConfig(');
      out.add('                    context: context,');
      out.add('                    placeholder: l10n.writePost,');
      out.add(
        '                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 80),',
      );
      out.add('                    autoFocus: true,');
      out.add('                  ),');
      continue;
    }
    if (skipConfig) {
      if (line.contains('                ),') &&
          lines[i + 1].contains('              ),') &&
          lines[i + 2].contains('            ),')) {
        // end of config block is around here.
        // Actually, let's just look for the end of the QuillEditor construct
        if (line == '                ),') {
          final prev = lines[i - 1];
          if (prev == '                    ),') {
            skipConfig = false;
            continue;
          }
        }
      }
      if (skipConfig) {
        if (line == '                  ),') {
          if (lines[i - 1] == '                    ),') {
            skipConfig = false;
            continue; // skipped `),`
          }
        }
      }
      // a simpler way: just check if line is `                  ),` but wait...
    }

    // Config simplified skip:
    if (skipConfig) {
      if (line == '                ),') {
        // End of QuillEditor
        skipConfig = false;
        out.add(line);
      }
      continue;
    }

    // Toolbar
    if (line.contains('// ── Bottom formatting toolbar ──')) {
      skipToolbar = true;
      out.add('            // ── Bottom formatting toolbar ──');
      out.add('            NubarQuillToolbar(');
      out.add('              controller: _quillController,');
      out.add('              trailingAction: NubarQuillToolIcon(');
      out.add(
        '                icon: _showMediaBar ? Icons.close_rounded : Icons.add_circle_outline_rounded,',
      );
      out.add('                onTap: _toggleMediaBar,');
      out.add('                active: _showMediaBar,');
      out.add('                baseColor: Colors.deepOrange,');
      out.add('              ),');
      out.add('            ),');
      continue;
    }
    if (skipToolbar) {
      if (line == '          ],') {
        // end of Column
        skipToolbar = false;
        out.add(line);
      }
      continue;
    }

    // Bottom classes
    if (line == '  void _showLinkDialog() {') {
      skipBottomClasses = true;
      continue;
    }

    if (skipBottomClasses) {
      if (line == 'class _MediaBtn extends StatelessWidget {') {
        skipBottomClasses = false;
        out.add(
          '// ═══════════════════════════════════════════════════════════════',
        );
        out.add('// ── Media button for expandable bar ──');
        out.add(
          '// ═══════════════════════════════════════════════════════════════',
        );
        out.add('');
        out.add(line);
      } else {
        continue;
      }
    }

    out.add(line);
  }

  file.writeAsStringSync(out.join('\n'));
}

void processStudioArticle() {
  final file = File(
    'lib/features/post/studio/screens/studio_article_screen.dart',
  );
  final lines = file.readAsLinesSync();
  final out = <String>[];

  bool skipConfig = false;
  bool skipToolbar = false;
  bool skipBottomClasses = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line ==
        "import 'package:nubar/features/post/studio/providers/studio_provider.dart';") {
      out.add(line);
      out.add(
        "import 'package:nubar/shared/widgets/nubar_quill_toolbar.dart';",
      );
      continue;
    }

    // Config
    if (line.contains('config: quill.QuillEditorConfig(')) {
      skipConfig = true;
      out.add('                config: NubarQuillConfigBuilder.buildConfig(');
      out.add('                  context: context,');
      out.add('                  placeholder: l10n.articleBodyHint,');
      out.add(
        '                  padding: const EdgeInsets.only(bottom: 80, top: 10),',
      );
      out.add('                  autoFocus: false,');
      out.add('                ),');
      continue;
    }
    if (skipConfig) {
      if (line == '              ),') {
        if (lines[i + 1] == '            ),') {
          skipConfig = false;
        }
      }
      continue;
    }

    // Toolbar
    if (line == '      bottomNavigationBar: Container(') {
      skipToolbar = true;
      out.add('      bottomNavigationBar: NubarQuillToolbar(');
      out.add('        controller: _quillController,');
      out.add('      ),');
      continue;
    }
    if (skipToolbar) {
      if (line == '      ),') {
        if (lines[i + 1] == '    ),') {
          skipToolbar = false;
        }
      }
      continue;
    }

    // Bottom classes
    if (line ==
        '// ═══════════════════════════════════════════════════════════════') {
      if (lines[i + 1] == '// ── Quill inline format toggle button ──') {
        skipBottomClasses = true;
      }
    }
    if (skipBottomClasses) {
      continue;
    }

    out.add(line);
  }

  file.writeAsStringSync(out.join('\n'));
}
