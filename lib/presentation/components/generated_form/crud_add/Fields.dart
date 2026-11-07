import 'dart:io';
import 'package:admineventpro/bussiness_layer/repos/snackbar.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/submit_button.dart';
import 'package:admineventpro/data_layer/services/vendor_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/component_list.dart';
import 'package:admineventpro/presentation/components/generated_form/vendor_form_ui.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';

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
    // A plain Column: the screen already wraps this in a scroll view, and the
    // SingleChildScrollView that used to sit here was a second, redundant
    // viewport nested inside it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorFormIntro(text: Assigns.textPreview),
        const SizedBox(height: 22),

        // ── Category ──────────────────────────────────────────────────────
        VendorSectionHeader(
          title: Assigns.vendorNames,
          icon: Icons.local_offer_outlined,
          subtitle: 'Choose a category, or type your own name below',
        ),
        const SizedBox(height: 12),
        VendorFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorCategoryChips(
                names: names,
                nameEditingController: nameEditingController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameEditingController,
                cursorColor: myColor,
                style: VendorForm.inputText,
                textCapitalization: TextCapitalization.words,
                decoration: VendorForm.input(
                  labelText: 'Displayed Name',
                  hintText: 'What clients will see',
                  icon: Icons.badge_outlined,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // ── Essential components ──────────────────────────────────────────
        VendorSectionHeader(
          title: Assigns.essentialComponent,
          icon: Icons.widgets_outlined,
          subtitle: 'Photos of what this listing includes',
          trailing: VendorStepper(
            count: itemCount ?? 0,
            onAdd: () {
              context.read<GeneratedBloc>().add(IncreamentEvent());
            },
            onRemove: () {
              context.read<GeneratedBloc>().add(DecrementEvent());
            },
          ),
        ),
        const SizedBox(height: 12),
        ComponentsWidget(
            screenHeight: screenHeight,
            itemCount: itemCount,
            imageNameControllers: imageNameControllers,
            screenWidth: screenWidth,
            images: images),
        const SizedBox(height: 26),

        // ── More details ──────────────────────────────────────────────────
        VendorSectionHeader(
          title: Assigns.moreDetails,
          icon: Icons.tune_rounded,
          subtitle: 'The main photo, the write-up and where you operate',
        ),
        const SizedBox(height: 12),
        VendorMainImagePicker(
          imagePath: imagePath,
          image: image,
          onTap: () => context.read<GeneratedBloc>().add(PickImage()),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descriptionEditingController,
          maxLines: 4,
          cursorColor: myColor,
          style: VendorForm.inputText,
          textCapitalization: TextCapitalization.sentences,
          decoration: VendorForm.input(
            labelText: 'Description',
            hintText: 'What makes this vendor worth booking?',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: locationController,
          readOnly: true,
          cursorColor: myColor,
          style: VendorForm.inputText,
          decoration: VendorForm.input(
            labelText: Assigns.location,
            hintText: 'Tap the pin to use your current location',
            icon: Icons.location_on_outlined,
            // The field has always been handed the empty string, which Flutter
            // reads as "there is an error, with no message" and paints the
            // border red on a form the user has not touched yet. Only a real
            // message is an error.
            errorText: errorText.isEmpty ? null : errorText,
            suffixIcon: IconButton(
              tooltip: 'Use my current location',
              onPressed: () {
                context.read<GeneratedBloc>().add(FetchLocation());
              },
              icon: Icon(Icons.my_location_rounded, size: 20, color: myColor),
            ),
          ),
        ),
        const SizedBox(height: 26),

        // ── Budget ────────────────────────────────────────────────────────
        VendorSectionHeader(
          title: Assigns.budget,
          icon: Icons.account_balance_wallet_outlined,
          subtitle: 'The range you quote for this listing',
        ),
        const SizedBox(height: 12),
        VendorBudgetRange(
          fromController: FromBudgetController,
          toController: ToBudgetController,
        ),
        const SizedBox(height: 30),

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
              showCustomSnackBar(
                  'Error', 'Please choose a main image for this vendor.');
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
