import 'dart:io';
import 'package:admineventpro/bussiness_layer/repos/snackbar.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/submit_button.dart';
import 'package:admineventpro/data_layer/services/vendor_api_service.dart';
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
    this.categoryId,
    this.subCategoryId,
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

  /// The catalogue entry this listing was opened from, when there is one.
  ///
  /// Both null for a standalone vendor. They travel together: the API treats
  /// one without the other as a half-filled reference and refuses it, so
  /// [_template] is the only thing that reads them.
  final String? categoryId;
  final String? subCategoryId;

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
              // No VendorSaveLoading here. That event emits SaveVendorLoading,
              // a state carrying none of the form's data, and every picked
              // image, the main image and the item count live on
              // GeneratedInitial — so dispatching it erased the component list
              // the moment Submit was pressed, and nothing ever put it back.
              // The spinner it was meant to show never rendered anyway: its
              // two guards compare `State`, the Flutter class, not `state`.
              if (!_hasMainImage()) {
                // A listing needs a picture. Caught here so the user is told
                // what to do rather than seeing a generic server rejection.
                showCustomSnackBar('Error',
                    'Please choose a main image for this vendor.');
              } else if (_validateForm()) {
                try {
                  final template = _template();

                  await FormSubmitManager.submitForm(
                    categoryName: nameEditingController.text,
                    categoryId: template?.categoryId,
                    subCategoryId: template?.subCategoryId,
                    mainImageFile: image,
                    templateImageKey: _templateImageKey(),
                    description: descriptionEditingController.text,
                    location: locationController.text,
                    imagesData: _prepareImagesData(),
                    budget: _prepareBudget(),
                    context: context,
                    locationController: locationController,
                    nameEditingController: nameEditingController,
                    descriptionEditingController: descriptionEditingController,
                    fromBudgetController: FromBudgetController,
                    toBudgetController: ToBudgetController,
                    imageNameControllers: imageNameControllers,
                  );

                } on VendorApiException catch (e) {
                  // e.message is written for a user and never carries a token
                  // or the Authorization header; e.toString() would append the
                  // raw response body, so only the message is shown.
                  showCustomSnackBar('Error', e.message);
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

  /// The catalogue template, when this form was opened from one.
  ///
  /// Returns null unless *both* ids are present and non-blank: the API
  /// refuses one without the other, so a half-filled pair is treated as no
  /// template at all rather than sent and rejected.
  ({String categoryId, String subCategoryId})? _template() {
    final category = categoryId?.trim() ?? '';
    final subCategory = subCategoryId?.trim() ?? '';

    if (category.isEmpty || subCategory.isEmpty) return null;

    return (categoryId: category, subCategoryId: subCategory);
  }

  /// The template's existing R2 object key, if this form has one to reuse.
  ///
  /// Only meaningful alongside a template — a bare key with no category to
  /// go with it would be refused, so it is dropped here instead.
  String? _templateImageKey() {
    if (_template() == null) return null;

    final key = imagePath?.trim() ?? '';

    return key.isEmpty ? null : key;
  }

  /// Every listing needs a main picture: one the user picked, or the
  /// template's own.
  bool _hasMainImage() => image != null || _templateImageKey() != null;

  bool _validateForm() {
    return nameEditingController.text.isNotEmpty &&
        descriptionEditingController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        FromBudgetController.text.isNotEmpty &&
        ToBudgetController.text.isNotEmpty &&
        imageNameControllers.isNotEmpty &&
        images != null;
  }

  List<Map<String, dynamic>> _prepareImagesData() {
    List<Map<String, dynamic>> imagesData = [];

    for (int i = 0; i < images!.length; i++) {
      if (images![i] != null) {
        imagesData.add({
          'image': images![i]!,
          // ComponentsWidget creates each caption controller lazily as the row
          // is built, so a slot scrolled out of view may have none yet. Reading
          // past the end threw and lost the whole submission; an empty caption
          // is the honest value for a field that was never shown.
          'text': i < imageNameControllers.length
              ? imageNameControllers[i].text
              : '',
        });
      }
    }
    return imagesData;
  }

  Map<String, double> _prepareBudget() {
    return {
      'from': double.parse(FromBudgetController.text),
      'to': double.parse(ToBudgetController.text),
    };
  }
}
