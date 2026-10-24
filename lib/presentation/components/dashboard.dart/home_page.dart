import 'package:admineventpro/data_layer/dashboard_bloc/dashboard_bloc.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/data_layer/services/cover_images.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/cover_image.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/place_holder.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  final CoverImageMethods coverImageMethods = CoverImageMethods();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  /// Held in state rather than created in build().
  ///
  /// This used to be `coverImageMethods.getCoverImage(uid)` inline, which
  /// made a fresh Firestore read on every rebuild and flashed the spinner
  /// over the whole page each time.
  late Future<DocumentSnapshot?> _coverFuture;

  @override
  void initState() {
    super.initState();
    _coverFuture = coverImageMethods.getCoverImage(uid);
  }

  /// Re-reads the saved cover. Called only when the selection has actually
  /// changed, so an ordinary rebuild still costs nothing.
  void _refreshCover() {
    if (!mounted) return;

    setState(() {
      _coverFuture = coverImageMethods.getCoverImage(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<DashboardBloc, DashboardState>(
      // CoverImageUploaded is emitted only after the Storage upload and the
      // Firestore write have both completed; a failure emits
      // CoverImageError instead, so a failed save leaves the background as
      // it was.
      listenWhen: (previous, current) => current is CoverImageUploaded,
      listener: (context, state) => _refreshCover(),
      child: Scaffold(
        body: FutureBuilder<DocumentSnapshot?>(
          future: _coverFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error loading image');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return PlaceHolderWidget(
                  screenHeight: screenHeight,
                  databaseMethods: databaseMethods,
                  screenWidth: screenWidth);
            }
            var coverImage = snapshot.data!.data() as Map<String, dynamic>;
            return CoverImageWidget(
                screenHeight: screenHeight,
                coverImage: coverImage,
                databaseMethods: databaseMethods,
                screenWidth: screenWidth);
          },
        ),
      ),
    );
  }
}
