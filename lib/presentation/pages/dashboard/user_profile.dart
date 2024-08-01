import 'dart:io';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/presentation/components/profile_form/user_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final String? companyName;
  final String? description;
  final String? website;
  final String? phoneNumber;
  final String? email;
  final String? imagePath;

  const ProfileScreen({
    super.key,
    this.companyName,
    this.description,
    this.website,
    this.phoneNumber,
    this.email,
    this.imagePath,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController websiteEditingController = TextEditingController();
  List<TextEditingController> fields = [];
  File? image;
  ProfileBloc? _profileBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileBloc = context.read<ProfileBloc>();
  }

  @override
  void dispose() {
    _profileBloc?.add(ClearImages());
    companyNameController.dispose();
    descriptionEditingController.dispose();
    phoneEditingController.dispose();
    emailAddressController.dispose();
    websiteEditingController.dispose();
    fields.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void initState() {
    companyNameController.text = widget.companyName ?? '';
    descriptionEditingController.text = widget.description ?? '';
    phoneEditingController.text = widget.phoneNumber ?? '';
    emailAddressController.text = widget.email ?? '';
    websiteEditingController.text = widget.website ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile Created Successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          int? itemCount = 0;
          List<File?>? images;
          int? fieldCount = 0;

          if (state is GeneratedInitial) {
            itemCount = state.listViewCount;
            fieldCount = state.fieldCount;
            images = state.pickedImages;
            image = state.pickImage;

            fields = state.pickedFields;

            if (fields.isEmpty) {
              fields = List.generate(
                fieldCount,
                (index) => TextEditingController(),
              );
            }
          }

          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: User_FieldsWidget(
                profileImage: widget.imagePath ?? '',
                screenHeight: screenHeight,
                companyNameController: companyNameController,
                descriptionEditingController: descriptionEditingController,
                image: image,
                screenWidth: screenWidth,
                phoneEditingController: phoneEditingController,
                emailAddressController: emailAddressController,
                websiteEditingController: websiteEditingController,
                fieldCount: fieldCount,
                fields: fields,
                itemCount: itemCount,
                images: images,
                onSavePressed: () {
                  String companyName = companyNameController.text;
                  String about = descriptionEditingController.text;
                  String? imagePath =
                      image != null ? image!.path : widget.imagePath;
                  String phoneNumber = phoneEditingController.text;
                  String emailAddress = emailAddressController.text;
                  String website = websiteEditingController.text;
                  List<Map<String, dynamic>> links = fields.map((controller) {
                    return {'link': controller.text};
                  }).toList();
                  List<Map<String, dynamic>> medias = images?.map((imageFile) {
                        return {'image': imageFile?.path};
                      }).toList() ??
                      [];

                  if (companyName.isNotEmpty &&
                      about.isNotEmpty &&
                      imagePath != null &&
                      phoneNumber.length == 10 &&
                      emailAddress.contains('@gmail.com') &&
                      website.isNotEmpty &&
                      links.isNotEmpty &&
                      medias.isNotEmpty) {
                    double rating = 0.0;
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      context.read<ProfileBloc>().add(SaveProfile(
                          uid: user.uid,
                          companyName: companyName,
                          about: about,
                          imagePath: imagePath,
                          phoneNumber: phoneNumber,
                          emailAddress: emailAddress,
                          website: website,
                          images: medias,
                          links: links,
                          rating: rating));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Please fill all the required fields')));
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
