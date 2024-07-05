import 'dart:io';

import 'package:admineventpro/common/assigns.dart';
import 'package:flutter/material.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated/generated_bloc.dart';

import 'package:admineventpro/presentation/components/generated_form/budget.dart';
import 'package:admineventpro/presentation/components/generated_form/category_image.dart';
import 'package:admineventpro/presentation/components/generated_form/category_name.dart';
import 'package:admineventpro/presentation/components/generated_form/component_list.dart';
import 'package:admineventpro/presentation/components/generated_form/description.dart';
import 'package:admineventpro/presentation/components/generated_form/location_widget.dart';
import 'package:admineventpro/presentation/components/generated_form/submit_button.dart';

import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComponentsFieldsWidget extends StatelessWidget {
  const ComponentsFieldsWidget({
    super.key,
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
  });

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
                    screenHeight: screenHeight),
                sizedbox,
                CategoryNameWidget(
                    nameEditingController: nameEditingController),
              ],
            ),
          ),
        ),
        sizedbox,
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
            descriptionEditingController: descriptionEditingController),
        SizedBox(height: 10),
        CustomTextAndIconWidget(
          text: Assigns.location,
          icon: Icons.location_on,
          screenHeight: screenHeight,
        ),
        SizedBox(height: 10),
        Location_widget(
            locationController: locationController, errorText: errorText),
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
            FromBudgetController: FromBudgetController,
            ToBudgetController: ToBudgetController),
        SizedBox(height: 10),
        PushableButton_widget(
          buttonText: 'Submit',
          onpressed: () async {
            String? imageUrl = imagePath;
            String categoryName = nameEditingController.text;
            String description = descriptionEditingController.text;
            String location = locationController.text;
            List<Map<String, dynamic>> imagesData = [];

            // Populate imagesData with selected images and their texts
            for (int i = 0; i < images!.length; i++) {
              if (images![i] != null) {
                imagesData.add({
                  'image': images![i]!,
                  'text': imageNameControllers[i].text,
                });
              }
            }
            if (image != null) {
              imageUrl = image!.path; // If a new image is picked, use its path
            } else if (imagePath != null && imagePath!.isNotEmpty) {
              // If imagePath is already a URL, use it directly
              imageUrl = imagePath;
            }

            Map<String, double> budget = {
              'from': double.parse(FromBudgetController.text),
              'to': double.parse(ToBudgetController.text),
            };

            // Call the method from VendorDetailsManager to add vendor details
            await VendorDetailsManager.addVendorDetails(
              categoryName: categoryName,
              description: description,
              location: location,
              imagesData: imagesData,
              imageUrl: imageUrl,
              budget: budget,
              context: context,
              locationController: locationController,
              nameEditingController: nameEditingController,
              descriptionEditingController: descriptionEditingController,
              FromBudgetController: FromBudgetController,
              ToBudgetController: ToBudgetController,
              imageNameControllers: imageNameControllers,
            );
          },
        )
      ],
    );
  }
}
