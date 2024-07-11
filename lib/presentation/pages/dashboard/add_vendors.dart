import 'dart:io';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_add/Fields.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
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
          if (State is SaveVendorLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          int? itemCount = 0;
          List<File?>? images;

          String errorText = '';
          if (state is GeneratedInitial) {
            itemCount = state.listViewCount;
            images = state.pickedImages;
            image = state.pickImage;
            locationController.text = state.pickLocation;
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
          if (State is SaveVendorLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: ComponentsFieldsWidget(
                  screenHeight: screenHeight,
                  names: names,
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
