import 'dart:io';
import 'package:admineventpro/data_layer/models/vendor_document.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_edit/edit_fields.dart';
import 'package:flutter/material.dart';
import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:image_picker/image_picker.dart';

/// One row of the Essential Components editor.
///
/// A row is either an existing component ([existingRef] set), a brand new one
/// ([existingRef] null), or an existing one whose picture the user replaced
/// ([picked] set as well). Keeping all three in one object is what lets the
/// editor add and remove rows without the indices of the other rows shifting
/// out from under their captions.
class ComponentRow {
  /// The stored reference — an R2 object key, or a legacy URL on an older
  /// listing. Null for a row the user just added.
  final String? existingRef;

  /// A locally chosen image, not yet uploaded. Wins over [existingRef].
  File? picked;

  final TextEditingController caption;

  ComponentRow({this.existingRef, this.picked, required this.caption});

  /// A row with neither a stored image nor a pick contributes nothing.
  bool get hasImage => picked != null || existingRef != null;

  void dispose() => caption.dispose();
}

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
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fromBudgetController = TextEditingController();
  final TextEditingController toBudgetContrller = TextEditingController();

  /// The editor's own component list.
  ///
  /// Deliberately not the shared GeneratedBloc: its picked-image list is
  /// sized and cleared for the registration form, so adding a row here used
  /// to do nothing and picking the second image threw a RangeError.
  final List<ComponentRow> rows = [];

  /// A newly picked main image, or null to keep the stored one.
  File? image;

  String? imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameEditingController.text = widget.vendorName ?? '';
    descriptionEditingController.text = widget.description ?? '';
    imagePath = widget.vendorImage ?? '';
    locationController.text = widget.location;

    // .toString() on a num prints "25000.0"; the form should show what the
    // user typed, and the API takes either.
    fromBudgetController.text = _budgetText(widget.budget['from']);
    toBudgetContrller.text = _budgetText(widget.budget['to']);

    for (final entry in widget.images) {
      rows.add(ComponentRow(
        existingRef: vendorImageRef(entry),
        caption: TextEditingController(text: vendorImageCaption(entry)),
      ));
    }
  }

  String _budgetText(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    locationController.dispose();
    fromBudgetController.dispose();
    toBudgetContrller.dispose();
    for (final row in rows) {
      row.dispose();
    }
    rows.clear();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => image = File(picked.path));
  }

  Future<void> _pickComponentImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => rows[index].picked = File(picked.path));
  }

  void _addRow() {
    setState(() => rows.add(ComponentRow(caption: TextEditingController())));
  }

  /// Removes a row, which drops it from the array the save writes.
  ///
  /// The stored object stays in R2. Deleting it would need an ownership-aware
  /// delete the API does not offer for a committed listing, and a component
  /// removed by mistake should be recoverable.
  void _removeRow(int index) {
    if (index < 0 || index >= rows.length) return;
    setState(() => rows.removeAt(index).dispose());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final List<Map<String, String>> names = [
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: EditVendorFieldsWidget(
            screenHeight: screenHeight,
            names: names,
            nameEditingController: nameEditingController,
            screenWidth: screenWidth,
            widget: widget,
            imagePath: imagePath,
            image: image,
            rows: rows,
            onPickMainImage: _pickMainImage,
            onPickComponentImage: _pickComponentImage,
            onAddRow: _addRow,
            onRemoveRow: _removeRow,
            descriptionEditingController: descriptionEditingController,
            locationController: locationController,
            fromBudgetController: fromBudgetController,
            toBudgetContrller: toBudgetContrller,
          ),
        ),
      ),
    );
  }
}
