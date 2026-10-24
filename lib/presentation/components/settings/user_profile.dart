import 'package:admineventpro/presentation/components/settings/settings_ui.dart';
import 'package:admineventpro/presentation/components/settings/more_data.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    super.key,
    required this.userData,
    required this.screenHeight,
    required this.items,
  });

  final Map<String, dynamic>? userData;
  final double screenHeight;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final String profileImage = userData?['profileImage'] ?? '';
    final String companyName = userData?['companyName'] ?? 'Not Registered';
    final String phoneNumber = userData?['phoneNumber'] ?? '';
    final String emailAddress = userData?['emailAddress'] ?? 'No email';
    final String website = userData?['website'] ?? 'No website';
    final String description = userData?['description'] ?? 'No description';
    final List<dynamic> links = userData?['links'] ?? [];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsHeader(
              imagePath: profileImage,
              name: companyName,
              subtitle: emailAddress,
              // Unchanged destination and arguments: without these the
              // editor started empty and saving replaced the whole
              // portfolio.
              onEdit: () => Get.to(() => ProfileScreen(
                    portfolio: profilePortfolioRefs(userData?['images']),
                    links: profileLinks(userData?['links']),
                    companyName: companyName,
                    description: description,
                    phoneNumber: phoneNumber,
                    email: emailAddress,
                    website: website,
                    imagePath: profileImage,
                  )),
            ),
            const SettingsSectionLabel('Contact'),
            SettingsMenuCard(
              rows: [
                SettingsRow(
                  icon: Icons.call,
                  label: phoneNumber.isEmpty ? 'No phone number' : phoneNumber,
                ),
                SettingsRow(
                  icon: Icons.mail,
                  label: emailAddress,
                ),
              ],
            ),
            // The company portfolio, unchanged.
            MoreDataWidget(
                screenHeight: screenHeight,
                website: website,
                companyName: companyName,
                links: links,
                description: description),
            for (final section in _sections)
              if (_rowsFor(section).isNotEmpty) ...[
                SettingsSectionLabel(section),
                SettingsMenuCard(rows: _rowsFor(section)),
              ],
            const SizedBox(height: 28),
            Center(
              child: Text('Version 1.0.0+3',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Section order. An item without a section falls into ABOUT, so an item
  /// added later still appears.
  static const List<String> _sections = ['ACCOUNT', 'ABOUT', 'DANGER'];

  /// The screen's own item maps, rendered as rows. `onTap` is passed straight
  /// through, so every destination stays exactly where it was defined.
  List<SettingsRow> _rowsFor(String section) {
    return items
        .where((item) => (item['section'] as String? ?? 'ABOUT') == section)
        .map((item) => SettingsRow(
              icon: item['icon'] as IconData,
              label: item['text'] as String,
              onTap: item['onTap'] as VoidCallback?,
              danger: section == 'DANGER',
            ))
        .toList();
  }
}
