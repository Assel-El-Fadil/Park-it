import 'package:src/shared/models/legal_document.dart';

class TermsOfServiceData {
  static LegalDocument get terms {
    return LegalDocument(
      title: 'Terms of Service',
      lastUpdated: 'March 11, 2026',
      sections: [
        Section(
          title: '1. Acceptance of Terms',
          content:
              'By accessing or using our app, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with any part of these terms, you may not use our services.',
        ),
        Section(
          title: '2. User Accounts',
          content:
              'When you create an account with us, you must provide accurate and complete information. You are responsible for safeguarding your password and for all activities under your account.',
          bulletPoints: [
            'You must be at least 13 years old to use this service',
            'You are responsible for maintaining account security',
            'Notify us immediately of any unauthorized access',
            'We reserve the right to terminate accounts at our discretion',
          ],
        ),
        Section(
          title: '3. User Conduct',
          content:
              'You agree not to use the service for any unlawful purpose or in any way that could damage, disable, or impair our services.',
          bulletPoints: [
            'Do not post inappropriate or offensive content',
            'Do not attempt to gain unauthorized access',
            'Do not interfere with other users\' experience',
            'Do not use the service for spam or phishing',
          ],
        ),
        Section(
          title: '4. Intellectual Property',
          content:
              'The app and its original content, features, and functionality are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
        ),
        Section(
          title: '5. Termination',
          content:
              'We may terminate or suspend your account immediately, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties.',
        ),
        Section(
          title: '6. Limitation of Liability',
          content:
              'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
        ),
        Section(
          title: '7. Changes to Terms',
          content:
              'We reserve the right to modify these terms at any time. We will notify users of any material changes via the app or email. Continued use after changes constitutes acceptance.',
        ),
        Section(
          title: '8. Contact Information',
          content:
              'If you have any questions about these Terms, please contact us at:',
          bulletPoints: [
            'Email: support@park-it.com',
            'Address: 123 App Street, Tech City, TC 12345',
            'Phone: (555) 123-4567',
          ],
        ),
      ],
    );
  }
}
