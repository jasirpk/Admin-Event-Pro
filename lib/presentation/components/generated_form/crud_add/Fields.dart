import 'dart:io';
import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/budget.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_image.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/category_name.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/component_list.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/description.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/location_widget.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';

class ComponentsFieldsWidget extends StatelessWidget {
  const ComponentsFieldsWidget({
    Key? key,
    required this.screenHeight,
    required this.names,
    required this.nameEditingController,
    required this.screenWidth,
    required this.itemCount,
    required this.imageNameControllers,
    required this.images,
    required this.imagePath,
    required this.image,
    required this.descriptionEditingController,
    required this.locationController,
    required this.errorText,
    required this.FromBudgetController,
    required this.ToBudgetController,
  }) : super(key: key);

  final double screenHeight;
  final List<Map<String, String>> names;
  final TextEditingController nameEditingController;
  final double screenWidth;
  final int? itemCount;
  final List<TextEditingController> imageNameControllers;
  final List<File?>? images;
  final String? imagePath;
  final File? image;
  final TextEditingController descriptionEditingController;
  final TextEditingController locationController;
  final String errorText;
  final TextEditingController FromBudgetController;
  final TextEditingController ToBudgetController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
          SizedBox(height: 8),
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
          ComponentsWidget(
              screenHeight: screenHeight,
              itemCount: itemCount,
              imageNameControllers: imageNameControllers,
              screenWidth: screenWidth,
              images: images),
          SizedBox(height: 8),
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
          SizedBox(height: 8),
          CategoryImageWidget(
            imagePath: imagePath,
            image: image,
            screenHeight: screenHeight,
          ),
          SizedBox(height: 8),
          Description_Widget(
              descriptionEditingController: descriptionEditingController),
          SizedBox(height: 8),
          CustomTextAndIconWidget(
            text: Assigns.location,
            icon: Icons.location_on,
            screenHeight: screenHeight,
          ),
          SizedBox(height: 8),
          Location_widget(
              locationController: locationController, errorText: errorText),
          SizedBox(height: 8),
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
          SizedBox(height: 8),
          Budget_widget(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              FromBudgetController: FromBudgetController,
              ToBudgetController: ToBudgetController),
          SizedBox(height: 16),
          PushableButton_widget(
            buttonText: 'Submit',
            onpressed: () async {
              Get.back();
              context.read<GeneratedBloc>().add(VendorSaveLoading());

              if (_validateForm()) {
                try {
                  await FormSubmitManager.submitForm(
                    categoryName: nameEditingController.text,
                    description: descriptionEditingController.text,
                    location: locationController.text,
                    imagesData: _prepareImagesData(),
                    imageUrl: _resolveImageUrl(),
                    budget: _prepareBudget(),
                    context: context,
                    locationController: locationController,
                    nameEditingController: nameEditingController,
                    descriptionEditingController: descriptionEditingController,
                    fromBudgetController: FromBudgetController,
                    toBudgetController: ToBudgetController,
                    imageNameControllers: imageNameControllers,
                  );
                  showCustomSnackBar('Success', 'Succesfully Registered');
                } catch (e) {
                  showCustomSnackBar('Error', 'Failed to submit: $e');
                }
              } else {
                showCustomSnackBar('Error', 'Please fill all fields');
              }
            },
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    return nameEditingController.text.isNotEmpty &&
        descriptionEditingController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        FromBudgetController.text.isNotEmpty &&
        ToBudgetController.text.isNotEmpty &&
        imageNameControllers.isNotEmpty &&
        imagePath != null &&
        images != null;
  }

  List<Map<String, dynamic>> _prepareImagesData() {
    List<Map<String, dynamic>> imagesData = [];

    for (int i = 0; i < images!.length; i++) {
      if (images![i] != null) {
        imagesData.add({
          'image': images![i]!,
          'text': imageNameControllers[i].text,
        });
      }
    }
    return imagesData;
  }

  String? _resolveImageUrl() {
    if (image != null) {
      return image!.path;
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath;
    }
    return null;
  }

  Map<String, double> _prepareBudget() {
    return {
      'from': double.parse(FromBudgetController.text),
      'to': double.parse(ToBudgetController.text),
    };
  }
}
