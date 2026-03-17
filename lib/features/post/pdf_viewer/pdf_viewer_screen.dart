import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'PDF'),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'first':
                  _pdfController.jumpToPage(1);
                  break;
                case 'last':
                  _pdfController.jumpToPage(_totalPages);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'first',
                child: Text('First page'),
              ),
              const PopupMenuItem(
                value: 'last',
                child: Text('Last page'),
              ),
            ],
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
        controller: _pdfController,
        onDocumentLoaded: (details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (details) {
          setState(() {
            _currentPage = details.newPageNumber - 1;
          });
        },
      ),
    );
  }
}
