import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/budget.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/components.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/description.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/location.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/vendor_image.dart';
import 'package:admineventpro/presentation/components/generated_form/crud_read/vendro_name.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/pages/dashboard/edit_vendor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadVendorScreen extends StatelessWidget {
  final String vendorName;
  final String vendorImage;
  final String location;
  final String description;
  final List<Map<String, dynamic>> images;
  final Map<String, double> budget;

  /// The listing's document id, needed to edit it.
  final String vendorId;

  /// The `uid` field stored on the listing — the entrepreneur it belongs to.
  ///
  /// Only used to decide whether to offer the Edit action. It is not what
  /// authorizes the write: the save path builds its Firestore reference from
  /// `FirebaseAuth.instance.currentUser`, so a listing belonging to someone
  /// else could not be written to even if this were wrong.
  final String? ownerUid;

  const ReadVendorScreen({
    super.key,
    required this.vendorName,
    required this.vendorImage,
    required this.location,
    required this.description,
    required this.images,
    required this.budget,
    required this.vendorId,
    this.ownerUid,
  });

  /// Whether the signed-in entrepreneur owns this listing.
  bool get _isOwner {
    final current = FirebaseAuth.instance.currentUser?.uid;
    return current != null && current == ownerUid;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Vendor Details',
        actions: [
          // Same AppBar-action pattern as the existing share button. Shown
          // only to the owner — everyone else sees the details read-only.
          if (_isOwner)
            IconButton(
              tooltip: 'Edit vendor',
              onPressed: () => Get.to(() => EditVendorScreen(
                    vendorId: vendorId,
                    vendorName: vendorName,
                    vendorImage: vendorImage,
                    location: location,
                    description: description,
                    images: images,
                    budget: budget,
                  )),
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
          sizedboxWidth,
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VendorImageWidget(vendorImage: vendorImage),
              SizedBox(height: 10),
              VendorNameWidget(
                  screenWidth: screenWidth, vendorName: vendorName),
              sizedbox,
              Text(Assigns.component),
              SizedBox(height: 10),
              componentsWidget(images: images, screenWidth: screenWidth),
              sizedbox,
              Row(
                children: [
                  Text(
                    Assigns.location,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.038,
                    ),
                  ),
                  Icon(Icons.location_on, color: Colors.white),
                ],
              ),
              SizedBox(height: 10),
              LocationWidget(screenHeight: screenHeight, location: location),
              sizedbox,
              Text(Assigns.aboutUs),
              sizedBoxSmall,
              DescriptionWidget(description: description),
              sizedbox,
              Text(
                Assigns.budget,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.038,
                ),
              ),
              sizedBoxSmall,
              BudgetWidget(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  vendorImage: vendorImage,
                  budget: budget),
            ],
          ),
        ),
      ),
    );
  }
}
