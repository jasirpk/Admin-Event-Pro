import 'dart:io';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/Fields.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddVendorsScreen extends StatefulWidget {
  AddVendorsScreen({
    this.categoryId,
    this.subCategoryId,
    this.categoryName,
    this.categoryDescription,
    this.imagePath,
  });

  /// The catalogue entry this listing is created from, when there is one.
  ///
  /// Optional: a template is a convenience, not a requirement. Opening this
  /// screen with no arguments is the standalone flow, where the user types
  /// the details and picks their own main image.
  final String? categoryId;
  final String? subCategoryId;

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
  List<TextEditingController> imageNameControllers = [];

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

  GeneratedBloc? _generatedBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generatedBloc = context.read<GeneratedBloc>();
  }

  @override
  void dispose() {
    _generatedBloc?.add(ClearImages());
    super.dispose();
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
            // Only when the bloc actually resolved a location. This used to
            // assign unconditionally, and pickLocation is '' until the
            // "use my location" button runs — so any rebuild (picking a
            // component image, for one) blanked a location the user had
            // typed, and Submit then reported "Please fill all fields".
            if (state.pickLocation.isNotEmpty &&
                locationController.text != state.pickLocation) {
              locationController.text = state.pickLocation;
            }
            if (imageNameControllers.isEmpty) {
              imageNameControllers = List.generate(
                itemCount,
                (index) => TextEditingController(),
              );
            }
          }
          if (state is ImagePickerInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // There is deliberately no SaveVendorLoading branch. Two used to sit
          // here, both written `State is SaveVendorLoading` — the Flutter
          // class, not this builder's `state` — so neither could ever be true.
          // Correcting the typo would not have helped: that state carries none
          // of the form's data, so rendering it would throw the picked images
          // away mid-submission. Submit reports progress through snackbars.
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: ComponentsFieldsWidget(
                  screenHeight: screenHeight,
                  names: names,
                  categoryId: widget.categoryId,
                  subCategoryId: widget.subCategoryId,
                  nameEditingController: nameEditingController,
                  screenWidth: screenWidth,
                  itemCount: itemCount,
                  imageNameControllers: imageNameControllers,
                  images: images,
                  imagePath: imagePath,
                  image: image,
                  descriptionEditingController: descriptionEditingController,
                  locationController: locationController,
                  errorText: errorText,
                  FromBudgetController: FromBudgetController,
                  ToBudgetController: ToBudgetController),
            ),
          );
        },
      ),
    );
  }
}
