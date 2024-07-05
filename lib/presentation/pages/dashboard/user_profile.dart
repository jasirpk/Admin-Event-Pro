import 'dart:io';

import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/auth_bloc/manage_bloc.dart';
import 'package:admineventpro/data_layer/profile/profile_bloc.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:admineventpro/presentation/components/ui/single_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileBloc? _profileBoloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileBoloc = context.read<ProfileBloc>();
  }

  @override
  void dispose() {
    _profileBoloc?.add(ClearImages());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    TextEditingController companyNameController = TextEditingController();
    TextEditingController descriptionEditingController =
        TextEditingController();

    TextEditingController PhoneEditingController = TextEditingController();
    TextEditingController EmailAddressContrller = TextEditingController();
    TextEditingController WebsiteEditingContrller = TextEditingController();
    List<TextEditingController> mediaEdingControllers = [];
    File? image;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            int? itemCount = 0;
            List<File?>? images;
            int? fieldCount = 0;

            if (state is GeneratedInitial) {
              itemCount = state.listViewCount;
              fieldCount = state.fieldCount;
              images = state.pickedImages;
              image = state.pickImage;

              if (mediaEdingControllers.isEmpty) {
                mediaEdingControllers = List.generate(
                  fieldCount,
                  (index) => TextEditingController(),
                );
              }
            }
            if (state is ImagePickerInitial) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Assigns.profileDetails,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * (34 / screenHeight),
                              letterSpacing: 1)),
                      SingleTextWidget(
                          text: Assigns.profileText,
                          screenHeight: screenHeight),
                      sizedbox,
                      SingleTextWidget(
                          screenHeight: screenHeight,
                          text: Assigns.profileDetails),
                      SizedBox(height: 10),
                      CustomTextFieldWidget(
                        controller: companyNameController,
                        labelText: 'Company Name',
                      ),
                      SizedBox(height: 10),
                      CustomTextFieldWidget(
                        controller: descriptionEditingController,
                        labelText: 'About Us',
                        maxLine: 4,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          context.read<ProfileBloc>().add(PickImage());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                              image: image != null
                                  ? DecorationImage(
                                      image: FileImage(image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                          child: Center(
                            child: Icon(
                              image == null
                                  ? Icons.collections_bookmark
                                  : Icons.edit,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.16,
                        ),
                      ),
                      sizedbox,
                      SingleTextWidget(
                          screenHeight: screenHeight,
                          text: Assigns.contactInformation),
                      SizedBox(height: 10),
                      CustomTextFieldWidget(
                        controller: PhoneEditingController,
                        labelText: 'Phone Number',
                      ),
                      SizedBox(height: 10),
                      CustomTextFieldWidget(
                        controller: EmailAddressContrller,
                        labelText: 'Email Address',
                      ),
                      SizedBox(height: 10),
                      CustomTextFieldWidget(
                        controller: WebsiteEditingContrller,
                        labelText: 'Website',
                      ),
                      SizedBox(height: 10),
                      CustomTextWithIconsWidget(
                          screenHeight: screenHeight,
                          text: Assigns.socialMedia,
                          onAddpressed: () {
                            context.read<ProfileBloc>().add(AddMoreFields());
                          },
                          onRemovePressed: () {
                            context.read<ProfileBloc>().add(Reducefield());
                          }),
                      sizedbox,
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: fieldCount,
                        itemBuilder: (context, index) {
                          if (mediaEdingControllers.length <= index) {
                            mediaEdingControllers.add(TextEditingController());
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CustomTextFieldWidget(
                              controller: mediaEdingControllers[index],
                              labelText: 'link',
                            ),
                          );
                        },
                      ),
                      sizedbox,
                      CustomTextWithIconsWidget(
                          screenHeight: screenHeight,
                          text: Assigns.portFolio,
                          onAddpressed: () {
                            context.read<ProfileBloc>().add(IncreamentEvent());
                          },
                          onRemovePressed: () {
                            context.read<ProfileBloc>().add(DecrementEvent());
                          }),
                      SizedBox(height: 10),
                      Container(
                        height: screenHeight * 0.3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            return Container(
                              width: screenWidth * 0.4,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<ProfileBloc>()
                                            .add(PickImageEvent(index));
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey,
                                              image: images != null &&
                                                      images[index] != null
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                          images[index]!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                images == null ||
                                                        images[index] == null
                                                    ? Icons.collections_bookmark
                                                    : Icons.edit,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            width: screenWidth * 0.4,
                                            height: screenHeight * 0.16,
                                          ),
                                          if (images != null &&
                                              images[index] != null)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.black,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    context
                                                        .read<ProfileBloc>()
                                                        .add(RemoveImageEvent(
                                                            index));
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
