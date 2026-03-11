import 'package:flutter/material.dart';
import 'package:src/shared/data/terms_of_service.dart';
import 'package:src/shared/widgets/legal_document_widget.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentWidget(
      document: TermsOfServiceData.terms,
      accentColor: Colors.blue,
    );
  }
}
