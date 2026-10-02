import 'dart:io';
import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/profile_form/link_fields.dart';
import 'package:admineventpro/presentation/components/profile_form/medias.dart';
import 'package:admineventpro/presentation/components/profile_form/profile_image.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/single_text.dart';
import 'package:flutter/material.dart';

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
    required this.fields,
    required this.portfolio,
    required this.profileImage,
    required this.saving,
    required this.onPickAvatar,
    required this.onPickPortfolioImage,
    required this.onAddPortfolioRow,
    required this.onRemovePortfolioRow,
    required this.onAddLinkField,
    required this.onRemoveLinkField,
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
  final List<TextEditingController> fields;
  final List<PortfolioRow> portfolio;
  final String profileImage;
  final bool saving;
  final VoidCallback onPickAvatar;
  final void Function(int index) onPickPortfolioImage;
  final VoidCallback onAddPortfolioRow;
  final void Function(int index) onRemovePortfolioRow;
  final VoidCallback onAddLinkField;
  final VoidCallback onRemoveLinkField;

  /// Null while a save is in flight, which disables the button.
  final VoidCallback? onSavePressed;

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
            onTap: onPickAvatar,
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
            onAddpressed: onAddLinkField,
            onRemovePressed: onRemoveLinkField),
        sizedbox,
        LinkFieldsWidget(fieldCount: fields.length, fields: fields),
        sizedbox,
        CustomTextWithIconsWidget(
            screenHeight: screenHeight,
            text: Assigns.portFolio,
            // These used to dispatch to the shared bloc, whose picked-image
            // list held only local files — so an existing portfolio image
            // had nowhere to live and was lost on save.
            onAddpressed: onAddPortfolioRow,
            onRemovePressed: () => onRemovePortfolioRow(portfolio.length - 1)),
        SizedBox(height: 10),
        MediasWidget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            portfolio: portfolio,
            onPickImage: onPickPortfolioImage,
            onRemoveRow: onRemovePortfolioRow),
        PushableButton_widget(
            buttonText: saving ? 'Saving…' : 'Save Details',
            onpressed: onSavePressed ?? () {})
      ],
    );
  }
}
