import 'dart:io';
import 'package:admineventpro/presentation/components/generated_form/crud_edit/edit_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditVendorScreen extends StatefulWidget {
  final String? vendorName;
  final String? description;
  final String? vendorImage;
  final String location;
  final List<Map<String, dynamic>> images;
  final Map<String, double> budget;
  final String vendorId;

  const EditVendorScreen({
    Key? key,
    this.vendorName,
    this.description,
    this.vendorImage,
    required this.location,
    required this.images,
    required this.budget,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<EditVendorScreen> createState() => _EditVendorScreenState();
}

class _EditVendorScreenState extends State<EditVendorScreen> {
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController fromBudgetController = TextEditingController();
  TextEditingController toBudgetContrller = TextEditingController();
  List<TextEditingController> imageNameControllers = [];

  /// A newly picked main image, or null to keep the stored one.
  File? image;

  /// Newly picked component images, by row index. Rows absent here keep
  /// whatever the listing already stores — that is what makes "change one
  /// picture" leave the others alone.
  final Map<int, File> componentReplacements = {};

  String? imagePath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => image = File(picked.path));
  }

  Future<void> _pickComponentImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => componentReplacements[index] = File(picked.path));
  }

  void _clearComponentReplacement(int index) {
    if (!componentReplacements.containsKey(index)) return;
    setState(() => componentReplacements.remove(index));
  }

  @override
  void initState() {
    super.initState();
    nameEditingController.text = widget.vendorName ?? '';
    descriptionEditingController.text = widget.description ?? '';
    imagePath = widget.vendorImage ?? '';
    locationController.text = widget.location;
    fromBudgetController.text = widget.budget['from'].toString();
    toBudgetContrller.text = widget.budget['to'].toString();

    imageNameControllers = List.generate(
      widget.images.length,
      (index) =>
          TextEditingController(text: widget.images[index]['text'] ?? ''),
    );
  }

  @override
  void dispose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    locationController.dispose();
    fromBudgetController.dispose();
    toBudgetContrller.dispose();
    // Dispose before clearing: clearing first emptied the list, so the loop
    // that followed ran zero times and every caption controller leaked.
    for (final controller in imageNameControllers) {
      controller.dispose();
    }
    imageNameControllers.clear();
    super.dispose();
  }

  GeneratedBloc? generatedBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generatedBloc = context.read<GeneratedBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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

    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Edit Vendor Details'),
      body: BlocBuilder<GeneratedBloc, GeneratedState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: EditVendorFieldsWidget(
                  screenHeight: screenHeight,
                  names: names,
                  nameEditingController: nameEditingController,
                  screenWidth: screenWidth,
                  imageNameControllers: imageNameControllers,
                  widget: widget,
                  imagePath: imagePath,
                  image: image,
                  componentReplacements: componentReplacements,
                  onPickMainImage: _pickMainImage,
                  onPickComponentImage: _pickComponentImage,
                  onClearComponentReplacement: _clearComponentReplacement,
                  descriptionEditingController: descriptionEditingController,
                  locationController: locationController,
                  fromBudgetController: fromBudgetController,
                  toBudgetContrller: toBudgetContrller),
            ),
          );
        },
      ),
    );
  }
}
