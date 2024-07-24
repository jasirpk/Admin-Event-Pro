import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/settings/more_data.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

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
    final String companyName = userData?['companyName'] ?? 'No Company';
    final String phoneNumber = userData?['phoneNumber'] ?? '+ 91-';
    final String emailAddress = userData?['emailAddress'] ?? 'No email';
    final String website = userData?['website'] ?? 'No website';
    final String description = userData?['description'] ?? 'No description';
    final List<dynamic> links = userData?['links'] ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(100)),
                      child: CircleAvatar(
                          maxRadius: 60,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : AssetImage(Assigns.personImage)
                                  as ImageProvider),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        maxRadius: 20,
                        backgroundColor: Colors.white,
                        child: IconButton(
                            onPressed: () {
                              Get.to(() {
                                return ProfileScreen(
                                  companyName: companyName,
                                  description: description,
                                  phoneNumber: phoneNumber,
                                  email: emailAddress,
                                  website: website,
                                );
                              });
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.black,
                            )),
                      ),
                    )
                  ],
                ),
                sizedboxWidth,
                Text(
                  companyName,
                  style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            sizedbox,
            Row(
              children: [
                Icon(
                  Icons.call,
                  color: Colors.white,
                ),
                sizedboxWidth,
                Text(
                  "Phone: $phoneNumber",
                ),
              ],
            ),
            sizedBoxSmall,
            Row(
              children: [
                Icon(
                  Icons.mail,
                  color: Colors.white,
                ),
                sizedboxWidth,
                Text(
                  emailAddress,
                ),
              ],
            ),
            MoreDataWidget(
                screenHeight: screenHeight,
                website: website,
                companyName: companyName,
                links: links,
                description: description),
            sizedbox,
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var data = items[index];
                return GestureDetector(
                  onTap: data['onTap'],
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        leading: Icon(
                          data['icon'],
                          color: Colors.white,
                        ),
                        title: Text(
                          data['text'],
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              CupertinoIcons.forward,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                );
              },
            ),
            sizedbox,
            Padding(
              padding: EdgeInsets.only(top: 60),
              child:
                  Text('Version 1.2.0', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
