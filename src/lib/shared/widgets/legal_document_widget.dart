import 'package:flutter/material.dart';
import 'package:src/shared/models/legal_document.dart';

class LegalDocumentWidget extends StatelessWidget {
  final LegalDocument document;
  final Color? accentColor;

  const LegalDocumentWidget({
    super.key,
    required this.document,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Last updated banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: (accentColor ?? Theme.of(context).primaryColor).withOpacity(
              0.1,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.update,
                  size: 18,
                  color: accentColor ?? Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${document.lastUpdated}',
                  style: TextStyle(
                    color: accentColor ?? Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Document content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: document.sections.length,
              itemBuilder: (context, index) {
                final section = document.sections[index];
                return _buildSection(section, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Section section, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(section.content, style: Theme.of(context).textTheme.bodyLarge),
            if (section.bulletPoints != null) ...[
              const SizedBox(height: 12),
              ...section.bulletPoints!.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor ?? Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share'),
          content: const Text('Share this document via:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }
}
