import 'package:src/shared/models/legal_document.dart';

class PrivacyPolicyData {
  static LegalDocument get privacyPolicy {
    return LegalDocument(
      title: 'Privacy Policy',
      lastUpdated: 'March 11, 2026',
      sections: [
        Section(
          title: '1. Introduction',
          content:
              'We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our app.',
        ),
        Section(
          title: '2. Information We Collect',
          content:
              'We collect several types of information to provide and improve our service to you:',
          bulletPoints: [
            'Personal Information: Name, email address, phone number',
            'Usage Data: How you interact with our app',
            'Device Information: Device type, OS version, unique identifiers',
            'Location Data: With your permission, we may collect location information',
          ],
        ),
        Section(
          title: '3. How We Use Your Information',
          content: 'We use the collected information for various purposes:',
          bulletPoints: [
            'To provide and maintain our service',
            'To notify you about changes to our service',
            'To provide customer support',
            'To gather analysis for service improvement',
            'To detect and prevent technical issues',
          ],
        ),
        Section(
          title: '4. Data Storage and Security',
          content:
              'We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
          bulletPoints: [
            'Data is encrypted during transmission',
            'We use secure servers for storage',
            'Regular security audits are performed',
            'Access is limited to authorized personnel only',
          ],
        ),
        Section(
          title: '5. Third-Party Services',
          content:
              'We may employ third-party companies and individuals for the following reasons:',
          bulletPoints: [
            'To facilitate our service',
            'To provide analytics (Google Analytics)',
            'To process payments',
            'To send push notifications',
          ],
        ),
        Section(
          title: '6. Your Data Rights',
          content:
              'Depending on your location, you may have the following rights regarding your personal data:',
          bulletPoints: [
            'Right to access your data',
            'Right to correct inaccurate data',
            'Right to delete your data',
            'Right to restrict processing',
            'Right to data portability',
          ],
        ),
        Section(
          title: '7. Children\'s Privacy',
          content:
              'Our service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.',
        ),
        Section(
          title: '8. Changes to This Policy',
          content:
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "last updated" date.',
        ),
        Section(
          title: '9. Contact Us',
          content:
              'If you have questions about this Privacy Policy, please contact us:',
          bulletPoints: [
            'Email: privacy@yourapp.com',
            'Address: 123 App Street, Tech City, TC 12345',
            'Data Protection Officer: dpo@yourapp.com',
          ],
        ),
      ],
    );
  }
}
