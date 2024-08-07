import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';

class TermsOfServices extends StatelessWidget {
  const TermsOfServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Terms of Service'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service for Admin Event Pro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '''1. Introduction
Welcome to Admin Event Pro, an event management entrepreneur application developed by an individual developer. By using Admin Event Pro, you agree to comply with and be bound by the following terms and conditions. If you do not agree to these terms, please do not use our application.

2. Developer Information
Admin Event Pro is developed and maintained by an individual developer. For any inquiries, please contact us at jasijasu@gmail.com.

3. Application Purpose
Admin Event Pro is designed to help entrepreneurs manage their event-related services and vendors. Entrepreneurs can add vendor details, services, and experiences, which will be displayed on the Event Master application for clients who need to manage their events.

4. Data Collection and Usage
We collect the following information from entrepreneurs:

- Company credentials, including contact information, email, social media links, media, and descriptions.

This data is collected to provide a comprehensive profile for clients using the Event Master application. Your data will not be shared with third-party services and will be stored securely.

5. Authentication
Admin Event Pro uses email and password authentication, as well as Google Sign-In for user authentication.

6. Features
Admin Event Pro includes the following features:

- Chatbot for client communication
- Budget tracker
- Vendor templates for easy form filling
- Local information based on client application installation
- Favorites for vendor templates
- Search queries
- Checklists for event management

7. Data Validation
After adding a vendor or service, the developer will validate the information through a website before it is displayed on the client side. If the data is not deemed trustworthy, it will be rejected.

8. Security
Your data is stored securely, and we take appropriate measures to protect it. However, it is your responsibility to use the features of this application safely and not misuse them.

9. No Payment Features
Admin Event Pro does not include any payment features. Payments are discussed and handled directly between the entrepreneur and the client.

10. User Responsibilities
Users are required to use the features of this application responsibly. Misuse of any feature is strictly prohibited.

11. Acceptance of Terms
By using Admin Event Pro, you agree to these terms of service. Only users who accept these terms are authorized to use this application.

12. Modifications to Terms
We reserve the right to modify these terms at any time. Any changes will be posted on this page, and your continued use of Admin Event Pro constitutes your acceptance of the modified terms.

13. Contact Us
If you have any questions or concerns about these terms, please contact us at jasijasu@gmail.com.

Effective Date: [03 - 08 - 2024]
              ''',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
