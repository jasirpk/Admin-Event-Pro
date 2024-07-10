import 'dart:io';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:admineventpro/presentation/components/profile_form/user_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();

  TextEditingController PhoneEditingController = TextEditingController();
  TextEditingController EmailAddressContrller = TextEditingController();
  TextEditingController WebsiteEditingContrller = TextEditingController();
  List<TextEditingController> fields = [];
  File? image;
  ProfileBloc? _profileBoloc;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileBoloc = context.read<ProfileBloc>();
  }

  @override
  void dispose() {
    _profileBoloc?.add(ClearImages());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            int? itemCount = 0;
            List<File?>? images;
            int? fieldCount = 0;

            if (state is GeneratedInitial) {
              itemCount = state.listViewCount;
              fieldCount = state.fieldCount;
              images = state.pickedImages;
              image = state.pickImage;

              fields = state.pickedFields;

              if (fields.isEmpty) {
                fields = List.generate(
                  fieldCount,
                  (index) => TextEditingController(),
                );
              }
            }
            if (state is ImagePickerInitial) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  child: User_FieldsWidget(
                    screenHeight: screenHeight,
                    companyNameController: companyNameController,
                    descriptionEditingController: descriptionEditingController,
                    image: image,
                    screenWidth: screenWidth,
                    PhoneEditingController: PhoneEditingController,
                    EmailAddressContrller: EmailAddressContrller,
                    WebsiteEditingContrller: WebsiteEditingContrller,
                    fieldCount: fieldCount,
                    fields: fields,
                    itemCount: itemCount,
                    images: images,
                  ),
                ),
              ),
            );
          },
        ));
  }
}
