import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:admineventpro/presentation/pages/auth/sign_in.dart';
import 'package:admineventpro/presentation/pages/dashboard/cover_images.dart';
import 'package:admineventpro/presentation/pages/dashboard/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> items = [
      {'icon': Icons.share, 'text': 'Share this App', 'onTap': () {}},
      {'icon': Icons.feedback, 'text': 'Feedback', 'onTap': () {}},
      {
        'icon': Icons.collections_bookmark,
        'text': 'Cover Images',
        'onTap': () {
          Get.to(() => CoverImages());
        }
      },
      {
        'icon': Icons.logout,
        'text': 'Exit Application',
        'onTap': () {
          context.read<ManageBloc>().add(Logout());
          context.read<ManageBloc>().add(SignOutWithGoogle());
          context.read<ManageBloc>().add(SignOutWithFacebook());
        }
      },
    ];
    return BlocListener<ManageBloc, ManageState>(
      listener: (context, state) {
        if (state is UnAthenticated) {
          Get.off(() => GoogleAuthScreen());
        } else if (state is AuthenticatedErrors) {
          Get.snackbar('Logout Error', state.message,
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            PopupMenuButton(
                color: Colors.white,
                iconColor: Colors.white,
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<ManageBloc>().add(Logout());
                    context.read<ManageBloc>().add(SignOutWithGoogle());
                    context.read<ManageBloc>().add(SignOutWithFacebook());
                  } else if (value == 'profile') {
                    Get.to(() {
                      return ProfileScreen();
                    });
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(Assigns.terms),
                      value: 'terms',
                    ),
                    PopupMenuItem(
                      child: Text(Assigns.privacy),
                      value: 'privacy',
                    ),
                    PopupMenuItem(
                      child: Text(Assigns.profile),
                      value: 'profile',
                    ),
                    PopupMenuItem(
                      child: Text(Assigns.logout),
                      value: 'logout',
                    ),
                  ];
                }),
            sizedboxWidth,
          ],
        ),
        body: FutureBuilder(
          future: UserProfile().getUserProfile(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
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
                                backgroundImage: NetworkImage(userData[
                                        'profileImage'] ??
                                    'assets/images/Circle-icons-profile.svg.png'),
                              ),
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
                                          companyName: userData['companyName'],
                                          description: userData['description'],
                                          phoneNumber: userData['phoneNumber'],
                                          email: userData['emailAddress'],
                                          website: userData['website'],
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
                          userData['companyName'],
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
                          "Phone: ${userData['phoneNumber']}",
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
                          userData['emailAddress'],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      tilePadding: EdgeInsets.only(left: 6, right: 260),
                      leading: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      title: Text(
                        'More',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.014),
                      ),
                      backgroundColor: Colors.black,
                      children: <Widget>[
                        ListTile(
                          title: Row(
                            children: [
                              Icon(
                                Icons.link,
                                color: Colors.white,
                              ),
                              sizedboxWidth,
                              Flexible(
                                child: Text(
                                  'Website:${userData['website']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.white,
                              ),
                              sizedboxWidth,
                              Text(
                                'Company: ${userData['companyName']}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text('Social Media Links:',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Container(
                          height: 160,
                          child: ListView.builder(
                              itemCount: userData['links'].length,
                              itemBuilder: (context, index) {
                                var link = userData['links'][index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.link,
                                      ),
                                      title: Text(
                                        link['link'],
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: screenHeight * 0.014,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.blue),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        ListTile(
                          title: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.white,
                              ),
                              sizedboxWidth,
                              Flexible(
                                child: Text(
                                  'Additional Info: ${userData['description']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    sizedbox,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (contex, index) {
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
                      padding: const EdgeInsets.only(top: 60),
                      child: Text('Version 1.2.0',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
