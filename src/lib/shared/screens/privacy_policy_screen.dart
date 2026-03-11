import 'package:flutter/material.dart';
import 'package:src/shared/data/privacy_policy.dart';
import 'package:src/shared/widgets/legal_document_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentWidget(
      document: PrivacyPolicyData.privacyPolicy,
      accentColor: Colors.blue,
    );
  }
}
