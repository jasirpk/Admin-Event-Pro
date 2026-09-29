import 'dart:io';

import 'package:admineventpro/bussiness_layer/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/data_layer/services/vendor_api_service.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/budget.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_image.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_edit/component.dart';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_name.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/description.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/location_widget.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/common/style.dart';
import 'package:get/get.dart';

class EditVendorFieldsWidget extends StatelessWidget {
  const EditVendorFieldsWidget({
    super.key,
    required this.screenHeight,
    required this.names,
    required this.nameEditingController,
    required this.screenWidth,
    required this.widget,
    required this.imagePath,
    required this.image,
    required this.descriptionEditingController,
    required this.locationController,
    required this.fromBudgetController,
    required this.toBudgetContrller,
    required this.rows,
    required this.onPickMainImage,
    required this.onPickComponentImage,
    required this.onAddRow,
    required this.onRemoveRow,
  });

  final double screenHeight;
  final List<Map<String, String>> names;
  final TextEditingController nameEditingController;
  final double screenWidth;
  final EditVendorScreen widget;
  final String? imagePath;
  final File? image;
  final TextEditingController descriptionEditingController;
  final TextEditingController locationController;
  final TextEditingController fromBudgetController;
  final TextEditingController toBudgetContrller;
  final List<ComponentRow> rows;
  final VoidCallback onPickMainImage;
  final void Function(int index) onPickComponentImage;
  final VoidCallback onAddRow;
  final void Function(int index) onRemoveRow;

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
          // These used to dispatch to the shared registration bloc, which
          // this screen never listened to — so the buttons did nothing.
          onAddpressed: onAddRow,
          onRemovePressed: () => onRemoveRow(rows.length - 1),
        ),
        ComponentEditsWidget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            rows: rows,
            onPickImage: onPickComponentImage,
            onRemoveRow: onRemoveRow),
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
            imagePath: imagePath,
            image: image,
            screenHeight: screenHeight,
            onTap: onPickMainImage),
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
            if (nameEditingController.text.trim().isNotEmpty &&
                descriptionEditingController.text.trim().isNotEmpty &&
                locationController.text.trim().isNotEmpty &&
                fromBudgetController.text.isNotEmpty &&
                toBudgetContrller.text.isNotEmpty) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  Map<String, double> budgetMap = {
                    'from': double.parse(fromBudgetController.text),
                    'to': double.parse(toBudgetContrller.text),
                  };

                  final vendor = GeneratedVendor();

                  // Uploads happen first, so a failure here leaves the
                  // listing untouched rather than half-edited. Rows the user
                  // did not touch keep their stored reference and are never
                  // re-uploaded; rows they removed are simply absent.
                  final images = await vendor.resolveEditedRows(
                    vendorId: widget.vendorId,
                    rows: rows,
                  );

                  await vendor.updateGeneratedCategoryDetail(
                    documentId: widget.vendorId,
                    categoryName: nameEditingController.text.trim(),
                    description: descriptionEditingController.text.trim(),
                    location: locationController.text.trim(),
                    budget: budgetMap,
                    images: images,
                    // Only a freshly picked file. Omitted when unchanged, so
                    // the stored key — which may be catalogue artwork or a
                    // legacy URL — is left exactly as it is.
                    imagePathUrl: image == null
                        ? null
                        : await VendorApiService.instance.uploadImage(
                            vendorId: widget.vendorId,
                            file: image!,
                          ),
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
