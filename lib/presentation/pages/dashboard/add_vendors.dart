import 'dart:io';
import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:admineventpro/data_layer/services/generated_vendor.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_and_icon.dart';
import 'package:admineventpro/presentation/components/ui/custom_text_with_icons.dart';
import 'package:admineventpro/presentation/components/ui/pushable_button.dart';
import 'package:admineventpro/presentation/components/ui/vendor_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddVendorsScreen extends StatefulWidget {
  AddVendorsScreen(
      {this.categoryName, this.categoryDescription, this.imagePath});
  final String? categoryName;
  final String? categoryDescription;
  final String? imagePath;

  @override
  State<AddVendorsScreen> createState() => _AddVendorsScreenState();
}

class _AddVendorsScreenState extends State<AddVendorsScreen> {
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController FromBudgetController = TextEditingController();
  TextEditingController ToBudgetController = TextEditingController();
  TextEditingController imageNameController = TextEditingController();

  File? image;
  String? imagePath = '';
  List<Map<String, String>> names = [
    {'name': Assigns.dressCode},
    {'name': Assigns.styleAndTheme},
    {'name': Assigns.photography},
    {'name': Assigns.decoration},
    {'name': Assigns.djAndBands},
    {'name': Assigns.music},
    {'name': Assigns.catering},
    {'name': Assigns.venues},
  ];
  @override
  void initState() {
    nameEditingController.text = widget.categoryName ?? '';
    descriptionEditingController.text = widget.categoryDescription ?? '';
    imagePath = widget.imagePath ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: Assigns.vendorPreview,
      ),
      body: BlocBuilder<GeneratedBloc, GeneratedState>(
        builder: (context, state) {
          int? itemCount = 0;
          List<File?>? images;

          String errorText = '';
          if (state is GeneratedInitial) {
            itemCount = state.listViewCount;
            images = state.pickedImages;
            image = state.pickImage;
            locationController.text = state.pickLocation;
          }
          if (state is ImagePickerInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
                              screenHeight: screenHeight),
                          sizedbox,
                          TextFormField(
                            controller: nameEditingController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Customize border color and width
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Customize focused border color and width
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Displayed Name',
                              labelStyle: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          ),
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
                                        .read<GeneratedBloc>()
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
                                                  image:
                                                      FileImage(images[index]!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: images == null ||
                                                images[index] == null
                                            ? Center(
                                                child: Icon(
                                                  Icons.collections_bookmark,
                                                  color: Colors.white,
                                                  size: 60,
                                                ),
                                              )
                                            : null,
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
                                                    .read<GeneratedBloc>()
                                                    .add(RemoveImageEvent(
                                                        index));
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: imageNameController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Customize border color and width
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Customize focused border color and width
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: 'Image Name',
                                    labelStyle: TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                  GestureDetector(
                    onTap: () {
                      context.read<GeneratedBloc>().add(PickImage());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                        image: imagePath!.isEmpty
                            ? (image != null
                                ? DecorationImage(
                                    image: FileImage(image!),
                                    fit: BoxFit.cover,
                                  )
                                : null)
                            : DecorationImage(
                                image: imagePath!.startsWith('http')
                                    ? NetworkImage(imagePath!)
                                    : AssetImage(imagePath!) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                image == null && imagePath == null
                                    ? Icons.collections_bookmark
                                    : Icons.edit,
                                color: Colors.white,
                                size: 40),
                          ],
                        ),
                      ),
                      height: screenHeight * 0.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionEditingController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      alignLabelWithHint: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .white), // Customize border color and width
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .white), // Customize focused border color and width
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 10),
                  CustomTextAndIconWidget(
                    text: Assigns.location,
                    icon: Icons.location_on,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'location',
                      errorText: errorText,
                      labelStyle: TextStyle(color: Colors.white70),
                      alignLabelWithHint: true,
                      suffixIcon: IconButton(
                        onPressed: () {
                          context.read<GeneratedBloc>().add(FetchLocation());
                        },
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                  Card(
                    color: Colors.white38,
                    child: Container(
                      height: screenHeight * (140 / screenHeight),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.4,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'From:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w200,
                                        letterSpacing: 1),
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: FromBudgetController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelText: '₹',
                                      prefixIcon: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.currency_rupee,
                                            size: 20,
                                            color: Colors.white,
                                          )),
                                      labelStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.4,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'To:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1),
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: ToBudgetController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelText: '₹',
                                      prefixIcon: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.currency_rupee,
                                            size: 20,
                                            color: Colors.white,
                                          )),
                                      labelStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  PushableButton_widget(
                    buttonText: 'Submit',
                    onpressed: () async {
                      String? imageUrl = imagePath;
                      try {
                        String categoryName = nameEditingController.text;
                        String description = descriptionEditingController.text;
                        String location = locationController.text;
                        List<Map<String, dynamic>> imagesData = [];
                        for (int i = 0; i < images!.length; i++) {
                          if (images[i] != null) {
                            imagesData.add({
                              'image': images[i]!,
                              'text': imageNameController
                                  .text, // Modify as per your requirement
                            });
                          }
                        }

                        if (image != null) {
                          imageUrl = image!
                              .path; // If a new image is picked, use its path
                        } else if (imagePath != null && imagePath!.isNotEmpty) {
                          // If imagePath is already a URL, use it directly
                          imageUrl = imagePath;
                        }

                        bool validate = false;
                        Map<String, double> budget = {
                          'from': double.parse(FromBudgetController.text),
                          'to': double.parse(ToBudgetController.text),
                        };
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await GeneratedVendor().addGeneratedCategoryDetail(
                            uid: user.uid,
                            categoryName: categoryName,
                            description: description,
                            location: location,
                            images: imagesData,
                            imagePath: imageUrl!,
                            budget: budget,
                            context: context,
                            validate: validate,
                          );
                          showCustomSnackBar(
                              "Success", "Details Added Successfully");

                          print('vendor details added');
                        } else {
                          showCustomSnackBar(
                              "Error", "User is not authenticated");
                        }
                      } catch (e) {
                        showCustomSnackBar(
                            "Error", "Failed to add vendor details: $e");
                        print('Not added');
                        print('$imageUrl for image else');
                        print(e.toString());
                      }
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nameEditingController.clear();
    descriptionEditingController.clear();
    imageNameController.clear();
    FromBudgetController.clear();
    ToBudgetController.clear();
    image = null;
    imagePath = null;
    locationController.clear();
    super.dispose();
  }
}
