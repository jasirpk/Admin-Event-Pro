import 'package:admineventpro/bussiness_layer/repos/snackbar.dart';
import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admineventpro/common/style.dart';
import 'package:get/get.dart';

class CoverImages extends StatefulWidget {
  const CoverImages({super.key});

  @override
  State<CoverImages> createState() => _CoverImagesState();
}

class _CoverImagesState extends State<CoverImages> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadCoverImages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Cover Images'),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is CoverImageError) {
            Get.snackbar('Error', state.message);
          }
          if (state is CoverImageUploaded) {
            showCustomSnackBar('Success', 'Image update Successfully');
          }
        },
        builder: (context, state) {
          if (state is CoverImageLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is CoverImageLoaded) {
            return GridView.builder(
              itemCount: state.images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                var data = state.images[index];
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    color: myColor,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: myColor),
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(data['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Checkbox(
                            value: state.selectedImageIndex == index,
                            onChanged: (bool? value) {
                              context
                                  .read<DashboardBloc>()
                                  .add(SelectCoverImage(index));
                            },
                            activeColor: myColor,
                            checkColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text('No images found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          context.read<DashboardBloc>().add(UploadCoverImage(uid));
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
