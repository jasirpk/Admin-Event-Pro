import 'dart:io';

import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/budget.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_image.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_edit/component.dart';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_name.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/description.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/location_widget.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/common/style.dart';
import 'package:get/get.dart';

class EditVendorFieldsWidget extends StatelessWidget {
  const EditVendorFieldsWidget({
    super.key,
    required this.screenHeight,
    required this.names,
    required this.nameEditingController,
    required this.screenWidth,
    required this.imageNameControllers,
    required this.widget,
    required this.imagePath,
    required this.image,
    required this.descriptionEditingController,
    required this.locationController,
    required this.fromBudgetController,
    required this.toBudgetContrller,
  });

  final double screenHeight;
  final List<Map<String, String>> names;
  final TextEditingController nameEditingController;
  final double screenWidth;
  final List<TextEditingController> imageNameControllers;
  final EditVendorScreen widget;
  final String? imagePath;
  final File? image;
  final TextEditingController descriptionEditingController;
  final TextEditingController locationController;
  final TextEditingController fromBudgetController;
  final TextEditingController toBudgetContrller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Assigns.textPreview,
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 8),
        Text(
          Assigns.vendorNames,
          style: TextStyle(
            color: myColor,
            fontFamily: 'JacquesFracois',
            fontSize: screenHeight * 0.020,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        Card(
          color: Colors.white24,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: [
                VendorNmesWidget(
                  names: names,
                  nameEditingController: nameEditingController,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                SizedBox(height: 8),
                CategoryNameWidget(
                  nameEditingController: nameEditingController,
                ),
              ],
            ),
          ),
        ),
        CustomTextWithIconsWidget(
          screenHeight: screenHeight,
          text: Assigns.essentialComponent,
          onAddpressed: () {
            context.read<GeneratedBloc>().add(IncreamentEvent());
          },
          onRemovePressed: () {
            context.read<GeneratedBloc>().add(DecrementEvent());
          },
        ),
        ComponentEditsWidget(
            screenHeight: screenHeight,
            itemCount: imageNameControllers.length,
            imageNameControllers: imageNameControllers,
            screenWidth: screenWidth,
            imagesData: widget.images),
        Text(
          Assigns.moreDetails,
          style: TextStyle(
            color: myColor,
            fontFamily: 'JacquesFracois',
            fontSize: screenHeight * 0.020,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 10),
        CategoryImageWidget(
            imagePath: imagePath, image: image, screenHeight: screenHeight),
        SizedBox(height: 10),
        Description_Widget(
          descriptionEditingController: descriptionEditingController,
        ),
        SizedBox(height: 10),
        CustomTextAndIconWidget(
          text: Assigns.location,
          icon: Icons.location_on,
          screenHeight: screenHeight,
        ),
        SizedBox(height: 10),
        Location_widget(
          locationController: locationController,
          errorText: '',
        ),
        SizedBox(height: 10),
        Text(
          Assigns.budget,
          style: TextStyle(
            color: myColor,
            fontFamily: 'JacquesFracois',
            fontSize: screenHeight * 0.020,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 10),
        Budget_widget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            FromBudgetController: fromBudgetController,
            ToBudgetController: toBudgetContrller),
        SizedBox(height: 10),
        PushableButton_widget(
          buttonText: 'Submit',
          onpressed: () async {
            if (nameEditingController.text.isNotEmpty &&
                descriptionEditingController.text.isNotEmpty &&
                locationController.text.isNotEmpty &&
                fromBudgetController.text.isNotEmpty &&
                toBudgetContrller.text.isNotEmpty &&
                imageNameControllers.isNotEmpty &&
                imagePath != null) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  Map<String, double> budgetMap = {
                    'from': double.parse(fromBudgetController.text),
                    'to': double.parse(toBudgetContrller.text),
                  };

                  await GeneratedVendor().updateGeneratedCategoryDetail(
                    uid: user.uid,
                    documentId: widget.vendorId,
                    categoryName: nameEditingController.text,
                    description: descriptionEditingController.text,
                    location: locationController.text,
                    budget: budgetMap,
                  );
                  Get.back();
                  showCustomSnackBar(
                      'Success', 'Vendor details updated successfully');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Failed to update vendor details: $e')),
                  );
                }
              }
            } else {
              showCustomSnackBar('Error', 'Please fill all fields');
            }
          },
        ),
      ],
    );
  }
}
