import 'dart:io';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/presentation/components/profile_form/link_fields.dart';
import 'package:admineventpro/presentation/components/profile_form/medias.dart';
import 'package:admineventpro/presentation/components/profile_form/profile_image.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/single_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class User_FieldsWidget extends StatelessWidget {
  const User_FieldsWidget({
    super.key,
    required this.screenHeight,
    required this.companyNameController,
    required this.descriptionEditingController,
    required this.image,
    required this.screenWidth,
    required this.phoneEditingController,
    required this.emailAddressController,
    required this.websiteEditingController,
    required this.fieldCount,
    required this.fields,
    required this.itemCount,
    required this.images,
    required this.profileImage,
    required this.onSavePressed,
  });

  final double screenHeight;
  final TextEditingController companyNameController;
  final TextEditingController descriptionEditingController;
  final File? image;
  final double screenWidth;
  final TextEditingController phoneEditingController;
  final TextEditingController emailAddressController;
  final TextEditingController websiteEditingController;
  final int? fieldCount;
  final List<TextEditingController> fields;
  final int? itemCount;
  final List<File?>? images;
  final String profileImage;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Assigns.profileDetails,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * (34 / screenHeight),
                letterSpacing: 1)),
        SingleTextWidget(text: Assigns.profileText, screenHeight: screenHeight),
        sizedbox,
        SingleTextWidget(
            screenHeight: screenHeight, text: Assigns.profileDetails),
        SizedBox(height: 10),
        CustomTextFieldWidget(
          keyboardtype: TextInputType.emailAddress,
          controller: companyNameController,
          readOnly: false,
          labelText: 'Company Name',
        ),
        SizedBox(height: 10),
        CustomTextFieldWidget(
          controller: descriptionEditingController,
          keyboardtype: TextInputType.emailAddress,
          readOnly: false,
          labelText: 'About Us',
          maxLine: 4,
        ),
        SizedBox(height: 10),
        UserProfileImageWidget(
            profileImage: profileImage,
            image: image,
            screenWidth: screenWidth,
            screenHeight: screenHeight),
        sizedbox,
        SingleTextWidget(
            screenHeight: screenHeight, text: Assigns.contactInformation),
        SizedBox(height: 10),
        CustomTextFieldWidget(
          keyboardtype: TextInputType.number,
          controller: phoneEditingController,
          readOnly: false,
          labelText: 'Phone Number',
        ),
        SizedBox(height: 10),
        CustomTextFieldWidget(
          keyboardtype: TextInputType.emailAddress,
          readOnly: false,
          controller: emailAddressController,
          labelText: 'Email Address',
        ),
        SizedBox(height: 10),
        CustomTextFieldWidget(
          keyboardtype: TextInputType.multiline,
          readOnly: false,
          controller: websiteEditingController,
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
        LinkFieldsWidget(fieldCount: fieldCount, fields: fields),
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
        MediasWidget(
            screenHeight: screenHeight,
            itemCount: itemCount,
            screenWidth: screenWidth,
            images: images),
        PushableButton_widget(
            buttonText: 'Save Details', onpressed: onSavePressed)
      ],
    );
  }
}
