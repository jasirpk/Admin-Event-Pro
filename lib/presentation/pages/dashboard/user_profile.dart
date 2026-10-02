import 'dart:io';
import 'package:admineventpro/data_layer/models/profile_document.dart';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/presentation/components/profile_form/user_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String? companyName;
  final String? description;
  final String? website;
  final String? phoneNumber;
  final String? email;
  final String? imagePath;

  /// The portfolio the profile already stores, in order. Each entry is an R2
  /// object key or a legacy URL.
  ///
  /// Previously the editor received nothing here, so saving replaced the
  /// whole array with only the images picked in that session — editing a
  /// company name wiped the portfolio.
  final List<String> portfolio;

  /// The links the profile already stores.
  final List<String> links;

  const ProfileScreen({
    super.key,
    this.companyName,
    this.description,
    this.website,
    this.phoneNumber,
    this.email,
    this.imagePath,
    this.portfolio = const [],
    this.links = const [],
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final TextEditingController phoneEditingController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController websiteEditingController =
      TextEditingController();

  /// Social links, one controller per row.
  final List<TextEditingController> fields = [];

  /// The portfolio editor's own rows.
  ///
  /// Deliberately not the shared ProfileBloc: its picked-image list holds
  /// only local files, so existing images had nowhere to live, and a
  /// data-less loading state would wipe it mid-save.
  final List<PortfolioRow> portfolio = [];

  /// A freshly picked avatar, or null to keep the stored one.
  File? image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    companyNameController.text = widget.companyName ?? '';
    descriptionEditingController.text = widget.description ?? '';
    phoneEditingController.text = widget.phoneNumber ?? '';
    emailAddressController.text = widget.email ?? '';
    websiteEditingController.text = widget.website ?? '';

    for (final ref in widget.portfolio) {
      portfolio.add(PortfolioRow(existingRef: ref));
    }

    for (final link in widget.links) {
      fields.add(TextEditingController(text: link));
    }

    // One empty row each, so a brand-new profile has something to fill in.
    if (fields.isEmpty) fields.add(TextEditingController());
  }

  @override
  void dispose() {
    companyNameController.dispose();
    descriptionEditingController.dispose();
    phoneEditingController.dispose();
    emailAddressController.dispose();
    websiteEditingController.dispose();
    for (final controller in fields) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => image = File(picked.path));
  }

  Future<void> _pickPortfolioImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => portfolio[index].picked = File(picked.path));
  }

  void _addPortfolioRow() {
    setState(() => portfolio.add(PortfolioRow()));
  }

  /// Removes a row, which drops it from the array the save writes.
  ///
  /// The stored object stays in R2. Deleting it would need an
  /// ownership-aware per-object delete the API does not offer, and an image
  /// removed by mistake should stay recoverable.
  void _removePortfolioRow(int index) {
    if (index < 0 || index >= portfolio.length) return;
    setState(() => portfolio.removeAt(index));
  }

  void _addLinkField() => setState(() => fields.add(TextEditingController()));

  void _removeLinkField() {
    if (fields.length <= 1) return;
    setState(() => fields.removeLast().dispose());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final saving = state is ProfileLoading;

          // The form is rendered on every state, including while saving.
          // Returning a bare spinner here used to replace the whole tree, and
          // because ProfileLoading carries no data the fields came back empty
          // if the save failed. Everything the form needs lives in this
          // State, so the tree survives any state change.
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: User_FieldsWidget(
                    profileImage: widget.imagePath ?? '',
                    screenHeight: screenHeight,
                    companyNameController: companyNameController,
                    descriptionEditingController: descriptionEditingController,
                    image: image,
                    screenWidth: screenWidth,
                    phoneEditingController: phoneEditingController,
                    emailAddressController: emailAddressController,
                    websiteEditingController: websiteEditingController,
                    fields: fields,
                    portfolio: portfolio,
                    saving: saving,
                    onPickAvatar: _pickAvatar,
                    onPickPortfolioImage: _pickPortfolioImage,
                    onAddPortfolioRow: _addPortfolioRow,
                    onRemovePortfolioRow: _removePortfolioRow,
                    onAddLinkField: _addLinkField,
                    onRemoveLinkField: _removeLinkField,
                    onSavePressed: saving ? null : _save,
                  ),
                ),
              ),
              if (saving)
                // A non-blocking overlay rather than a replacement, so the
                // user can still see what they typed while it uploads.
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Colors.black45,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _save() {
    final companyName = companyNameController.text.trim();
    final about = descriptionEditingController.text.trim();
    final phoneNumber = phoneEditingController.text.trim();
    final emailAddress = emailAddressController.text.trim();
    final website = websiteEditingController.text.trim();

    final links = fields
        .map((controller) => controller.text.trim())
        .where((link) => link.isNotEmpty)
        .toList();

    // The avatar may come from the stored value; the portfolio may be empty
    // if the user removed everything, which is a legitimate edit.
    final hasAvatar = image != null || (widget.imagePath ?? '').isNotEmpty;

    if (companyName.isEmpty ||
        about.isEmpty ||
        phoneNumber.length != 10 ||
        !emailAddress.contains('@') ||
        website.isEmpty ||
        !hasAvatar) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill all the required fields')));
      return;
    }

    context.read<ProfileBloc>().add(SaveProfile(
          companyName: companyName,
          about: about,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
          website: website,
          portfolio: portfolio,
          links: links,
          existingProfileImage: widget.imagePath,
          newProfileImage: image,
        ));
  }
}
